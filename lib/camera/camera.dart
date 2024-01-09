import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:booky/common.dart';
import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:booky/utils/debounce.dart';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as img_lib;

import '../bundle.dart';
import '../common.dart' as common;
import '../helpers.dart';
import '../isbn_helper.dart';
import 'barcode_detection.dart';
import 'camera_preview_widget.dart';
import 'draggable_widget.dart';

sealed class CameraMode {}

class EditOneBundle implements CameraMode {
  EditOneBundle(this.bundleDirToEdit);

  final Directory bundleDirToEdit;
}

class ShootMultipleBundle implements CameraMode {
  ShootMultipleBundle(this.repo);

  /// Where to create new bundles
  final common.BookyRepo repo;
}

class CameraWidgetInit extends StatefulWidget {
  const CameraWidgetInit(this.cameraMode);

  final CameraMode cameraMode;

  @override
  State<CameraWidgetInit> createState() => _CameraWidgetInitState();
}

class _CameraWidgetInitState extends State<CameraWidgetInit> {
  Directory _getBundleDir() {
    final cameraMode = widget.cameraMode;
    switch (cameraMode) {
      case EditOneBundle():
        return cameraMode.bundleDirToEdit;
      case ShootMultipleBundle():
        final bundleName = common.nowAsFileName();
        return cameraMode.repo.getDir(BundleType.toPublish).joinDir(bundleName);
    }
  }

  late final Bundle bundle = Bundle(_getBundleDir());

  late Future<rust.BundleMetaData> metadata = bundle.getManualMetadata();

  @override
  Widget build(BuildContext context) {
    return FutureWidget(
        future: metadata,
        builder: (metadata) {
          return CameraWidget(
            bundle: bundle,
            initialWeight: metadata.weightGrams,
            initialItemState: metadata.itemState,
            initialBarcodes:
                metadata.books.map((b) => MapEntry<String, BarcodeDetection>(b.isbn, SureDetection())).toMap(),
          );
        });
  }
}

class CameraWidget extends StatefulWidget {
  const CameraWidget(
      {required this.bundle,
      required this.initialWeight,
      required this.initialItemState,
      required this.initialBarcodes});

  final Bundle bundle;
  final int? initialWeight;
  final rust.ItemState? initialItemState;
  final Map<String, BarcodeDetection> initialBarcodes;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraDescription? cameraDescription;

  CameraController? _controller;

  late int? weightGrams = widget.initialWeight;
  late rust.ItemState? itemState = widget.initialItemState;

  late final Map<String, BarcodeDetection> _registeredBarcodes = widget.initialBarcodes;

  // Used to signal when the imageProcessing pipeline finish processing the current frame
  Completer<void>? imageProcessingCompleter;

  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.ean13]);

  final Debouncer saveFormDebouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();

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
    _controller?.dispose();
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
        child: Column(children: [
          TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9X]{0,13}')),
              ],
              autovalidateMode: AutovalidateMode.always,
              validator: (s) => isbnValidator(s!),
              decoration: const InputDecoration(hintText: 'Type manually the ISBN here'),
              onFieldSubmitted: (newIsbn) {
                setState(() {
                  _registeredBarcodes.update(newIsbn, (oldDetection) => oldDetection.makeSure(() {}), ifAbsent: () {
                    return SureDetection();
                  });
                });
              }),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  children: _getValidRegisteredBarcodes()
                      .map((barcode) => BarcodeLabel(
                            barcode,
                            onDeletePressed: () => setState(() => _registeredBarcodes.remove(barcode)),
                          ))
                      .toList()),
            ),
          ),
        ]),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        onImageTaken: (img_lib.Image imageTaken) async {
                          final fullScaleImageFile = await widget.bundle.appendNewImage(imageTaken);
                          final inputImage = InputImage.fromFilePath(fullScaleImageFile.fullScale.path);
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
          Expanded(child: _buildImageThumbnails()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                initialValue: weightGrams?.toString() ?? '',
                onChanged: (newText) {
                  setState(() => weightGrams = int.parse(newText));
                  _debouncedSaveMetadata();
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.scale),
                  labelText: 'Weight in grams',
                ),
              ),
              DropdownButtonFormField<rust.ItemState>(
                decoration: const InputDecoration(icon: Icon(Icons.diamond), labelText: 'Book state'),
                value: itemState,
                items: rust.ItemState.values.map((s) => DropdownMenuItem(value: s, child: Text(s.loc))).toList(),
                onChanged: (state) {
                  setState(() {
                    itemState = state;
                  });
                  _debouncedSaveMetadata();
                },
              ),
            ]
                .map((w) => Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: w,
                    )))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnails() {
    return FutureWidget(future: () async {
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
    });
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget(Iterable<MultiResImage> images) {
    // FIXME: The drag from DraggableWidget and SingleChildScrollView might conflict with one another
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: images
            .map((image) => SizedBox(
                  width: 64,
                  height: 64,
                  child: DraggableWidget(
                      // Use a key otherwise if we delete an image, the image that will take its place will inherit the state of the deleted image
                      key: ValueKey(image.fullScale.path),
                      child: Image.file(File(image.thumbnail.path)),
                      onVerticalDrag: () async {
                        final res = await widget.bundle.deleteImage(image);
                        if (!res && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Error while saving image'),
                          ));
                          return;
                        }
                        setState(() {});
                      }),
                ))
            .toList(),
      ),
    );
  }

  void _debouncedSaveMetadata() {
    saveFormDebouncer(() async {
      try {
        final manualMd = await widget.bundle.getManualMetadata();
        final newISBNs = _getValidRegisteredBarcodes();

        /// Remove ISBNs that were deleted
        manualMd.books.removeWhere((book) => newISBNs.contains(book.isbn) == false);

        /// Add new ISBNs
        newISBNs.whereNot((newISBN) => manualMd.books.any((book) => book.isbn == newISBN)).forEach((newISBN) {
          manualMd.books.add(rust.BookMetaData(isbn: newISBN, authors: [], keywords: [], priceCent: null));
        });

        manualMd.weightGrams = weightGrams;
        manualMd.itemState = itemState;

        await rust.setManualMetadataForBundle(bundlePath: widget.bundle.directory.path, bundleMetadata: manualMd);
      } on PanicException catch (e) {
        print('Error while saving metadata. e = $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error while saving metadata.'),
          ));
        }
      }
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(title: const Text('Edit Bundle'), actions: [
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
    ]);
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
      .whereNotNull()
      .where((isbn) => isbnValidator(isbn) == null);

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

  List<String> _getValidRegisteredBarcodes() {
    return _registeredBarcodes.entries.where((entry) => entry.value is SureDetection).map((e) => e.key).toList();
  }
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
  late rust.BundleMetaData metadata;
  final additionalISBNController = TextEditingController();

  @override
  void initState() {
    super.initState();
    metadata = rust.BundleMetaData(
        books: widget.isbns
            .map((isbn) => rust.BookMetaData(isbn: isbn, authors: [], keywords: [], priceCent: null))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add the final metadata'),
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
      children: [
        IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (additionalISBNController.text.isNotEmpty) {
                metadata.books.addAll(additionalISBNController.text
                    .split(' ')
                    .map((isbn) => rust.BookMetaData(isbn: isbn, authors: [], keywords: [], priceCent: null)));
              }
              try {
                await rust.setManualMetadataForBundle(bundlePath: widget.directory.path, bundleMetadata: metadata);
              } on PanicException catch (e) {
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
