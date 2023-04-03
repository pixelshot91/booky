// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.68.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

abstract class Native {
  Future<BookMetaData?> getMetadataFromProvider(
      {required ProviderEnum provider, required String isbn, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromProviderConstMeta;

  Future<bool> publishAd(
      {required Ad ad, required LbcCredential credential, dynamic hint});

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

class Author {
  final String firstName;
  final String lastName;

  const Author({
    required this.firstName,
    required this.lastName,
  });
}

class BookMetaData {
  String? title;
  List<Author> authors;
  String? blurb;
  List<String> keywords;
  Float32List marketPrice;

  BookMetaData({
    this.title,
    required this.authors,
    this.blurb,
    required this.keywords,
    required this.marketPrice,
  });
}

class LbcCredential {
  String lbcToken;
  String datadomeCookie;

  LbcCredential({
    required this.lbcToken,
    required this.datadomeCookie,
  });
}

enum ProviderEnum {
  Babelio,
  GoogleBooks,
  BooksPrice,
}
