// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.68.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import 'dart:ffi' as ffi;

class NativeImpl implements Native {
  final NativePlatform _platform;
  factory NativeImpl(ExternalLibrary dylib) =>
      NativeImpl.raw(NativePlatform(dylib));

  /// Only valid on web/WASM platforms.
  factory NativeImpl.wasm(FutureOr<WasmModule> module) =>
      NativeImpl(module as ExternalLibrary);
  NativeImpl.raw(this._platform);
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

  Future<bool> publishAd(
      {required Ad ad, required LbcCredential credential, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_ad(ad);
    var arg1 = _platform.api2wire_box_autoadd_lbc_credential(credential);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_publish_ad(port_, arg0, arg1),
      parseSuccessData: _wire2api_bool,
      constMeta: kPublishAdConstMeta,
      argValues: [ad, credential],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kPublishAdConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "publish_ad",
        argNames: ["ad", "credential"],
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

  bool _wire2api_bool(dynamic raw) {
    return raw as bool;
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

  List<Author> _wire2api_list_author(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_author).toList();
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

  int _wire2api_u8(dynamic raw) {
    return raw as int;
  }

  Uint8List _wire2api_uint_8_list(dynamic raw) {
    return raw as Uint8List;
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

class NativePlatform extends FlutterRustBridgeBase<NativeWire> {
  NativePlatform(ffi.DynamicLibrary dylib) : super(NativeWire(dylib));

// Section: api2wire

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_String(String raw) {
    return api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  @protected
  ffi.Pointer<wire_StringList> api2wire_StringList(List<String> raw) {
    final ans = inner.new_StringList_0(raw.length);
    for (var i = 0; i < raw.length; i++) {
      ans.ref.ptr[i] = api2wire_String(raw[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_Ad> api2wire_box_autoadd_ad(Ad raw) {
    final ptr = inner.new_box_autoadd_ad_0();
    _api_fill_to_wire_ad(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_LbcCredential> api2wire_box_autoadd_lbc_credential(
      LbcCredential raw) {
    final ptr = inner.new_box_autoadd_lbc_credential_0();
    _api_fill_to_wire_lbc_credential(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }
// Section: finalizer

// Section: api_fill_to_wire

  void _api_fill_to_wire_ad(Ad apiObj, wire_Ad wireObj) {
    wireObj.title = api2wire_String(apiObj.title);
    wireObj.description = api2wire_String(apiObj.description);
    wireObj.price_cent = api2wire_i32(apiObj.priceCent);
    wireObj.imgs_path = api2wire_StringList(apiObj.imgsPath);
  }

  void _api_fill_to_wire_box_autoadd_ad(
      Ad apiObj, ffi.Pointer<wire_Ad> wireObj) {
    _api_fill_to_wire_ad(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_box_autoadd_lbc_credential(
      LbcCredential apiObj, ffi.Pointer<wire_LbcCredential> wireObj) {
    _api_fill_to_wire_lbc_credential(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_lbc_credential(
      LbcCredential apiObj, wire_LbcCredential wireObj) {
    wireObj.lbc_token = api2wire_String(apiObj.lbcToken);
    wireObj.datadome_cookie = api2wire_String(apiObj.datadomeCookie);
  }
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// generated by flutter_rust_bridge
class NativeWire implements FlutterRustBridgeWireBase {
  @internal
  late final dartApi = DartApiDl(init_frb_dart_api_dl);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();

  Object get_dart_object(
    int ptr,
  ) {
    return _get_dart_object(
      ptr,
    );
  }

  late final _get_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Handle Function(ffi.UintPtr)>>(
          'get_dart_object');
  late final _get_dart_object =
      _get_dart_objectPtr.asFunction<Object Function(int)>();

  void drop_dart_object(
    int ptr,
  ) {
    return _drop_dart_object(
      ptr,
    );
  }

  late final _drop_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>(
          'drop_dart_object');
  late final _drop_dart_object =
      _drop_dart_objectPtr.asFunction<void Function(int)>();

  int new_dart_opaque(
    Object handle,
  ) {
    return _new_dart_opaque(
      handle,
    );
  }

  late final _new_dart_opaquePtr =
      _lookup<ffi.NativeFunction<ffi.UintPtr Function(ffi.Handle)>>(
          'new_dart_opaque');
  late final _new_dart_opaque =
      _new_dart_opaquePtr.asFunction<int Function(Object)>();

  int init_frb_dart_api_dl(
    ffi.Pointer<ffi.Void> obj,
  ) {
    return _init_frb_dart_api_dl(
      obj,
    );
  }

  late final _init_frb_dart_api_dlPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'init_frb_dart_api_dl');
  late final _init_frb_dart_api_dl = _init_frb_dart_api_dlPtr
      .asFunction<int Function(ffi.Pointer<ffi.Void>)>();

  void wire_get_metadata_from_provider(
    int port_,
    int provider,
    ffi.Pointer<wire_uint_8_list> isbn,
  ) {
    return _wire_get_metadata_from_provider(
      port_,
      provider,
      isbn,
    );
  }

  late final _wire_get_metadata_from_providerPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64, ffi.Int32, ffi.Pointer<wire_uint_8_list>)>>(
      'wire_get_metadata_from_provider');
  late final _wire_get_metadata_from_provider =
      _wire_get_metadata_from_providerPtr
          .asFunction<void Function(int, int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_publish_ad(
    int port_,
    ffi.Pointer<wire_Ad> ad,
    ffi.Pointer<wire_LbcCredential> credential,
  ) {
    return _wire_publish_ad(
      port_,
      ad,
      credential,
    );
  }

  late final _wire_publish_adPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_Ad>,
              ffi.Pointer<wire_LbcCredential>)>>('wire_publish_ad');
  late final _wire_publish_ad = _wire_publish_adPtr.asFunction<
      void Function(
          int, ffi.Pointer<wire_Ad>, ffi.Pointer<wire_LbcCredential>)>();

  ffi.Pointer<wire_StringList> new_StringList_0(
    int len,
  ) {
    return _new_StringList_0(
      len,
    );
  }

  late final _new_StringList_0Ptr = _lookup<
          ffi.NativeFunction<ffi.Pointer<wire_StringList> Function(ffi.Int32)>>(
      'new_StringList_0');
  late final _new_StringList_0 = _new_StringList_0Ptr
      .asFunction<ffi.Pointer<wire_StringList> Function(int)>();

  ffi.Pointer<wire_Ad> new_box_autoadd_ad_0() {
    return _new_box_autoadd_ad_0();
  }

  late final _new_box_autoadd_ad_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_Ad> Function()>>(
          'new_box_autoadd_ad_0');
  late final _new_box_autoadd_ad_0 =
      _new_box_autoadd_ad_0Ptr.asFunction<ffi.Pointer<wire_Ad> Function()>();

  ffi.Pointer<wire_LbcCredential> new_box_autoadd_lbc_credential_0() {
    return _new_box_autoadd_lbc_credential_0();
  }

  late final _new_box_autoadd_lbc_credential_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_LbcCredential> Function()>>(
          'new_box_autoadd_lbc_credential_0');
  late final _new_box_autoadd_lbc_credential_0 =
      _new_box_autoadd_lbc_credential_0Ptr
          .asFunction<ffi.Pointer<wire_LbcCredential> Function()>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_uint_8_list> Function(
              ffi.Int32)>>('new_uint_8_list_0');
  late final _new_uint_8_list_0 = _new_uint_8_list_0Ptr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturn(
    WireSyncReturn ptr,
  ) {
    return _free_WireSyncReturn(
      ptr,
    );
  }

  late final _free_WireSyncReturnPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturn)>>(
          'free_WireSyncReturn');
  late final _free_WireSyncReturn =
      _free_WireSyncReturnPtr.asFunction<void Function(WireSyncReturn)>();
}

class _Dart_Handle extends ffi.Opaque {}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

class wire_StringList extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<wire_uint_8_list>> ptr;

  @ffi.Int32()
  external int len;
}

class wire_Ad extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> title;

  external ffi.Pointer<wire_uint_8_list> description;

  @ffi.Int32()
  external int price_cent;

  external ffi.Pointer<wire_StringList> imgs_path;
}

class wire_LbcCredential extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> lbc_token;

  external ffi.Pointer<wire_uint_8_list> datadome_cookie;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<ffi.Bool Function(DartPort, ffi.Pointer<ffi.Void>)>>;
typedef DartPort = ffi.Int64;
