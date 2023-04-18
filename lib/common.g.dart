// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      weightGrams: json['weightGrams'] as int?,
      itemState: $enumDecodeNullable(_$ItemStateEnumMap, json['itemState']),
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'weightGrams': instance.weightGrams,
      'itemState': _$ItemStateEnumMap[instance.itemState],
    };

const _$ItemStateEnumMap = {
  ItemState.brandNew: 'brandNew',
  ItemState.veryGood: 'veryGood',
  ItemState.good: 'good',
  ItemState.medium: 'medium',
};
