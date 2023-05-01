import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_rust_bridge_template/common.dart';
import 'package:path/path.dart' as path;

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Iterable<File> get images {
    return directory.listSync().whereType<File>().where((file) => path.extension(file.path) == '.jpg');
  }

  Directory get compressedImagesDir => Directory(path.join(directory.path, 'compressed'));

  Iterable<File> get compressedImages {
    return compressedImagesDir
        .listSync()
        .whereType<File>()
        .where((file) => path.extension(file.path) == '.jpg')
        .sorted((f1, f2) => path.basename(f1.path).compareTo(path.basename(f2.path)));
  }

  Metadata get metadata {
    final metadataFile = File(path.join(directory.path, 'metadata.json'));
    return Metadata.fromJson(jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>);
  }
}
