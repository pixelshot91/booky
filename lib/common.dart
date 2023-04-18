// TODO: merge with same file in camera_app

import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

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
  Metadata({this.weightGrams, this.itemState});
  int? weightGrams;
  ItemState? itemState;

  factory Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}
