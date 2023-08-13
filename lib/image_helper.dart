/// From https://github.com/brendan-duncan/image/blob/main/doc/flutter.md
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

Future<img.Image> crop(XFile sourceImage, double cropValue) async {
  final img.Image image = (await img.decodeJpgFile(sourceImage.path))!;

  final croppedFraction = cropValue.abs();

  // ignore: non_constant_identifier_names
  final AOIFraction = (1 - croppedFraction);

  if (cropValue > 0) {
    return img.copyCrop(image,
        x: (croppedFraction / 2 * image.width).toInt(),
        y: 0,
        width: (AOIFraction * image.width).toInt(),
        height: image.height);
  } else {
    return img.copyCrop(image,
        x: 0,
        y: (croppedFraction / 2 * image.height).toInt(),
        width: image.width,
        height: (AOIFraction * image.height).toInt());
  }
}

Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

  final ui.ImageDescriptor id =
      ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);

  final ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);

  final ui.FrameInfo fi = await codec.getNextFrame();
  final ui.Image uiImage = fi.image;

  return uiImage;
}
