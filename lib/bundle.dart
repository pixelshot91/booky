import 'dart:convert';
import 'dart:io';

import 'package:flutter_rust_bridge_template/common.dart';
import 'package:path/path.dart' as path;

class Bundle {
  Bundle(this.directory);

  final Directory directory;

  Iterable<File> get images {
    return directory.listSync().whereType<File>().where((file) => path.extension(file.path) == '.jpg');
  }

  Metadata get metadata {
    final metadataFile = File(path.join(directory.path, 'metadata.json'));
    return Metadata.fromJson(jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>);
  }
}
