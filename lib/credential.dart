import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'credential.g.dart';

@JsonSerializable()
class Credential {
  String lbcToken;
  String dataDomeCookie;

  Credential({required this.lbcToken, required this.dataDomeCookie});

  static final _file = File('credential.json');

  void saveToFile() {
    _file.writeAsStringSync(jsonEncode(toJson()));
  }

  factory Credential.loadFromFile() {
    final json = _file.readAsStringSync();
    return Credential.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  factory Credential.fromJson(Map<String, dynamic> json) => _$CredentialFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialToJson(this);
}
