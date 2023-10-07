import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:path/path.dart' as path;
import 'package:stream_transform/stream_transform.dart';

import '../ffi.dart';
import 'common.dart' as common;

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Future<List<File>> get images => directory.listImages();

  Directory get compressedImagesDir => Directory(path.join(directory.path, 'compressed'));

  Future<Iterable<File>> get compressedImages => compressedImagesDir.listImages();

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
    final destinationName = path.basename(autoMetadataFile.path) + '_backup_' + common.nowAsFileName();
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
