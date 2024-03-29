import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as img;

import '../helpers.dart';
import '../image_helper.dart';
import 'barcode_detector_painter.dart';
import 'barcode_live_detection_button.dart';
import 'centered_track_shape.dart';

/// Display the preview from the camera (or a message if the preview is not available).
class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    required this.controller,
    required this.onImageTaken,
    required this.barcodeScanner,
    required this.onBarcodeLiveDetected,
  });

  final CameraController? controller;
  final BarcodeScanner barcodeScanner;

  /// The image that was just taken
  /// Potentially cropped, if the user change the crop slider
  final void Function(img.Image imageTaken) onImageTaken;
  final void Function(List<Barcode> barcodes) onBarcodeLiveDetected;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  // 0 means no crop
  // toward 1 the image become thinner in width
  // toward -1 the image become shorter in height
  double _cropValue = 0;

  // Prevent from cropping more than 80% of the image
  static const double maxCropRatio = 0.8;

  bool _isBusy = false;
  bool _canProcess = true;
  CustomPaint? _customPaint;

  double _exposureOffset = 0;

  @override
  void dispose() {
    _canProcess = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = widget.controller;

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
                    onTapDown: (TapDownDetails details) async => _onViewFinderTap(details, boxConstraints),
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
                    icon: const Icon(Icons.fullscreen)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        trackShape: const CenteredTrackShape(),
                        thumbColor: _exposureOffset == 0 ? Colors.blue.shade200 : Colors.blue),
                    child: Slider(
                        min: -1.0,
                        max: 1.0,
                        value: _exposureOffset,
                        onChanged: (newValue) async {
                          setState(() => _exposureOffset = newValue);

                          final minExposure = await cameraController.getMinExposureOffset();
                          final maxExposure = await cameraController.getMaxExposureOffset();

                          final remapExposure = remap(_exposureOffset, -1.0, 1.0, minExposure, maxExposure);
                          await cameraController.setExposureOffset(remapExposure);
                        }),
                  ),
                ),
                IconButton(
                    tooltip: 'Reset exposure',
                    onPressed: _exposureOffset == 0
                        ? null
                        : () {
                            cameraController.setExposureOffset(0);
                            setState(() => _exposureOffset = 0);
                          },
                    icon: const Icon(Icons.brightness_auto)),
              ],
            ),
            BarcodeLiveDetectionButton(
              onBarcodeDetectStart: () {
                print('BarcodeLiveDetectionButton onBarcodeDetectStart');
                widget.controller!.startImageStream(_processCameraImage);
              },
              onBarcodeDetectStop: () async {
                print('CameraWidget onBarcodeDetectStop');
                await widget.controller!.stopImageStream();
                // Wait a bit otherwise the `_processImage` maybe be called after `_customPaint = null;`, thus leaving the customPaint visible
                // TODO: find a cleaner and faster way to remove the customPaint
                await Future<void>.delayed(const Duration(seconds: 1));
                setState(() {
                  _customPaint = null;
                });
              },
            ),
          ],
        ),
      );
    }
  }

  double remap(double value, double oldMin, double oldMax, double newMin, double newMax) {
    final normalizedValue = (value - oldMin) / (oldMax - oldMin);
    return normalizedValue * (newMax - newMin) + newMin;
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) async {
    final CameraController? cameraController = widget.controller;
    if (cameraController == null) {
      return;
    }

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);

    // The auto focus is not instantaneous. We must wait a little while before taking the picture
    // In release mode, if we
    // wait 100 ms : blurry
    // wait 300 ms : sharp
    // The optimum delay shall lie between the bounds
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _takePicture(cameraController).then((XFile? file) async {
      if (file == null) {
        return;
      }

      AudioPlayer().play(AssetSource('sounds/take_picture.mp3'), mode: PlayerMode.lowLatency);
      final image = await maybeCrop(file);
      widget.onImageTaken(image);
    });
  }

  Future<img.Image> maybeCrop(XFile file) async {
    if (_cropValue != 0) {
      return crop(file, _cropValue);
    } else {
      return (await img.decodeJpgFile(file.path))!;
    }
  }

  Future<XFile?> _takePicture(CameraController cameraController) async {
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      if (mounted) {
        showCameraException(context, e);
      }
      return null;
    }
  }

  // <-- croppedFraction / 2 --> | <-- AOI (Area of Interest) --> | <-- croppedFraction / 2 -->
  Widget _viewFinderCropIndicator() {
    // Easy case, prevent the drawing of border
    if (_cropValue == 0.0) {
      return const SizedBox.shrink();
    }

    // flex factor is an int, so multiply all flex value by this amount to emulate double
    const intToDouble = 1000;

    final disabledColor = Colors.grey.withOpacity(0.6);
    final croppedFraction = _cropValue.abs();
    // ignore: non_constant_identifier_names
    final AOIFraction = (1 - croppedFraction);

    final croppedFlex = croppedFraction * intToDouble;
    // ignore: non_constant_identifier_names
    final AOIFlex = (AOIFraction * intToDouble).toInt();

    final direction = _cropValue > 0 ? Axis.horizontal : Axis.vertical;
    final firstBorder = switch (direction) {
      Axis.horizontal => const Border(right: BorderSide()),
      Axis.vertical => const Border(bottom: BorderSide()),
    };
    final secondBorder = switch (direction) {
      Axis.horizontal => const Border(left: BorderSide()),
      Axis.vertical => const Border(top: BorderSide()),
    };

    return Flex(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      direction: direction,
      children: [
        Expanded(
            flex: croppedFlex ~/ 2,
            child: Container(
              decoration: BoxDecoration(color: disabledColor, border: firstBorder),
            )),
        Expanded(flex: AOIFlex, child: const SizedBox.shrink()),
        Expanded(
            flex: croppedFlex ~/ 2,
            child: Container(
              decoration: BoxDecoration(color: disabledColor, border: secondBorder),
            )),
      ],
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _processImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = widget.controller;
    if (controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;
/*    print(
        'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${controller.value.deviceOrientation} ${controller.value.lockedCaptureOrientation} ${controller.value.isCaptureOrientationLocked}');*/
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      var rotationCompensation = orientations[controller.value.deviceOrientation];
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
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final barcodes = await widget.barcodeScanner.processImage(inputImage);

    widget.onBarcodeLiveDetected(barcodes);

    final inputImageMetadata = inputImage.metadata!;

    final painter = BarcodeDetectorPainter(
      barcodes,
      inputImageMetadata.size,
      inputImageMetadata.rotation,
      CameraLensDirection.back,
    );
    _customPaint = CustomPaint(painter: painter);
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
