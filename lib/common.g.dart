// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BundleMetadata _$MetadataFromJson(Map<String, dynamic> json) => BundleMetadata(
      weightGrams: json['weightGrams'] as int?,
      itemState: $enumDecodeNullable(_$ItemStateEnumMap, json['itemState']),
    )..books = (json['isbns'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$MetadataToJson(BundleMetadata instance) => <String, dynamic>{
      'weightGrams': instance.weightGrams,
      'itemState': _$ItemStateEnumMap[instance.itemState],
      'isbns': instance.books,
    };

const _$ItemStateEnumMap = {
  ItemState.brandNew: 'brandNew',
  ItemState.veryGood: 'veryGood',
  ItemState.good: 'good',
  ItemState.medium: 'medium',
};
