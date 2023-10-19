import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:booky/common.dart';
import 'package:booky/image_helper.dart';
import 'package:booky/isbn_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../ffi.dart';
import '../helpers.dart';
import 'barcode_detection.dart';
import 'barcode_detector_painter.dart';
import 'draggable_widget.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({this.bundleDirToEdit});

  // Null means create a new bundle
  final Directory? bundleDirToEdit;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  late String bundleName;

  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.ean13]);
  bool _isBusy = false;
  bool _canProcess = true;
  CustomPaint? _customPaint;
  final Map<String, BarcodeDetection> _registeredBarcodes = {};

  // Used to signal when the imageProcessing pipeline finish processing the current frame
  Completer<void>? imageProcessingCompleter;

  // 0 means no crop
  // toward 1 the image become thinner in width
  // toward -1 the image become shorter in height
  double _cropValue = 0;

  // Prevent from cropping more than 80% of the image
  static const double maxCropRatio = 0.8;

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
    _canProcess = false;
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
                      children: _getValidRegisteredBarcodes()
                          .map((barcode) => Row(
                                children: [
                                  Expanded(child: Text(barcode, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                      onPressed: () => setState(() => _registeredBarcodes.remove(barcode)),
                                      icon: const Icon(Icons.delete))
                                ],
                              ))
                          .toList(),
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
              child: FutureWidget(
                future: getBundle,
                builder: (bundle) => BottomWidget(
                  bundle: bundle,
                  onSubmit: () {
                    /// The bundle has been edited, go back to BundleSelection
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
                  onBarcodeDetectStart: () => _controller!.startImageStream(_processCameraImage),
                  onBarcodeDetectStop: () async {
                    print('XXX onBarcodeDetectStop');
                    // controller!.addListener(_listener);
                    await _controller!.stopImageStream();
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

  // Even if we await the stopImageStream, there might still be an instance f _processCameraImage processing a frame
  // So _listener is called until the streaming stops, and the last frame has been processed
  // Only then should we remove the _customPaint
  void _listener() async {
    // No new frame are added into the pipeline
    if (_controller!.value.isStreamingImages == false) {
      _controller!.removeListener(_listener);

      if (_isBusy) {
        imageProcessingCompleter = Completer();
        // The current frame is finished processing
        await imageProcessingCompleter!.future;
        imageProcessingCompleter = null;
      }
      /*if (mounted) {
        setState(() {
          _customPaint = null;
        });
      }*/
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = _controller;

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
        child: Column(
          children: [
            Expanded(
              child: CameraPreview(
                cameraController,
                child: LayoutBuilder(
                  builder: (context, boxConstraints) => GestureDetector(
                    onTapDown: (TapDownDetails details) async {
                      print('TapDownDetails');
                      _onViewFinderTap(details, boxConstraints);
                      // The auto focus is not instantaneous. We must wait a little while before taking the picture
                      // In release mode, if we
                      // wait 100 ms : blurry
                      // wait 300 ms : sharp
                      // The optimum delay shall lie between the bounds
                      await Future<void>.delayed(const Duration(milliseconds: 300));
                      _onTakePictureButtonPressed();
                    },
                    child: AbsorbPointer(
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          _viewFinderCropIndicator(),
                          if (_customPaint != null) _customPaint!,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        trackShape: const CenteredTrackShape(),
                        thumbColor: _cropValue == 0 ? Colors.blue.shade200 : Colors.blue),
                    child: Slider(
                        min: -maxCropRatio,
                        max: maxCropRatio,
                        value: _cropValue,
                        onChanged: (newValue) => setState(() => _cropValue = newValue)),
                  ),
                ),
                IconButton(
                    tooltip: 'Use full frame',
                    onPressed: _cropValue == 0 ? null : () => setState(() => _cropValue = 0),
                    icon: const Icon(Icons.undo)),
              ],
            ),
          ],
        ),
      );
    }
  }

  // <-- croppedFraction / 2 --> | <-- AOI (Area of Interest) --> | <-- croppedFraction / 2 -->
  Widget _viewFinderCropIndicator() {
    // flex factor is an int, so multiply all flex value by this amount to emulate double
    const intToDouble = 1000;

    final disabledColor = Colors.grey.withOpacity(0.6);
    final croppedFraction = _cropValue.abs();
    // ignore: non_constant_identifier_names
    final AOIFraction = (1 - croppedFraction);

    final croppedFlex = croppedFraction * intToDouble;
    // ignore: non_constant_identifier_names
    final AOIFlex = (AOIFraction * intToDouble).toInt();
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      direction: _cropValue > 0 ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(
            flex: croppedFlex ~/ 2,
            child: ColoredBox(
              color: disabledColor,
            )),
        Expanded(flex: AOIFlex, child: const SizedBox.shrink()),
        Expanded(
            flex: croppedFlex ~/ 2,
            child: ColoredBox(
              color: disabledColor,
            )),
      ],
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) {
      return;
    }

    final CameraController cameraController = _controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
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
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      // If the imageFormatGroup is specified, the stream processing does not work anymore
      // It seems that the default format for still picture is jpeg, bu the default format for streaming is not
      // imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    // If the controller is updated then update the UI.
/*    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });*/

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
    print('XXX _processCameraImage BEGIN');
    /*final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());

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

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);*/
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _processImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    print(
        'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final _orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    print('_processImage BEGIN');
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    /*setState(() {
      _text = '';
    });*/
    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        CameraLensDirection.back,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      // _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

/*
  Future<void> _processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    if (_canProcessBarcode) {
      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
        final painter =
            BarcodeDetectorPainter(barcodes, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
        _customPaint = CustomPaint(painter: painter);

        _filterBarcode(barcodes).forEach((barcodeString) {
          _registeredBarcodes.update(barcodeString, (oldDetection) => oldDetection.increaseCounter(),
              ifAbsent: () => UnsureDetection());
        });
      }
    }
    if (mounted) {
      setState(() {});
    }
    imageProcessingCompleter?.complete();

    _isBusy = false;
  }
*/

  Iterable<String> _filterBarcode(Iterable<Barcode> barcodes) => barcodes
      .where((barcode) => barcode.type == BarcodeType.isbn)
      .map((barcode) => barcode.displayValue)
      .whereType<String>();

  void _onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (file == null) {
        return;
      }

      AudioPlayer().play(AssetSource('sounds/take_picture.mp3'), mode: PlayerMode.lowLatency);

      await (await getBundleDir).create(recursive: true);
      final firstUnusedImagePath = await _getFirstUnusedName(await getBundleDir);

      if (_cropValue != 0) {
        final croppedImage = await crop(file, _cropValue);
        final res = await img.encodeJpgFile(firstUnusedImagePath, croppedImage);
        if (!res) {
          print('error while saving cropped image');
        }
      } else {
        file.saveTo(firstUnusedImagePath);
      }

      final inputImage = InputImage.fromFilePath(file.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      _filterBarcode(barcodes).forEach((barcodeString) {
        _registeredBarcodes.update(barcodeString, (oldDetection) => oldDetection.makeSure(),
            ifAbsent: () => SureDetection());
      });

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<String> _getFirstUnusedName(Directory dir) async {
    final numberOfImages = (await (await getBundle).images).length;
    return _numberToImgPath((await getBundleDir), numberOfImages);
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (_controller != null) {
        final CameraController cameraController = _controller!;
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
    final CameraController? cameraController = _controller;
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

  List<String> _getValidRegisteredBarcodes() => _registeredBarcodes.entries
      .where((entry) => isbnValidator(entry.key) == null && entry.value is SureDetection)
      .map((e) => e.key)
      .toList();

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }
}

class CenteredTrackShape extends RoundedRectSliderTrackShape {
  const CenteredTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween =
        ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
        ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, activeTrackRadius),
      inactivePaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.center.dx,
        trackRect.top,
        thumbCenter.dx,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      activePaint,
    );
  }
}

String _numberToImgPath(Directory bundlePath, int index) {
  // Add padding so that numerical and lexical sorting have the same output
  final paddedNumber = index.toString().padLeft(5, '0');
  return path.join(bundlePath.path, '$paddedNumber.jpg');
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
            _barcodeDetectionButton(),
            _addMetadataButton(context: context, directory: widget.bundle.directory, onSubmit: widget.onSubmit),
          ],
        ),
      ],
    );
  }

  Widget _barcodeDetectionButton() {
    return GestureDetector(
      onTapDown: (_) => widget.onBarcodeDetectStart(),
      onTapUp: (_) => widget.onBarcodeDetectStop(),
      onTapCancel: () => widget.onBarcodeDetectStop(),
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

List<CameraDescription> _cameras = <CameraDescription>[];
