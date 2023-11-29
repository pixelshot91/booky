import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:booky/common.dart';
import 'package:booky/isbn_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../ffi.dart';
import '../helpers.dart';
import 'barcode_detection.dart';
import 'camera_preview_widget.dart';
import 'draggable_widget.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({this.bundleDirToEdit});

  // Null means create a new bundle
  final Directory? bundleDirToEdit;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraDescription? cameraDescription;

  CameraController? _controller;

  late String bundleName;

  final Map<String, BarcodeDetection> _registeredBarcodes = {};

  // Used to signal when the imageProcessing pipeline finish processing the current frame
  Completer<void>? imageProcessingCompleter;

  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.ean13]);

  Future<Directory> get getBundleDir async =>
      widget.bundleDirToEdit ?? (await common.bookyDir()).getDir(BundleType.toPublish).joinDir(bundleName);

  Future<Bundle> get getBundle async => Bundle(await getBundleDir);

  void _generateNewFolderPath() {
    bundleName = common.nowAsFileName();
  }

  @override
  void initState() {
    super.initState();
    _generateNewFolderPath();

    Future(() async {
      try {
        // WidgetsFlutterBinding.ensureInitialized();
        final cameras = await availableCameras();
        cameraDescription = cameras.first;
        _onNewCameraSelected(cameraDescription!);
      } on CameraException catch (e) {
        _showCameraException(e);
      }
    });
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

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

  @override
  Widget build(BuildContext context) {
    Widget showBarcodeList() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: _getValidRegisteredBarcodes()
              .map((barcode) => BarcodeLabel(
                    barcode,
                    onDeletePressed: () => setState(() => _registeredBarcodes.remove(barcode)),
                  ))
              .toList(),
        ),
      );
    }

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
                      builder: (BuildContext _) => FutureWidget(
                        future: availableCameras(),
                        builder: (cameras) => SimpleDialog(
                            title: const Text('Select camera'),
                            children: cameras
                                .where((c) => c.lensDirection == CameraLensDirection.back)
                                .map((c) => SimpleDialogOption(
                                      onPressed: () => _onNewCameraSelected(c),
                                      child: Text('Camera ${c.name}'),
                                    ))
                                .toList()),
                      ),
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
                  child: showBarcodeList(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Center(
                      child: CameraPreviewWidget(
                        controller: _controller,
                        barcodeScanner: _barcodeScanner,
                        onImageTaken: (img.Image croppedImage) async {
                          await (await getBundleDir).create(recursive: true);
                          final firstUnusedImagePath = await _getFirstUnusedName(await getBundleDir);
                          final res = await img.encodeJpgFile(firstUnusedImagePath, croppedImage);
                          if (!res) {
                            print('error while saving cropped image');
                          }

                          final inputImage = InputImage.fromFilePath(firstUnusedImagePath);
                          final barcodes = await _barcodeScanner.processImage(inputImage);

                          _filterBarcode(barcodes).forEach((barcodeString) {
                            _registeredBarcodes
                                .update(barcodeString, (oldDetection) => oldDetection.makeSure(_onBarcodeDetected),
                                    ifAbsent: () {
                              _onBarcodeDetected();
                              return SureDetection();
                            });
                          });
                          setState(() {});
                        },
                        onBarcodeLiveDetected: (List<Barcode> barcodes) {
                          _filterBarcode(barcodes).forEach((barcodeString) {
                            _registeredBarcodes.update(
                                barcodeString, (oldDetection) => oldDetection.increaseCounter(_onBarcodeDetected),
                                ifAbsent: () => UnsureDetection());
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: FutureWidget(
                future: getBundle,
                builder: (bundle) => BottomWidget(
                  key: const ValueKey('BottomWidgetKey'),
                  bundle: bundle,
                  onSubmit: () {
                    /// The bundle has been edited, close pop-up and go back to BundleSelection
                    if (widget.bundleDirToEdit != null) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _generateNewFolderPath();
                        _registeredBarcodes.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  isbns: _getValidRegisteredBarcodes(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetected() {
    // Refresh the barcode list
    if (mounted) {
      setState(() {});
    }
    AudioPlayer().play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = _controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      _controller = null;
      await oldController.dispose();
    }
    final CameraController cameraController = CameraController(
      cameraDescription,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    _controller = cameraController;

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

  Iterable<String> _filterBarcode(Iterable<Barcode> barcodes) => barcodes
      .where((barcode) => barcode.type == BarcodeType.isbn)
      .map((barcode) => barcode.displayValue)
      .whereType<String>();

  Future<String> _getFirstUnusedName(Directory dir) async {
    final numberOfImages = (await (await getBundle).images).length;
    return _numberToImgPath((await getBundleDir), numberOfImages);
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<String> _getValidRegisteredBarcodes() => _registeredBarcodes.entries
      .where((entry) => isbnValidator(entry.key) == null && entry.value is SureDetection)
      .map((e) => e.key)
      .toList();
}

String _numberToImgPath(Directory bundlePath, int index) {
  // Add padding so that numerical and lexical sorting have the same output
  final paddedNumber = index.toString().padLeft(5, '0');
  return path.join(bundlePath.path, '$paddedNumber.jpg');
}

class BottomWidget extends StatefulWidget {
  const BottomWidget({
    required super.key,
    required this.bundle,
    required this.onSubmit,
    required this.isbns,
  });

  final Bundle bundle;
  final void Function() onSubmit;
  final List<String> isbns;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  @override
  void initState() {
    print('XXX _BottomWidgetState initState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: FutureWidget(future: () async {
          try {
            return await widget.bundle.images;
          } on PathNotFoundException {
            return null;
          }
        }(), builder: (images) {
          if (images == null) {
            return const Center(child: Text('Tap the camera preview to take a picture'));
          }
          return _thumbnailWidget(images);
        })),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _addMetadataButton(context: context, directory: widget.bundle.directory, onSubmit: widget.onSubmit),
          ],
        ),
      ],
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
                      onVerticalDrag: () async {
                        final deletedImageNumber = _pathToNumber(imgFile.path);
                        final images = await widget.bundle.images;
                        await imgFile.delete();
                        for (final img in images.skip(deletedImageNumber + 1)) {
                          final imgNumber = _pathToNumber(img.path);
                          final newPath = _numberToImgPath(Directory(path.dirname(img.path)), imgNumber - 1);
                          await img.safeRename(newPath);
                        }
                        for (final img in images.skip(deletedImageNumber)) {
                          // Clear the cache of all changed images (the one deleted and all the one after)
                          final evictRes = await FileImage(img).evict();
                          if (!evictRes && mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Error while trying to evict image ${img.path}')));
                          }
                        }

                        setState(() {});
                      }),
                ))
            .toList(),
      ),
    );
  }

  int _pathToNumber(String fullPath) {
    return int.parse(path.basenameWithoutExtension(fullPath));
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

class BarcodeLabel extends StatelessWidget {
  const BarcodeLabel(this.barcode, {required this.onDeletePressed});

  final String barcode;
  final void Function() onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(barcode, style: const TextStyle(fontWeight: FontWeight.bold))),
        IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete))
      ],
    );
  }
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
  late BundleMetaData metadata;
  final additionalISBNController = TextEditingController();

  @override
  void initState() {
    super.initState();
    metadata = BundleMetaData(
        books:
            widget.isbns.map((isbn) => BookMetaData(isbn: isbn, authors: [], keywords: [], priceCent: null)).toList());
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
        DropdownButton<ItemState>(
            hint: const Text('Book state'),
            value: metadata.itemState,
            items: ItemState.values.map((s) => DropdownMenuItem(value: s, child: Text(s.loc))).toList(),
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
              if (additionalISBNController.text.isNotEmpty) {
                metadata.books.addAll(additionalISBNController.text
                    .split(' ')
                    .map((isbn) => BookMetaData(isbn: isbn, authors: [], keywords: [], priceCent: null)));
              }
              try {
                await api.setManualMetadataForBundle(bundlePath: widget.directory.path, bundleMetadata: metadata);
              } on FfiException catch (e) {
                print('Error while saving metadata. e = $e');

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Error while saving metadata.'),
                  ));
                }
              }

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
