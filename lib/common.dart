import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

extension IterableFutureMapEntryExt<K, V> on Iterable<Future<MapEntry<K, V>>> {
  Future<Map<K, V>> toMap() async => Map.fromEntries(await Future.wait(this));
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

Future<List<String>> extractIsbnsFromImage(File image) {
  return Future(() async {
    final decoderProcess = await Process.run(
        '/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode', ['-in=' + image.path]);
    if (decoderProcess.exitCode != 0) {
      print('stdout is ${decoderProcess.stdout}');
      print('stderr is ${decoderProcess.stderr}');
      throw Exception('decoder status is ${decoderProcess.exitCode}');
    }
    final s = decoderProcess.stdout as String;
    return s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  });
}
