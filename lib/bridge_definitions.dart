// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.81.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';

abstract class Native {
  Future<BarcodeDetectResults> detectBarcodeInImage(
      {required String imgPath, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDetectBarcodeInImageConstMeta;

  Future<void> getMetadataFromIsbns(
      {required List<String> isbns, required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromIsbnsConstMeta;

  Future<List<ISBNMetadataPair>> getAutoMetadataFromBundle(
      {required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetAutoMetadataFromBundleConstMeta;

  Future<BookMetaDataFromProvider?> getMetadataFromProvider(
      {required ProviderEnum provider, required String isbn, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromProviderConstMeta;

  Future<bool> publishAd(
      {required Ad ad, required LbcCredential credential, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kPublishAdConstMeta;
}

class Ad {
  final String title;
  final String description;
  final int priceCent;
  final int weightGrams;
  final List<String> imgsPath;

  const Ad({
    required this.title,
    required this.description,
    required this.priceCent,
    required this.weightGrams,
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

class BarcodeDetectResult {
  final String value;
  final List<Point> corners;

  const BarcodeDetectResult({
    required this.value,
    required this.corners,
  });
}

class BarcodeDetectResults {
  final List<BarcodeDetectResult> results;

  const BarcodeDetectResults({
    required this.results,
  });
}

class BookMetaDataFromProvider {
  final String? title;
  final List<Author> authors;
  final String? blurb;
  final List<String> keywords;
  final Float32List marketPrice;

  const BookMetaDataFromProvider({
    this.title,
    required this.authors,
    this.blurb,
    required this.keywords,
    required this.marketPrice,
  });
}

class ISBNMetadataPair {
  final String isbn;
  final List<ProviderMetadataPair> metadatas;

  const ISBNMetadataPair({
    required this.isbn,
    required this.metadatas,
  });
}

class LbcCredential {
  final String lbcToken;
  final String datadomeCookie;

  const LbcCredential({
    required this.lbcToken,
    required this.datadomeCookie,
  });
}

class Point {
  final int x;
  final int y;

  const Point({
    required this.x,
    required this.y,
  });
}

enum ProviderEnum {
  Babelio,
  GoogleBooks,
  BooksPrice,
  AbeBooks,
  LesLibraires,
  JustBooks,
}

class ProviderMetadataPair {
  final ProviderEnum provider;
  final BookMetaDataFromProvider? metadata;

  const ProviderMetadataPair({
    required this.provider,
    this.metadata,
  });
}
