import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

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

final bookyDir = Platform.isAndroid
    ? Directory('/storage/emulated/0/DCIM/booky/')
    : Directory('/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/DCIM/booky/');

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
class Metadata {
  Metadata({this.weightGrams, this.itemState, this.isbns});
  int? weightGrams;
  ItemState? itemState;
  List<String>? isbns;

  factory Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}
