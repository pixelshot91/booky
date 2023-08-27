// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.81.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';

class NativeImpl implements Native {
  final NativePlatform _platform;
  factory NativeImpl(ExternalLibrary dylib) =>
      NativeImpl.raw(NativePlatform(dylib));

  /// Only valid on web/WASM platforms.
  factory NativeImpl.wasm(FutureOr<WasmModule> module) =>
      NativeImpl(module as ExternalLibrary);
  NativeImpl.raw(this._platform);
  Future<BarcodeDetectResults> detectBarcodeInImage(
      {required String imgPath, dynamic hint}) {
    var arg0 = _platform.api2wire_String(imgPath);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_detect_barcode_in_image(port_, arg0),
      parseSuccessData: _wire2api_barcode_detect_results,
      constMeta: kDetectBarcodeInImageConstMeta,
      argValues: [imgPath],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kDetectBarcodeInImageConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "detect_barcode_in_image",
        argNames: ["imgPath"],
      );

  Future<void> getMetadataFromIsbns(
      {required List<String> isbns, required String path, dynamic hint}) {
    var arg0 = _platform.api2wire_StringList(isbns);
    var arg1 = _platform.api2wire_String(path);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_get_metadata_from_isbns(port_, arg0, arg1),
      parseSuccessData: _wire2api_unit,
      constMeta: kGetMetadataFromIsbnsConstMeta,
      argValues: [isbns, path],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromIsbnsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_metadata_from_isbns",
        argNames: ["isbns", "path"],
      );

  Future<List<ISBNMetadataPair>> getAutoMetadataFromBundle(
      {required String path, dynamic hint}) {
    var arg0 = _platform.api2wire_String(path);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_get_auto_metadata_from_bundle(port_, arg0),
      parseSuccessData: _wire2api_list_isbn_metadata_pair,
      constMeta: kGetAutoMetadataFromBundleConstMeta,
      argValues: [path],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetAutoMetadataFromBundleConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_auto_metadata_from_bundle",
        argNames: ["path"],
      );

  Future<BookMetaDataFromProvider?> getMetadataFromProvider(
      {required ProviderEnum provider, required String isbn, dynamic hint}) {
    var arg0 = api2wire_provider_enum(provider);
    var arg1 = _platform.api2wire_String(isbn);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_get_metadata_from_provider(port_, arg0, arg1),
      parseSuccessData: _wire2api_opt_box_autoadd_book_meta_data_from_provider,
      constMeta: kGetMetadataFromProviderConstMeta,
      argValues: [provider, isbn],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetMetadataFromProviderConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_metadata_from_provider",
        argNames: ["provider", "isbn"],
      );

  void dispose() {
    _platform.dispose();
  }
// Section: wire2api

  String _wire2api_String(dynamic raw) {
    return raw as String;
  }

  List<String> _wire2api_StringList(dynamic raw) {
    return (raw as List<dynamic>).cast<String>();
  }

  Author _wire2api_author(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return Author(
      firstName: _wire2api_String(arr[0]),
      lastName: _wire2api_String(arr[1]),
    );
  }

  BarcodeDetectResult _wire2api_barcode_detect_result(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return BarcodeDetectResult(
      value: _wire2api_String(arr[0]),
      corners: _wire2api_list_point(arr[1]),
    );
  }

  BarcodeDetectResults _wire2api_barcode_detect_results(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 1)
      throw Exception('unexpected arr length: expect 1 but see ${arr.length}');
    return BarcodeDetectResults(
      results: _wire2api_list_barcode_detect_result(arr[0]),
    );
  }

  BookMetaDataFromProvider _wire2api_book_meta_data_from_provider(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return BookMetaDataFromProvider(
      title: _wire2api_opt_String(arr[0]),
      authors: _wire2api_list_author(arr[1]),
      blurb: _wire2api_opt_String(arr[2]),
      keywords: _wire2api_StringList(arr[3]),
      marketPrice: _wire2api_float_32_list(arr[4]),
    );
  }

  BookMetaDataFromProvider _wire2api_box_autoadd_book_meta_data_from_provider(
      dynamic raw) {
    return _wire2api_book_meta_data_from_provider(raw);
  }

  double _wire2api_f32(dynamic raw) {
    return raw as double;
  }

  Float32List _wire2api_float_32_list(dynamic raw) {
    return raw as Float32List;
  }

  int _wire2api_i32(dynamic raw) {
    return raw as int;
  }

  ISBNMetadataPair _wire2api_isbn_metadata_pair(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return ISBNMetadataPair(
      isbn: _wire2api_String(arr[0]),
      metadatas: _wire2api_list_provider_metadata_pair(arr[1]),
    );
  }

  List<Author> _wire2api_list_author(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_author).toList();
  }

  List<BarcodeDetectResult> _wire2api_list_barcode_detect_result(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_barcode_detect_result).toList();
  }

  List<ISBNMetadataPair> _wire2api_list_isbn_metadata_pair(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_isbn_metadata_pair).toList();
  }

  List<Point> _wire2api_list_point(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_point).toList();
  }

  List<ProviderMetadataPair> _wire2api_list_provider_metadata_pair(
      dynamic raw) {
    return (raw as List<dynamic>)
        .map(_wire2api_provider_metadata_pair)
        .toList();
  }

  String? _wire2api_opt_String(dynamic raw) {
    return raw == null ? null : _wire2api_String(raw);
  }

  BookMetaDataFromProvider?
      _wire2api_opt_box_autoadd_book_meta_data_from_provider(dynamic raw) {
    return raw == null
        ? null
        : _wire2api_box_autoadd_book_meta_data_from_provider(raw);
  }

  Point _wire2api_point(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return Point(
      x: _wire2api_u16(arr[0]),
      y: _wire2api_u16(arr[1]),
    );
  }

  ProviderEnum _wire2api_provider_enum(dynamic raw) {
    return ProviderEnum.values[raw as int];
  }

  ProviderMetadataPair _wire2api_provider_metadata_pair(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return ProviderMetadataPair(
      provider: _wire2api_provider_enum(arr[0]),
      metadata: _wire2api_opt_box_autoadd_book_meta_data_from_provider(arr[1]),
    );
  }

  int _wire2api_u16(dynamic raw) {
    return raw as int;
  }

  int _wire2api_u8(dynamic raw) {
    return raw as int;
  }

  Uint8List _wire2api_uint_8_list(dynamic raw) {
    return raw as Uint8List;
  }

  void _wire2api_unit(dynamic raw) {
    return;
  }
}

// Section: api2wire

@protected
int api2wire_i32(int raw) {
  return raw;
}

@protected
int api2wire_provider_enum(ProviderEnum raw) {
  return api2wire_i32(raw.index);
}

@protected
int api2wire_u8(int raw) {
  return raw;
}

// Section: finalizer
