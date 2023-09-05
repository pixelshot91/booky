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

class BookyDir {
  BookyDir(this.root);

  Directory root;

  // Contain the bundle create by the Camera
  Directory get toPublish => root.joinDir('to_publish');

  // Contain bundle after they have been published at the end of AdEditing
  Directory get published => root.joinDir('published');

  // Contain bundles that have been deleted
  Directory get deleted => root.joinDir('deleted');
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
  return Future(() => BookyDir(
      Directory('/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/DCIM/booky/')));
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
/*
enum ItemState {
  brandNew,
  veryGood,
  good,
  medium;

  String get loc {
    switch (this) {
      case ItemState.brandNew:
        return 'Brand New';
      case ItemState.veryGood:
        return 'Very Good';
      case ItemState.good:
        return 'Good';
      case ItemState.medium:
        return 'Medium';
    }
  }
}

@JsonSerializable()
class BundleMetadata {
  BundleMetadata({this.weightGrams, this.itemState, this.books});

  int? weightGrams;
  ItemState? itemState;

  List<BookMetaDataManual>? books;

  factory BundleMetadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}

@JsonSerializable()
class BookMetaDataManual {
  String isbn;
  String? title;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Author> authors;
  String? blurb;
  List<String> keywords;
  int? priceCent;

  BookMetaDataManual({
    required this.isbn,
    this.title,
    required this.authors,
    this.blurb,
    required this.keywords,
    required this.priceCent,
  });

  BookMetaDataManual.fromIsbn({required this.isbn})
      : title = null,
        authors = [],
        keywords = [];

  factory BookMetaDataManual.fromJson(Map<String, dynamic> json) => _$BookMetaDataManualFromJson(json);

  Map<String, dynamic> toJson() => _$BookMetaDataManualToJson(this);
}*/
