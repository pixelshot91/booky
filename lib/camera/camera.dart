import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import '../bundle.dart';
import '../common.dart' as common;
import 'draggable_widget.dart';

/// Camera example home widget.
class CameraWidget extends StatefulWidget {
  /// Default Constructor
  const CameraWidget({Key? key}) : super(key: key);

  @override
  State<CameraWidget> createState() {
    return _CameraWidgetState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  late String bundleName;

  Directory get getBundleDir => Directory(path.join(common.bookyDir.path, bundleName));
  Bundle get getBundle => Bundle(getBundleDir);

  void _generateNewFolderPath() {
    bundleName = DateTime.now().toIso8601String().replaceAll(':', '_');
  }

  @override
  void initState() {
    super.initState();
    _generateNewFolderPath();
    WidgetsBinding.instance.addObserver(this);

    Future(() async {
      try {
        // WidgetsFlutterBinding.ensureInitialized();
        _cameras = await availableCameras();
      } on CameraException catch (e) {
        _logError(e.code, e.description);
      }
      _onNewCameraSelected(_cameras.first);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booky Camera app'), actions: [
        PopupMenuButton<void>(
          itemBuilder: (_) => [
            PopupMenuItem(
                child: const Text('Change camera'),
                onTap: () async {
                  await Future.delayed(const Duration(seconds: 0), () async {
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext _) => SimpleDialog(
                          title: const Text('Select camera'),
                          children: _cameras
                              .where((c) => c.lensDirection == CameraLensDirection.back)
                              .map((c) => SimpleDialogOption(
                                    onPressed: () => _onNewCameraSelected(c),
                                    child: Text('Camera ${c.name}'),
                                  ))
                              .toList()),
                    );
                  });
                })
          ],
        ),
      ]),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: _cameraPreviewWidget(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: BottomWidget(
                bundle: getBundle,
                onSubmit: () {
                  setState(() {
                    _generateNewFolderPath();
                  });
                  Navigator.pop(context);
                }),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(
        controller!,
        child: LayoutBuilder(
          builder: (context, boxConstraints) => GestureDetector(
            onTapDown: (TapDownDetails details) async {
              _onViewFinderTap(details, boxConstraints);
              // The auto focus is not instantaneous. We must wait a little while before taking the picture
              // In release mode, if we
              // wait 100 ms : blurry
              // wait 300 ms : sharp
              // The optimum delay shall lie between the bounds
              await Future<void>.delayed(const Duration(milliseconds: 300));
              _onTakePictureButtonPressed();
            },
          ),
        ),
      );
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (mounted) {
        if (file != null) {
          await getBundleDir.create();
          file.saveTo(_getFirstUnusedName(getBundleDir));
        }
      }
    });
  }

  String _getFirstUnusedName(Directory dir) =>
      List.generate(20, (index) => path.join(dir.path, '$index.jpg')).firstWhere((path) => !File(path).existsSync());

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class BottomWidget extends StatefulWidget {
  const BottomWidget({required this.bundle, required this.onSubmit});
  final Bundle bundle;
  final void Function() onSubmit;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      return Row(
        children: <Widget>[
          _thumbnailWidget(widget.bundle.images),
          _addMetadataButton(context: context, directory: widget.bundle.directory, onSubmit: widget.onSubmit),
        ],
      );
    } on PathNotFoundException {
      return const Text('Tap the screen to take a picture');
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget(Iterable<FileSystemEntity> images) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: images
              .map((imgFile) => SizedBox(
                    width: 64,
                    height: 64,
                    child: DraggableWidget(
                        // Use a key otherwise if we delete an image, the image that will take its place will inherit the state of the deleted image
                        key: ValueKey(imgFile.path),
                        child: Image.file(File(imgFile.path)),
                        onVerticalDrag: () => setState(() {
                              imgFile.deleteSync();
                            })),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _addMetadataButton(
          {required BuildContext context, required Directory directory, required void Function() onSubmit}) =>
      IconButton(
          icon: const Icon(Icons.keyboard_arrow_right),
          onPressed: () => showDialog<void>(
              context: context,
              builder: (BuildContext context) => MetadataWidget(directory: directory, onSubmit: onSubmit)));
}

class MetadataWidget extends StatefulWidget {
  const MetadataWidget({
    required this.directory,
    required this.onSubmit,
  });
  final Directory directory;
  final void Function() onSubmit;

  @override
  State<MetadataWidget> createState() => _MetadataWidgetState();
}

class _MetadataWidgetState extends State<MetadataWidget> {
  var metadata = common.Metadata();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add the final metadata'),
      children: [
        TextFormField(
          initialValue: '',
          autofocus: true,
          onChanged: (newText) => setState(() => metadata.weightGrams = int.parse(newText)),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.scale),
            labelText: 'Weight in grams',
          ),
          style: const TextStyle(fontSize: 20),
        ),
        DropdownButton<common.ItemState>(
            hint: const Text('Book state'),
            value: metadata.itemState,
            items: common.ItemState.values.map((s) => DropdownMenuItem(value: s, child: Text(s.loc))).toList(),
            onChanged: (state) => setState(() {
                  metadata.itemState = state;
                })),
        IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final managePerm = await Permission.manageExternalStorage.request();
              print('managePerm = $managePerm');
              File(path.join(widget.directory.path, 'metadata.json')).writeAsStringSync(jsonEncode(metadata.toJson()));
              widget.onSubmit();
            })
      ],
    );
  }
}

List<CameraDescription> _cameras = <CameraDescription>[];
/*

Future<void> main() async {
  runApp(const MaterialApp(home: Explorer()));
  // Fetch the available cameras before initializing the app.
  */
/*try {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(const CameraApp());*/ /*

}
*/
