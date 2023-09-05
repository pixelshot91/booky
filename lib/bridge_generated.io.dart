// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.81.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'bridge_generated.dart';
export 'bridge_generated.dart';
import 'dart:ffi' as ffi;

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
  ffi.Pointer<wire_BundleMetaData> api2wire_box_autoadd_bundle_meta_data(
      BundleMetaData raw) {
    final ptr = inner.new_box_autoadd_bundle_meta_data_0();
    _api_fill_to_wire_bundle_meta_data(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<ffi.Int32> api2wire_box_autoadd_i32(int raw) {
    return inner.new_box_autoadd_i32_0(api2wire_i32(raw));
  }

  @protected
  ffi.Pointer<ffi.Int32> api2wire_box_autoadd_item_state(ItemState raw) {
    return inner.new_box_autoadd_item_state_0(api2wire_item_state(raw));
  }

  @protected
  ffi.Pointer<wire_list_author> api2wire_list_author(List<Author> raw) {
    final ans = inner.new_list_author_0(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      _api_fill_to_wire_author(raw[i], ans.ref.ptr[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_list_book_meta_data> api2wire_list_book_meta_data(
      List<BookMetaData> raw) {
    final ans = inner.new_list_book_meta_data_0(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      _api_fill_to_wire_book_meta_data(raw[i], ans.ref.ptr[i]);
    }
    return ans;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_opt_String(String? raw) {
    return raw == null ? ffi.nullptr : api2wire_String(raw);
  }

  @protected
  ffi.Pointer<ffi.Int32> api2wire_opt_box_autoadd_i32(int? raw) {
    return raw == null ? ffi.nullptr : api2wire_box_autoadd_i32(raw);
  }

  @protected
  ffi.Pointer<ffi.Int32> api2wire_opt_box_autoadd_item_state(ItemState? raw) {
    return raw == null ? ffi.nullptr : api2wire_box_autoadd_item_state(raw);
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }
// Section: finalizer

// Section: api_fill_to_wire

  void _api_fill_to_wire_author(Author apiObj, wire_Author wireObj) {
    wireObj.first_name = api2wire_String(apiObj.firstName);
    wireObj.last_name = api2wire_String(apiObj.lastName);
  }

  void _api_fill_to_wire_book_meta_data(
      BookMetaData apiObj, wire_BookMetaData wireObj) {
    wireObj.isbn = api2wire_String(apiObj.isbn);
    wireObj.title = api2wire_opt_String(apiObj.title);
    wireObj.authors = api2wire_list_author(apiObj.authors);
    wireObj.blurb = api2wire_opt_String(apiObj.blurb);
    wireObj.keywords = api2wire_StringList(apiObj.keywords);
    wireObj.price_cent = api2wire_opt_box_autoadd_i32(apiObj.priceCent);
  }

  void _api_fill_to_wire_box_autoadd_bundle_meta_data(
      BundleMetaData apiObj, ffi.Pointer<wire_BundleMetaData> wireObj) {
    _api_fill_to_wire_bundle_meta_data(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_bundle_meta_data(
      BundleMetaData apiObj, wire_BundleMetaData wireObj) {
    wireObj.weight_grams = api2wire_opt_box_autoadd_i32(apiObj.weightGrams);
    wireObj.item_state = api2wire_opt_box_autoadd_item_state(apiObj.itemState);
    wireObj.books = api2wire_list_book_meta_data(apiObj.books);
  }
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint

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

  void wire_detect_barcode_in_image(
    int port_,
    ffi.Pointer<wire_uint_8_list> img_path,
  ) {
    return _wire_detect_barcode_in_image(
      port_,
      img_path,
    );
  }

  late final _wire_detect_barcode_in_imagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64,
              ffi.Pointer<wire_uint_8_list>)>>('wire_detect_barcode_in_image');
  late final _wire_detect_barcode_in_image = _wire_detect_barcode_in_imagePtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_metadata_from_isbns(
    int port_,
    ffi.Pointer<wire_StringList> isbns,
    ffi.Pointer<wire_uint_8_list> path,
  ) {
    return _wire_get_metadata_from_isbns(
      port_,
      isbns,
      path,
    );
  }

  late final _wire_get_metadata_from_isbnsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_StringList>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_get_metadata_from_isbns');
  late final _wire_get_metadata_from_isbns =
      _wire_get_metadata_from_isbnsPtr.asFunction<
          void Function(int, ffi.Pointer<wire_StringList>,
              ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_auto_metadata_from_bundle(
    int port_,
    ffi.Pointer<wire_uint_8_list> path,
  ) {
    return _wire_get_auto_metadata_from_bundle(
      port_,
      path,
    );
  }

  late final _wire_get_auto_metadata_from_bundlePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>(
      'wire_get_auto_metadata_from_bundle');
  late final _wire_get_auto_metadata_from_bundle =
      _wire_get_auto_metadata_from_bundlePtr
          .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_manual_metadata_for_bundle(
    int port_,
    ffi.Pointer<wire_uint_8_list> bundle_path,
  ) {
    return _wire_get_manual_metadata_for_bundle(
      port_,
      bundle_path,
    );
  }

  late final _wire_get_manual_metadata_for_bundlePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>(
      'wire_get_manual_metadata_for_bundle');
  late final _wire_get_manual_metadata_for_bundle =
      _wire_get_manual_metadata_for_bundlePtr
          .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_set_merged_metadata_for_bundle(
    int port_,
    ffi.Pointer<wire_uint_8_list> bundle_path,
    ffi.Pointer<wire_BundleMetaData> bundle_metadata,
  ) {
    return _wire_set_merged_metadata_for_bundle(
      port_,
      bundle_path,
      bundle_metadata,
    );
  }

  late final _wire_set_merged_metadata_for_bundlePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>,
                  ffi.Pointer<wire_BundleMetaData>)>>(
      'wire_set_merged_metadata_for_bundle');
  late final _wire_set_merged_metadata_for_bundle =
      _wire_set_merged_metadata_for_bundlePtr.asFunction<
          void Function(int, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_BundleMetaData>)>();

  void wire_get_merged_metadata_for_bundle(
    int port_,
    ffi.Pointer<wire_uint_8_list> bundle_path,
  ) {
    return _wire_get_merged_metadata_for_bundle(
      port_,
      bundle_path,
    );
  }

  late final _wire_get_merged_metadata_for_bundlePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>(
      'wire_get_merged_metadata_for_bundle');
  late final _wire_get_merged_metadata_for_bundle =
      _wire_get_merged_metadata_for_bundlePtr
          .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

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

  ffi.Pointer<wire_BundleMetaData> new_box_autoadd_bundle_meta_data_0() {
    return _new_box_autoadd_bundle_meta_data_0();
  }

  late final _new_box_autoadd_bundle_meta_data_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_BundleMetaData> Function()>>(
          'new_box_autoadd_bundle_meta_data_0');
  late final _new_box_autoadd_bundle_meta_data_0 =
      _new_box_autoadd_bundle_meta_data_0Ptr
          .asFunction<ffi.Pointer<wire_BundleMetaData> Function()>();

  ffi.Pointer<ffi.Int32> new_box_autoadd_i32_0(
    int value,
  ) {
    return _new_box_autoadd_i32_0(
      value,
    );
  }

  late final _new_box_autoadd_i32_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function(ffi.Int32)>>(
          'new_box_autoadd_i32_0');
  late final _new_box_autoadd_i32_0 = _new_box_autoadd_i32_0Ptr
      .asFunction<ffi.Pointer<ffi.Int32> Function(int)>();

  ffi.Pointer<ffi.Int32> new_box_autoadd_item_state_0(
    int value,
  ) {
    return _new_box_autoadd_item_state_0(
      value,
    );
  }

  late final _new_box_autoadd_item_state_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function(ffi.Int32)>>(
          'new_box_autoadd_item_state_0');
  late final _new_box_autoadd_item_state_0 = _new_box_autoadd_item_state_0Ptr
      .asFunction<ffi.Pointer<ffi.Int32> Function(int)>();

  ffi.Pointer<wire_list_author> new_list_author_0(
    int len,
  ) {
    return _new_list_author_0(
      len,
    );
  }

  late final _new_list_author_0Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<wire_list_author> Function(ffi.Int32)>>(
      'new_list_author_0');
  late final _new_list_author_0 = _new_list_author_0Ptr
      .asFunction<ffi.Pointer<wire_list_author> Function(int)>();

  ffi.Pointer<wire_list_book_meta_data> new_list_book_meta_data_0(
    int len,
  ) {
    return _new_list_book_meta_data_0(
      len,
    );
  }

  late final _new_list_book_meta_data_0Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_list_book_meta_data> Function(
              ffi.Int32)>>('new_list_book_meta_data_0');
  late final _new_list_book_meta_data_0 = _new_list_book_meta_data_0Ptr
      .asFunction<ffi.Pointer<wire_list_book_meta_data> Function(int)>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<wire_uint_8_list> Function(ffi.Int32)>>(
      'new_uint_8_list_0');
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

final class _Dart_Handle extends ffi.Opaque {}

final class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_StringList extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<wire_uint_8_list>> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_Author extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> first_name;

  external ffi.Pointer<wire_uint_8_list> last_name;
}

final class wire_list_author extends ffi.Struct {
  external ffi.Pointer<wire_Author> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_BookMetaData extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> isbn;

  external ffi.Pointer<wire_uint_8_list> title;

  external ffi.Pointer<wire_list_author> authors;

  external ffi.Pointer<wire_uint_8_list> blurb;

  external ffi.Pointer<wire_StringList> keywords;

  external ffi.Pointer<ffi.Int32> price_cent;
}

final class wire_list_book_meta_data extends ffi.Struct {
  external ffi.Pointer<wire_BookMetaData> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_BundleMetaData extends ffi.Struct {
  external ffi.Pointer<ffi.Int32> weight_grams;

  external ffi.Pointer<ffi.Int32> item_state;

  external ffi.Pointer<wire_list_book_meta_data> books;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Bool Function(DartPort port_id, ffi.Pointer<ffi.Void> message)>>;
typedef DartPort = ffi.Int64;
