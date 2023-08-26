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

class NativePlatform extends FlutterRustBridgeBase<NativeWire>
    with FlutterRustBridgeSetupMixin {
  NativePlatform(FutureOr<WasmModule> dylib) : super(NativeWire(dylib)) {
    setupMixinConstructor();
  }
  Future<void> setup() => inner.init;

// Section: api2wire

  @protected
  String api2wire_String(String raw) {
    return raw;
  }

  @protected
  List<String> api2wire_StringList(List<String> raw) {
    return raw;
  }

  @protected
  List<dynamic> api2wire_ad(Ad raw) {
    return [
      api2wire_String(raw.title),
      api2wire_String(raw.description),
      api2wire_i32(raw.priceCent),
      api2wire_i32(raw.weightGrams),
      api2wire_StringList(raw.imgsPath)
    ];
  }

  @protected
  List<dynamic> api2wire_box_autoadd_ad(Ad raw) {
    return api2wire_ad(raw);
  }

  @protected
  List<dynamic> api2wire_box_autoadd_lbc_credential(LbcCredential raw) {
    return api2wire_lbc_credential(raw);
  }

  @protected
  List<dynamic> api2wire_lbc_credential(LbcCredential raw) {
    return [api2wire_String(raw.lbcToken), api2wire_String(raw.datadomeCookie)];
  }

  @protected
  Uint8List api2wire_uint_8_list(Uint8List raw) {
    return raw;
  }
// Section: finalizer
}

// Section: WASM wire module

@JS('wasm_bindgen')
external NativeWasmModule get wasmModule;

@JS()
@anonymous
class NativeWasmModule implements WasmModule {
  external Object /* Promise */ call([String? moduleName]);
  external NativeWasmModule bind(dynamic thisArg, String moduleName);
  external dynamic /* void */ wire_detect_barcode_in_image(
      NativePortType port_, String img_path);

  external dynamic /* void */ wire_get_metadata_from_isbns(
      NativePortType port_, List<String> isbns, String path);

  external dynamic /* void */ wire_get_auto_metadata_from_bundle(
      NativePortType port_, String path);

  external dynamic /* void */ wire_get_metadata_from_provider(
      NativePortType port_, int provider, String isbn);

  external dynamic /* void */ wire_publish_ad(
      NativePortType port_, List<dynamic> ad, List<dynamic> credential);
}

// Section: WASM wire connector

class NativeWire extends FlutterRustBridgeWasmWireBase<NativeWasmModule> {
  NativeWire(FutureOr<WasmModule> module)
      : super(WasmModule.cast<NativeWasmModule>(module));

  void wire_detect_barcode_in_image(NativePortType port_, String img_path) =>
      wasmModule.wire_detect_barcode_in_image(port_, img_path);

  void wire_get_metadata_from_isbns(
          NativePortType port_, List<String> isbns, String path) =>
      wasmModule.wire_get_metadata_from_isbns(port_, isbns, path);

  void wire_get_auto_metadata_from_bundle(NativePortType port_, String path) =>
      wasmModule.wire_get_auto_metadata_from_bundle(port_, path);

  void wire_get_metadata_from_provider(
          NativePortType port_, int provider, String isbn) =>
      wasmModule.wire_get_metadata_from_provider(port_, provider, isbn);

  void wire_publish_ad(
          NativePortType port_, List<dynamic> ad, List<dynamic> credential) =>
      wasmModule.wire_publish_ad(port_, ad, credential);
}
