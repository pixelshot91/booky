import 'dart:io';

import 'package:booky/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:image/image.dart' as img_lib;
import 'package:path/path.dart' as path;
import 'package:stream_transform/stream_transform.dart';

import '../ffi.dart';
import 'common.dart' as common;

const _exportDirName = 'to_export';
const _thumbnailDirName = 'thumbnail';

class MultiResImage {
  MultiResImage({required this.fullScale});

  File fullScale;

  /// Images that will be uploaded and published. Compressed to upload them faster and LBC compressed them anyway
  /// Should not compress it more than LBC
  /// About 800x800 pixels
  File get imageToExport {
    final segments = path.split(fullScale.path);
    segments.insert(segments.length - 1, _exportDirName);
    return File(path.joinAll(segments));
  }

  Future<void> compressToImageToExport() async {
    await Directory(path.dirname(imageToExport.path)).create(recursive: true);
    final compressedRes = await FlutterImageCompress.compressAndGetFile(
      fullScale.path,
      imageToExport.path,
      minHeight: 800,
      minWidth: 800,
    );
    if (compressedRes == null) {
      print('error while saving compressToImageToExport');
    }
  }

  /// Used for performance improvement, especially when viewing many picture on a computer connected to the phone
  /// About 100x100 pixels
  File get thumbnail {
    final segments = path.split(fullScale.path);
    segments.insert(segments.length - 1, _thumbnailDirName);
    return File(path.joinAll(segments));
  }

  Future<void> compressToThumbnail() async {
    await Directory(path.dirname(thumbnail.path)).create(recursive: true);
    final compressedRes = await FlutterImageCompress.compressAndGetFile(
      fullScale.path,
      thumbnail.path,
      minHeight: 200,
      minWidth: 200,
      quality: 80,
    );

    if (compressedRes == null) {
      print('error while saving compressToThumbnail');
    }
  }
}

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Future<List<MultiResImage>> get images async {
    final fullScaleImgFiles = await directory.listImages();
    return fullScaleImgFiles.map((img) => MultiResImage(fullScale: img)).toList();
  }

  Directory get imagesToExportDir => directory.joinDir(_exportDirName);

  Directory get thumbnailImagesDir => directory.joinDir(_thumbnailDirName);

  String _numberToImageFileName(int index) {
    // Add padding so that numerical and lexical sorting have the same output
    return index.toString().padLeft(5, '0') + '.jpg';
  }

  int _pathToNumber(String fullPath) {
    return int.parse(path.basenameWithoutExtension(fullPath));
  }

  /// Save the new image, and create the thumbnail
  Future<MultiResImage> appendNewImage(img_lib.Image imageTaken) async {
    await directory.create(recursive: true);
    final numberOfImages = (await images).length;

    final fullScaleImageFile = directory.joinFile(_numberToImageFileName(numberOfImages));
    final multiResImg = MultiResImage(fullScale: fullScaleImageFile);

    final fullScaleRes = await img_lib.encodeJpgFile(fullScaleImageFile.path, imageTaken);
    if (!fullScaleRes) {
      print('error while saving full scale image');
    }

    multiResImg.compressToThumbnail();
    multiResImg.compressToImageToExport();

    return multiResImg;
  }

  Future<bool> deleteImage(MultiResImage image) async {
    final imageNumberToDelete = _pathToNumber(image.fullScale.path);
    final images = await this.images;

    if (images[imageNumberToDelete].fullScale.path != image.fullScale.path) {
      print(
          'image path is ${image.fullScale.path}, so imageNumberToDelete = $imageNumberToDelete, but the images at index imageNumberToDelete is ${images[imageNumberToDelete].fullScale.path}. Not deleting anything');
      return false;
    }

    Future<void> removeImageAndDecreaseNumberOfFollowingImages(Iterable<File> imgs, int imageNumberToDelete) async {
      await imgs.elementAt(imageNumberToDelete).delete();
      // rename all the following images so they all have consecutive number
      await Future.forEach(imgs.skip(imageNumberToDelete + 1), (File f) async {
        final imgNumber = _pathToNumber(f.path);
        final newPath = f.parent.joinFile(_numberToImageFileName(imgNumber - 1));
        await f.safeRename(newPath.path);
      });
      // Clear the cache of all changed images (the one deleted and all the one after)
      await Future.wait(imgs.skip(imageNumberToDelete).map((img) => FileImage(img).evict()));
    }

    await Future.wait([
      removeImageAndDecreaseNumberOfFollowingImages(images.map((img) => img.fullScale), imageNumberToDelete),
      removeImageAndDecreaseNumberOfFollowingImages(images.map((img) => img.thumbnail), imageNumberToDelete)
    ]);

    return true;
  }

  File get metadataFile => directory.joinFile('metadata.json');

  Future<bool> overwriteMetadata(BundleMetaData md) async {
    try {
      api.setManualMetadataForBundle(bundlePath: directory.path, bundleMetadata: md);
      return true;
    } on FfiException {
      return false;
    }
  }

  Future<bool> removeAutoMetadata() async {
    if (!await autoMetadataFile.exists()) {
      print('Nothing to do');
      return true;
    }
    final destinationName =
        path.withoutExtension(autoMetadataFile.path) + '_backup_' + common.nowAsFileName() + '.json';
    await File(autoMetadataFile.path).rename(destinationName);
    return true;
  }

  File get autoMetadataFile => directory.joinFile('automatic_metadata.json');

  /// Return the best information either manually submitted, manually verified, or automatically, for every book of the bundle
  Future<BundleMetaData?> getMergedMetadata() async {
    try {
      return await api.getMergedMetadataForBundle(bundlePath: directory.path);
    } on FfiException catch (e) {
      print('getMergedMetadata. FfiException. e = $e');
      return null;
    }
  }

  Future<BundleMetaData> getManualMetadata() async {
    return api.getManualMetadataForBundle(bundlePath: directory.path);
  }
}

extension _DirExt on Directory {
  Future<List<File>> listImages() =>
      list().whereType<File>().where((file) => path.extension(file.path) == '.jpg').sortByName();
}

extension _ListFileExt on Stream<File> {
  Future<List<File>> sortByName() async =>
      (await toList()).sorted((f1, f2) => path.basename(f1.path).compareTo(path.basename(f2.path)));
}
