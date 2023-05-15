import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_rust_bridge_template/common.dart';
import 'package:flutter_rust_bridge_template/helpers.dart';
import 'package:path/path.dart' as path;

import 'bridge_definitions.dart';

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Iterable<File> get images => directory.listImages();

  Directory get compressedImagesDir => Directory(path.join(directory.path, 'compressed'));

  Iterable<File> get compressedImages => compressedImagesDir.listImages();

  Metadata get metadata {
    final metadataFile = File(path.join(directory.path, 'metadata.json'));
    return Metadata.fromJson(jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>);
  }

  File get autoMetadataFile => File(path.join(directory.path, 'automatic_metadata.json'));
}

extension ListProviderMetadataPairExt on List<ProviderMetadataPair> {
  @Deprecated('Use MapProviderEnumBookMetaDataFromProviderExt')
  List<double> getPrices() =>
      map((e) => e.metadata?.marketPrice.toList()).whereNotNull().expand((i) => i).toList()..sort();

  @Deprecated('Use MapProviderEnumBookMetaDataFromProviderExt')
  BookMetaDataFromProvider mergeAllProvider() {
    return BookMetaDataFromProvider(
        title: map((e) => e.metadata?.title)
            .whereNotNull()
            .fold(null, (best, s) => s.length > (best?.length ?? 0) ? s : best),
        authors: [],
        keywords: [],
        marketPrice: Float32List.fromList(getPrices()));
  }
}

extension MapProviderEnumBookMetaDataFromProviderExt on Map<ProviderEnum, BookMetaDataFromProvider?> {
  List<double> getPrices() =>
      values.map((e) => e?.marketPrice.toList()).whereNotNull().expand((i) => i).toList()..sort();
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
  Iterable<File> listImages() =>
      listSync().whereType<File>().where((file) => path.extension(file.path) == '.jpg').sortByName();
}

extension _ListFileExt on Iterable<File> {
  List<File> sortByName() => sorted((f1, f2) => path.basename(f1.path).compareTo(path.basename(f2.path)));
}
