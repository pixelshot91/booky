import 'dart:io';

import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:path/path.dart' as path;

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

class BookyRepo {
  BookyRepo(this.root);

  Directory root;

  Directory getDir(BundleType bundleType) => root.joinDir(bundleType.getDirName);
}

extension DirectoryExt on Directory {
  Directory joinDir(String d) => Directory(path.join(this.path, d));

  File joinFile(String f) => File(path.join(this.path, f));
}

final externalDeviceRepo = Directory('/media/phone/storage/emulated/0/Android/data/fr.pimoid.booky/files');
// final externalDeviceRepo = Directory('/home/julien/Perso/LeBonCoin/chain_automatisation/booky/extra/mock_data/basic/');

extension ItemStateExt on rust.ItemState {
  String get loc {
    switch (this) {
      case rust.ItemState.brandNew:
        return 'Brand New';
      case rust.ItemState.veryGood:
        return 'Very Good';
      case rust.ItemState.good:
        return 'Good';
      case rust.ItemState.medium:
        return 'Medium';
    }
  }
}
