// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
      lbcToken: json['lbcToken'] as String,
      dataDomeCookie: json['dataDomeCookie'] as String,
    );

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      'lbcToken': instance.lbcToken,
      'dataDomeCookie': instance.dataDomeCookie,
    };
