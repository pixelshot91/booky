// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.12.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'api/api.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_web.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  Author dco_decode_author(dynamic raw);

  @protected
  BarcodeDetectResult dco_decode_barcode_detect_result(dynamic raw);

  @protected
  BarcodeDetectResults dco_decode_barcode_detect_results(dynamic raw);

  @protected
  BookMetaData dco_decode_book_meta_data(dynamic raw);

  @protected
  BookMetaDataFromProvider dco_decode_book_meta_data_from_provider(dynamic raw);

  @protected
  BookMetaDataFromProvider dco_decode_box_autoadd_book_meta_data_from_provider(
      dynamic raw);

  @protected
  BundleMetaData dco_decode_box_autoadd_bundle_meta_data(dynamic raw);

  @protected
  int dco_decode_box_autoadd_i_32(dynamic raw);

  @protected
  ItemState dco_decode_box_autoadd_item_state(dynamic raw);

  @protected
  BundleMetaData dco_decode_bundle_meta_data(dynamic raw);

  @protected
  double dco_decode_f_32(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  ISBNMetadataPair dco_decode_isbn_metadata_pair(dynamic raw);

  @protected
  ItemState dco_decode_item_state(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  List<Author> dco_decode_list_author(dynamic raw);

  @protected
  List<BarcodeDetectResult> dco_decode_list_barcode_detect_result(dynamic raw);

  @protected
  List<BookMetaData> dco_decode_list_book_meta_data(dynamic raw);

  @protected
  List<ISBNMetadataPair> dco_decode_list_isbn_metadata_pair(dynamic raw);

  @protected
  List<BundleMetaData?> dco_decode_list_opt_box_autoadd_bundle_meta_data(
      dynamic raw);

  @protected
  List<Point> dco_decode_list_point(dynamic raw);

  @protected
  Float32List dco_decode_list_prim_f_32_strict(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  List<ProviderMetadataPair> dco_decode_list_provider_metadata_pair(
      dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  BookMetaDataFromProvider?
      dco_decode_opt_box_autoadd_book_meta_data_from_provider(dynamic raw);

  @protected
  BundleMetaData? dco_decode_opt_box_autoadd_bundle_meta_data(dynamic raw);

  @protected
  int? dco_decode_opt_box_autoadd_i_32(dynamic raw);

  @protected
  ItemState? dco_decode_opt_box_autoadd_item_state(dynamic raw);

  @protected
  Point dco_decode_point(dynamic raw);

  @protected
  ProviderEnum dco_decode_provider_enum(dynamic raw);

  @protected
  ProviderMetadataPair dco_decode_provider_metadata_pair(dynamic raw);

  @protected
  int dco_decode_u_16(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  Author sse_decode_author(SseDeserializer deserializer);

  @protected
  BarcodeDetectResult sse_decode_barcode_detect_result(
      SseDeserializer deserializer);

  @protected
  BarcodeDetectResults sse_decode_barcode_detect_results(
      SseDeserializer deserializer);

  @protected
  BookMetaData sse_decode_book_meta_data(SseDeserializer deserializer);

  @protected
  BookMetaDataFromProvider sse_decode_book_meta_data_from_provider(
      SseDeserializer deserializer);

  @protected
  BookMetaDataFromProvider sse_decode_box_autoadd_book_meta_data_from_provider(
      SseDeserializer deserializer);

  @protected
  BundleMetaData sse_decode_box_autoadd_bundle_meta_data(
      SseDeserializer deserializer);

  @protected
  int sse_decode_box_autoadd_i_32(SseDeserializer deserializer);

  @protected
  ItemState sse_decode_box_autoadd_item_state(SseDeserializer deserializer);

  @protected
  BundleMetaData sse_decode_bundle_meta_data(SseDeserializer deserializer);

  @protected
  double sse_decode_f_32(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  ISBNMetadataPair sse_decode_isbn_metadata_pair(SseDeserializer deserializer);

  @protected
  ItemState sse_decode_item_state(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  List<Author> sse_decode_list_author(SseDeserializer deserializer);

  @protected
  List<BarcodeDetectResult> sse_decode_list_barcode_detect_result(
      SseDeserializer deserializer);

  @protected
  List<BookMetaData> sse_decode_list_book_meta_data(
      SseDeserializer deserializer);

  @protected
  List<ISBNMetadataPair> sse_decode_list_isbn_metadata_pair(
      SseDeserializer deserializer);

  @protected
  List<BundleMetaData?> sse_decode_list_opt_box_autoadd_bundle_meta_data(
      SseDeserializer deserializer);

  @protected
  List<Point> sse_decode_list_point(SseDeserializer deserializer);

  @protected
  Float32List sse_decode_list_prim_f_32_strict(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  List<ProviderMetadataPair> sse_decode_list_provider_metadata_pair(
      SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  BookMetaDataFromProvider?
      sse_decode_opt_box_autoadd_book_meta_data_from_provider(
          SseDeserializer deserializer);

  @protected
  BundleMetaData? sse_decode_opt_box_autoadd_bundle_meta_data(
      SseDeserializer deserializer);

  @protected
  int? sse_decode_opt_box_autoadd_i_32(SseDeserializer deserializer);

  @protected
  ItemState? sse_decode_opt_box_autoadd_item_state(
      SseDeserializer deserializer);

  @protected
  Point sse_decode_point(SseDeserializer deserializer);

  @protected
  ProviderEnum sse_decode_provider_enum(SseDeserializer deserializer);

  @protected
  ProviderMetadataPair sse_decode_provider_metadata_pair(
      SseDeserializer deserializer);

  @protected
  int sse_decode_u_16(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  String cst_encode_AnyhowException(AnyhowException raw) {
    throw UnimplementedError();
  }

  @protected
  String cst_encode_String(String raw) {
    return raw;
  }

  @protected
  List<dynamic> cst_encode_author(Author raw) {
    return [cst_encode_String(raw.firstName), cst_encode_String(raw.lastName)];
  }

  @protected
  List<dynamic> cst_encode_barcode_detect_result(BarcodeDetectResult raw) {
    return [cst_encode_String(raw.value), cst_encode_list_point(raw.corners)];
  }

  @protected
  List<dynamic> cst_encode_barcode_detect_results(BarcodeDetectResults raw) {
    return [cst_encode_list_barcode_detect_result(raw.results)];
  }

  @protected
  List<dynamic> cst_encode_book_meta_data(BookMetaData raw) {
    return [
      cst_encode_String(raw.isbn),
      cst_encode_opt_String(raw.title),
      cst_encode_list_author(raw.authors),
      cst_encode_opt_String(raw.blurb),
      cst_encode_list_String(raw.keywords),
      cst_encode_opt_box_autoadd_i_32(raw.priceCent)
    ];
  }

  @protected
  List<dynamic> cst_encode_book_meta_data_from_provider(
      BookMetaDataFromProvider raw) {
    return [
      cst_encode_opt_String(raw.title),
      cst_encode_list_author(raw.authors),
      cst_encode_opt_String(raw.blurb),
      cst_encode_list_String(raw.keywords),
      cst_encode_list_prim_f_32_strict(raw.marketPrice)
    ];
  }

  @protected
  List<dynamic> cst_encode_box_autoadd_book_meta_data_from_provider(
      BookMetaDataFromProvider raw) {
    return cst_encode_book_meta_data_from_provider(raw);
  }

  @protected
  List<dynamic> cst_encode_box_autoadd_bundle_meta_data(BundleMetaData raw) {
    return cst_encode_bundle_meta_data(raw);
  }

  @protected
  int cst_encode_box_autoadd_i_32(int raw) {
    return cst_encode_i_32(raw);
  }

  @protected
  int cst_encode_box_autoadd_item_state(ItemState raw) {
    return cst_encode_item_state(raw);
  }

  @protected
  List<dynamic> cst_encode_bundle_meta_data(BundleMetaData raw) {
    return [
      cst_encode_opt_box_autoadd_i_32(raw.weightGrams),
      cst_encode_opt_box_autoadd_item_state(raw.itemState),
      cst_encode_list_book_meta_data(raw.books)
    ];
  }

  @protected
  List<dynamic> cst_encode_isbn_metadata_pair(ISBNMetadataPair raw) {
    return [
      cst_encode_String(raw.isbn),
      cst_encode_list_provider_metadata_pair(raw.metadatas)
    ];
  }

  @protected
  List<dynamic> cst_encode_list_String(List<String> raw) {
    return raw.map(cst_encode_String).toList();
  }

  @protected
  List<dynamic> cst_encode_list_author(List<Author> raw) {
    return raw.map(cst_encode_author).toList();
  }

  @protected
  List<dynamic> cst_encode_list_barcode_detect_result(
      List<BarcodeDetectResult> raw) {
    return raw.map(cst_encode_barcode_detect_result).toList();
  }

  @protected
  List<dynamic> cst_encode_list_book_meta_data(List<BookMetaData> raw) {
    return raw.map(cst_encode_book_meta_data).toList();
  }

  @protected
  List<dynamic> cst_encode_list_isbn_metadata_pair(List<ISBNMetadataPair> raw) {
    return raw.map(cst_encode_isbn_metadata_pair).toList();
  }

  @protected
  List<dynamic> cst_encode_list_opt_box_autoadd_bundle_meta_data(
      List<BundleMetaData?> raw) {
    return raw.map(cst_encode_opt_box_autoadd_bundle_meta_data).toList();
  }

  @protected
  List<dynamic> cst_encode_list_point(List<Point> raw) {
    return raw.map(cst_encode_point).toList();
  }

  @protected
  Float32List cst_encode_list_prim_f_32_strict(Float32List raw) {
    return raw;
  }

  @protected
  Uint8List cst_encode_list_prim_u_8_strict(Uint8List raw) {
    return raw;
  }

  @protected
  List<dynamic> cst_encode_list_provider_metadata_pair(
      List<ProviderMetadataPair> raw) {
    return raw.map(cst_encode_provider_metadata_pair).toList();
  }

  @protected
  String? cst_encode_opt_String(String? raw) {
    return raw == null ? null : cst_encode_String(raw);
  }

  @protected
  List<dynamic>? cst_encode_opt_box_autoadd_book_meta_data_from_provider(
      BookMetaDataFromProvider? raw) {
    return raw == null
        ? null
        : cst_encode_box_autoadd_book_meta_data_from_provider(raw);
  }

  @protected
  List<dynamic>? cst_encode_opt_box_autoadd_bundle_meta_data(
      BundleMetaData? raw) {
    return raw == null ? null : cst_encode_box_autoadd_bundle_meta_data(raw);
  }

  @protected
  int? cst_encode_opt_box_autoadd_i_32(int? raw) {
    return raw == null ? null : cst_encode_box_autoadd_i_32(raw);
  }

  @protected
  int? cst_encode_opt_box_autoadd_item_state(ItemState? raw) {
    return raw == null ? null : cst_encode_box_autoadd_item_state(raw);
  }

  @protected
  List<dynamic> cst_encode_point(Point raw) {
    return [cst_encode_u_16(raw.x), cst_encode_u_16(raw.y)];
  }

  @protected
  List<dynamic> cst_encode_provider_metadata_pair(ProviderMetadataPair raw) {
    return [
      cst_encode_provider_enum(raw.provider),
      cst_encode_opt_box_autoadd_book_meta_data_from_provider(raw.metadata)
    ];
  }

  @protected
  double cst_encode_f_32(double raw);

  @protected
  int cst_encode_i_32(int raw);

  @protected
  int cst_encode_item_state(ItemState raw);

  @protected
  int cst_encode_provider_enum(ProviderEnum raw);

  @protected
  int cst_encode_u_16(int raw);

  @protected
  int cst_encode_u_8(int raw);

  @protected
  void cst_encode_unit(void raw);

  @protected
  void sse_encode_AnyhowException(
      AnyhowException self, SseSerializer serializer);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_author(Author self, SseSerializer serializer);

  @protected
  void sse_encode_barcode_detect_result(
      BarcodeDetectResult self, SseSerializer serializer);

  @protected
  void sse_encode_barcode_detect_results(
      BarcodeDetectResults self, SseSerializer serializer);

  @protected
  void sse_encode_book_meta_data(BookMetaData self, SseSerializer serializer);

  @protected
  void sse_encode_book_meta_data_from_provider(
      BookMetaDataFromProvider self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_book_meta_data_from_provider(
      BookMetaDataFromProvider self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_bundle_meta_data(
      BundleMetaData self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_item_state(
      ItemState self, SseSerializer serializer);

  @protected
  void sse_encode_bundle_meta_data(
      BundleMetaData self, SseSerializer serializer);

  @protected
  void sse_encode_f_32(double self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_isbn_metadata_pair(
      ISBNMetadataPair self, SseSerializer serializer);

  @protected
  void sse_encode_item_state(ItemState self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_author(List<Author> self, SseSerializer serializer);

  @protected
  void sse_encode_list_barcode_detect_result(
      List<BarcodeDetectResult> self, SseSerializer serializer);

  @protected
  void sse_encode_list_book_meta_data(
      List<BookMetaData> self, SseSerializer serializer);

  @protected
  void sse_encode_list_isbn_metadata_pair(
      List<ISBNMetadataPair> self, SseSerializer serializer);

  @protected
  void sse_encode_list_opt_box_autoadd_bundle_meta_data(
      List<BundleMetaData?> self, SseSerializer serializer);

  @protected
  void sse_encode_list_point(List<Point> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_f_32_strict(
      Float32List self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_list_provider_metadata_pair(
      List<ProviderMetadataPair> self, SseSerializer serializer);

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_book_meta_data_from_provider(
      BookMetaDataFromProvider? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_bundle_meta_data(
      BundleMetaData? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_i_32(int? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_item_state(
      ItemState? self, SseSerializer serializer);

  @protected
  void sse_encode_point(Point self, SseSerializer serializer);

  @protected
  void sse_encode_provider_enum(ProviderEnum self, SseSerializer serializer);

  @protected
  void sse_encode_provider_metadata_pair(
      ProviderMetadataPair self, SseSerializer serializer);

  @protected
  void sse_encode_u_16(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire extends BaseWire {
  RustLibWire.fromExternalLibrary(ExternalLibrary lib);

  void dart_fn_deliver_output(int call_id, PlatformGeneralizedUint8ListPtr ptr_,
          int rust_vec_len_, int data_len_) =>
      wasmModule.dart_fn_deliver_output(
          call_id, ptr_, rust_vec_len_, data_len_);

  void wire_detect_barcode_in_image(NativePortType port_, String img_path) =>
      wasmModule.wire_detect_barcode_in_image(port_, img_path);

  void wire_get_auto_metadata_from_bundle(NativePortType port_, String path) =>
      wasmModule.wire_get_auto_metadata_from_bundle(port_, path);

  void wire_get_manual_metadata_for_bundle(
          NativePortType port_, String bundle_path) =>
      wasmModule.wire_get_manual_metadata_for_bundle(port_, bundle_path);

  void wire_get_merged_metadata_for_all_bundles(
          NativePortType port_, String bundles_dir) =>
      wasmModule.wire_get_merged_metadata_for_all_bundles(port_, bundles_dir);

  void wire_get_merged_metadata_for_bundle(
          NativePortType port_, String bundle_path) =>
      wasmModule.wire_get_merged_metadata_for_bundle(port_, bundle_path);

  void wire_get_metadata_from_isbns(
          NativePortType port_, List<dynamic> isbns, String path) =>
      wasmModule.wire_get_metadata_from_isbns(port_, isbns, path);

  void wire_get_metadata_from_provider(
          NativePortType port_, int provider, String isbn) =>
      wasmModule.wire_get_metadata_from_provider(port_, provider, isbn);

  void wire_set_manual_metadata_for_bundle(NativePortType port_,
          String bundle_path, List<dynamic> bundle_metadata) =>
      wasmModule.wire_set_manual_metadata_for_bundle(
          port_, bundle_path, bundle_metadata);
}

@JS('wasm_bindgen')
external RustLibWasmModule get wasmModule;

@JS()
@anonymous
class RustLibWasmModule implements WasmModule {
  @override
  external Object /* Promise */ call([String? moduleName]);

  @override
  external RustLibWasmModule bind(dynamic thisArg, String moduleName);

  external void dart_fn_deliver_output(int call_id,
      PlatformGeneralizedUint8ListPtr ptr_, int rust_vec_len_, int data_len_);

  external void wire_detect_barcode_in_image(
      NativePortType port_, String img_path);

  external void wire_get_auto_metadata_from_bundle(
      NativePortType port_, String path);

  external void wire_get_manual_metadata_for_bundle(
      NativePortType port_, String bundle_path);

  external void wire_get_merged_metadata_for_all_bundles(
      NativePortType port_, String bundles_dir);

  external void wire_get_merged_metadata_for_bundle(
      NativePortType port_, String bundle_path);

  external void wire_get_metadata_from_isbns(
      NativePortType port_, List<dynamic> isbns, String path);

  external void wire_get_metadata_from_provider(
      NativePortType port_, int provider, String isbn);

  external void wire_set_manual_metadata_for_bundle(
      NativePortType port_, String bundle_path, List<dynamic> bundle_metadata);
}