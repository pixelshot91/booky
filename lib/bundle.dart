import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:path/path.dart' as path;
import 'package:stream_transform/stream_transform.dart';

import '../ffi.dart';
import 'common.dart' as common;

Future<File?> testCompressAndGetFile(File file, String targetPath) async {
  await Directory(path.dirname(targetPath)).create();
  return await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minHeight: 200,
    minWidth: 200,
    quality: 90,
  );
}

class MultiResImage {
  MultiResImage({required this.fullScale});

  File fullScale;

  File get compressed {
    final segments = path.split(fullScale.path);
    segments.insert(segments.length - 1, 'compressed');
    return File(path.joinAll(segments));
  }
}

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Future<List<MultiResImage>> get images async {
    final fullScaleImgFiles = await directory.listImages();
    return fullScaleImgFiles.map((img) => MultiResImage(fullScale: img)).toList();
  }

  Directory get compressedImagesDir => Directory(path.join(directory.path, 'compressed'));

  File get metadataFile => File(path.join(directory.path, 'metadata.json'));

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

  File get autoMetadataFile => File(path.join(directory.path, 'automatic_metadata.json'));

  // Return the best information either manually submitted, manually verified, or automatically, for every book of the bundle
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
