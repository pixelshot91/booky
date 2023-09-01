import 'dart:convert';
import 'dart:io';

import 'package:booky/common.dart';
import 'package:booky/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:kt_dart/collection.dart';
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

  Metadata get metadata {
    try {
      return Metadata.fromJson(jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>);
    } on PathNotFoundException {
      return Metadata();
    }
  }

  Future<bool> overwriteMetadata(Metadata md) async {
    final tmpFile = File('tmp.json');

    try {
      await tmpFile.writeAsString(jsonEncode(md.toJson()));
    } on FileSystemException catch (e) {
      print(e);
      return false;
    }

    return common.launchCommandLine('gio', ['move', tmpFile.path, metadataFile.path]);
  }

  Future<bool> removeAutoMetadata() async {
    if (!await autoMetadataFile.exists()) {
      print('Nothing to do');
      return true;
    }
    final destinationName = path.basename(autoMetadataFile.path) + '_backup_' + common.nowAsFileName();

    return common.launchCommandLine('gio', ['rename', autoMetadataFile.path, destinationName]);
  }

  File get autoMetadataFile => File(path.join(directory.path, 'automatic_metadata.json'));

  Future<KtMutableMap<String, KtMutableMap<ProviderEnum, BookMetaDataFromProvider?>>> getAutoMetadata() async {
    try {
      final value = await api.getAutoMetadataFromBundle(path: autoMetadataFile.path);
      return Map
          .fromEntries(value.map((e) {
        final providerMdMap = Map
            .fromEntries(e.metadatas.map((e) => MapEntry(e.provider, e.metadata)))
            .kt;
        return MapEntry(e.isbn, providerMdMap);
      }))
          .kt;
    } on FfiException {
      return KtMutableMap.empty();
    }
  }

/*Metadata getMergedMetadata() {

  }*/
}

extension MapProviderEnumBookMetaDataFromProviderExt on Map<ProviderEnum, BookMetaDataFromProvider?> {
  List<double> getPrices() =>
      values.map((e) => e?.marketPrice.toList()).whereNotNull().expand((i) => i).toList()
        ..sort();

  BookMetaDataFromProvider mergeAllProvider() {
    return BookMetaDataFromProvider(
        title: entries.map((e) => e.value?.title).whereNotNull().biggest(),
        authors: values.whereNotNull().map((md) => md.authors).biggest(),
        blurb: values.map((e) => e?.blurb).whereNotNull().biggest(),
        keywords: values.whereNotNull().map((e) => e.keywords).expand((e) => e).toList(),
        marketPrice: Float32List.fromList(getPrices()));
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
