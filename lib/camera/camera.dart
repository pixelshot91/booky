import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import '../bundle.dart';
import '../common.dart' as common;
import 'barcode_detector_painter.dart';
import 'draggable_widget.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  late String bundleName;

  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.ean13]);
  bool _isBusy = false;
  bool _canProcessBarcode = true;
  CustomPaint? _customPaint;
  final Map<String, int> _registeredBarcodes = {};

  Directory get getBundleDir => Directory(path.join(common.bookyDir.path, bundleName));
  Bundle get getBundle => Bundle(getBundleDir);

  void _generateNewFolderPath() {
    bundleName = common.nowAsFileName();
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
    _canProcessBarcode = false;
    _barcodeScanner.close();
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

  /// The minimum number of time the barcode stream decoder must see a barcode to consider it valid.
  /// Use the prevent false barcode decoding to show up (due to glare, poor image quality)
  static const minBarcodeOccurrence = 20;

  /// All ISBN (EAN-13) should start with 978
  /// Use to prevent false barcode decoding
  static const isbnPrefix = '978';
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
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: _getValidRegisteredBarcodes().map((barcode) {
                        return Row(
                          children: [
                            Expanded(child: Text(barcode, style: const TextStyle(fontWeight: FontWeight.bold))),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _registeredBarcodes.remove(barcode);
                                  });
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Center(
                      child: _cameraPreviewWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: BottomWidget(
                bundle: getBundle,
                onSubmit: () {
                  setState(() {
                    _generateNewFolderPath();
                    _registeredBarcodes.clear();
                  });
                  Navigator.pop(context);
                },
                onBarcodeDetectStart: () => controller!.startImageStream(_processCameraImage),
                onBarcodeDetectStop: () async {
                  await controller!.stopImageStream();
                  setState(() => _customPaint = null);
                },
                isbns: _getValidRegisteredBarcodes(),
              ),
            ),
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
      return Center(
        child: CameraPreview(
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
              child: _customPaint,
            ),
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
      // If the imageFormatGroup is specified, the stream processing does not work anymore
      // It seems that the default format for still picture is jpeg, bu the default format for streaming is not
      // imageFormatGroup: ImageFormatGroup.jpeg,
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
      await cameraController.setFlashMode(FlashMode.off);
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

  Future<void> _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = controller!.description;
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _extractBarcodeFromImage(inputImage);
  }

  Future<void> _extractBarcodeFromImage(InputImage inputImage) async {
    if (!_canProcessBarcode) return;
    if (_isBusy) return;
    _isBusy = true;
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final painter =
          BarcodeDetectorPainter(barcodes, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);

      final barcodesString = barcodes.map((barcode) => barcode.displayValue).whereType<String>();
      for (final barcodeString in barcodesString) {
        _registeredBarcodes.update(barcodeString, (oldCount) => oldCount + 1, ifAbsent: () => 1);
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (file == null) {
        return;
      }
      if (mounted) {
        await getBundleDir.create();
        file.saveTo(_getFirstUnusedName(getBundleDir));
      }

      final inputImage = InputImage.fromFilePath(file.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      final barcodesString = barcodes.map((barcode) => barcode.displayValue).whereType<String>();
      for (final barcodeString in barcodesString) {
        _registeredBarcodes.update(barcodeString, (oldCount) => oldCount + minBarcodeOccurrence,
            ifAbsent: () => minBarcodeOccurrence);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  // TODO: padding so that lexical sorting correspond to numerical sorting
  // TODO: Don't look for the first unused number because if a picture is deleted, then the next picture to be taken will take its space which is weird
  // Instead store a increasing index or rename all the picture ofter the deleted one so that there is no gap in the numbering
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

  List<String> _getValidRegisteredBarcodes() {
    return _registeredBarcodes.entries
        .where((entry) => entry.key.startsWith(isbnPrefix) && entry.value >= minBarcodeOccurrence)
        .map((e) => e.key)
        .toList();
  }
}

class BottomWidget extends StatefulWidget {
  const BottomWidget({
    required this.bundle,
    required this.onSubmit,
    required this.onBarcodeDetectStart,
    required this.onBarcodeDetectStop,
    required this.isbns,
  });
  final Bundle bundle;
  final void Function() onSubmit;
  final void Function() onBarcodeDetectStart;
  final void Function() onBarcodeDetectStop;
  final List<String> isbns;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _thumbnailWidget(widget.bundle.images)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _barcodeDetectionButton(),
              _addMetadataButton(context: context, directory: widget.bundle.directory, onSubmit: widget.onSubmit),
            ],
          ),
        ],
      );
    } on PathNotFoundException {
      return const Text('Tap the screen to take a picture');
    }
  }

  Widget _barcodeDetectionButton() {
    return GestureDetector(
      onTapDown: (_) {
        widget.onBarcodeDetectStart();
      },
      onTapUp: (_) {
        widget.onBarcodeDetectStop();
      },
      child: AbsorbPointer(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.select_all_rounded),
          onPressed: () {},
          label: const Text('Live barcode detection'),
        ),
      ),
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget(Iterable<FileSystemEntity> images) {
    // FIXME: The drag from DraggableWidget and SingleChildScrollView might conflict with one another
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
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
    );
  }

  Widget _addMetadataButton(
          {required BuildContext context, required Directory directory, required void Function() onSubmit}) =>
      ElevatedButton.icon(
        label: const Text('Save'),
        icon: const Icon(Icons.save),
        onPressed: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) =>
                MetadataWidget(directory: directory, isbns: widget.isbns, onSubmit: onSubmit)),
      );
}

class MetadataWidget extends StatefulWidget {
  const MetadataWidget({
    required this.directory,
    required this.onSubmit,
    required this.isbns,
  });
  final Directory directory;
  final void Function() onSubmit;
  final List<String> isbns;

  @override
  State<MetadataWidget> createState() => _MetadataWidgetState();
}

class _MetadataWidgetState extends State<MetadataWidget> {
  late common.Metadata metadata;
  final additionalISBNController = TextEditingController();

  @override
  void initState() {
    super.initState();
    metadata = common.Metadata(isbns: widget.isbns);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add the final metadata'),
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
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
        TextFormField(
          controller: additionalISBNController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            icon: Icon(Icons.text_snippet),
            labelText: 'Additional ISBN, separated by space',
            labelStyle: TextStyle(fontSize: 10),
          ),
          style: const TextStyle(fontSize: 15),
        ),
        IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final managePerm = await Permission.manageExternalStorage.request();
              print('managePerm = $managePerm');
              if (additionalISBNController.text.isNotEmpty) {
                metadata.isbns!.addAll(additionalISBNController.text.split(' '));
              }
              File(path.join(widget.directory.path, 'metadata.json')).writeAsStringSync(jsonEncode(metadata.toJson()));
              widget.onSubmit();
            })
      ]
          .map((w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: w,
              ))
          .toList(),
    );
  }
}

List<CameraDescription> _cameras = <CameraDescription>[];
