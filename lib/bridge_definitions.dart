// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.68.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'dart:async';
import 'dart:convert';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:meta/meta.dart';

abstract class Native {
  Future<Ad> getMetadataFromImages({required List<String> imgsPath, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromImagesConstMeta;

  Future<void> publishAd({required Ad ad, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kPublishAdConstMeta;
}

class Ad {
  String title;
  String description;
  int priceCent;
  List<String> imgsPath;

  Ad({
    required this.title,
    required this.description,
    required this.priceCent,
    required this.imgsPath,
  });
}
