import 'dart:io';

import 'package:booky/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

/// All ISBN (EAN-13) should start with 978
/// Use to prevent false barcode decoding
const isbnPrefix = '978';

extension IterableFutureMapEntryExt<K, V> on Iterable<Future<MapEntry<K, V>>> {
  Future<Map<K, V>> toMap() async => Map.fromEntries(await Future.wait(this));
}

String nowAsFileName() => DateTime.now().toIso8601String().replaceAll(':', '_');

Future<bool> launchCommandLine(String executable, List<String> arguments) async {
  final res = await Process.run(executable, arguments);
  if (res.exitCode != 0) {
    print('Error when launching executable $executable with arguments $arguments');
    print('stdout is ${res.stdout}');
    print('stderr is ${res.stderr}');
    return false;
  }
  return true;
}

enum BundleType {
  // Contain the bundle create by the Camera
  toPublish,
  // Contain bundle after they have been published at the end of AdEditing
  published,
  // Contain bundles that have been deleted
  deleted,
}

extension BundleTypeExt on BundleType {
  String get getDirName {
    switch (this) {
      case BundleType.toPublish:
        return 'to_publish';
      case BundleType.published:
        return 'published';
      case BundleType.deleted:
        return 'deleted';
    }
  }
}

class BookyDir {
  BookyDir(this.root);

  Directory root;

  Directory getDir(BundleType bundleType) => root.joinDir(bundleType.getDirName);
}

extension DirectoryExt on Directory {
  Directory joinDir(String d) => Directory(path.join(this.path, d));

  File joinFile(String f) => File(path.join(this.path, f));
}

Future<BookyDir> bookyDir() async {
  if (Platform.isAndroid) {
    final extDir = (await path_provider.getExternalStorageDirectory())!;
    return BookyDir(extDir);
  }

  return Future(() => BookyDir(Directory(
      '/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/Android/data/fr.pimoid.booky/files')));
  return Future(
      () => BookyDir(Directory('/home/julien/Perso/LeBonCoin/chain_automatisation/saved_folder/after_migration')));
}

extension ItemStateExt on ItemState {
  String get loc {
    switch (this) {
      case ItemState.BrandNew:
        return 'Brand New';
      case ItemState.VeryGood:
        return 'Very Good';
      case ItemState.Good:
        return 'Good';
      case ItemState.Medium:
        return 'Medium';
    }
  }
}
