// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.12.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<BarcodeDetectResults> detectBarcodeInImage(
        {required String imgPath, dynamic hint}) =>
    RustLib.instance.api.detectBarcodeInImage(imgPath: imgPath, hint: hint);

Future<void> getMetadataFromIsbns(
        {required List<String> isbns, required String path, dynamic hint}) =>
    RustLib.instance.api
        .getMetadataFromIsbns(isbns: isbns, path: path, hint: hint);

Future<List<ISBNMetadataPair>> getAutoMetadataFromBundle(
        {required String path, dynamic hint}) =>
    RustLib.instance.api.getAutoMetadataFromBundle(path: path, hint: hint);

Future<BundleMetaData> getManualMetadataForBundle(
        {required String bundlePath, dynamic hint}) =>
    RustLib.instance.api
        .getManualMetadataForBundle(bundlePath: bundlePath, hint: hint);

Future<void> setManualMetadataForBundle(
        {required String bundlePath,
        required BundleMetaData bundleMetadata,
        dynamic hint}) =>
    RustLib.instance.api.setManualMetadataForBundle(
        bundlePath: bundlePath, bundleMetadata: bundleMetadata, hint: hint);

/// Use tokio async to get all the data faster than just calling many times [`get_merged_metadata_for_bundle`]
Future<List<BundleMetaData?>> getMergedMetadataForAllBundles(
        {required String bundlesDir, dynamic hint}) =>
    RustLib.instance.api
        .getMergedMetadataForAllBundles(bundlesDir: bundlesDir, hint: hint);

Future<BundleMetaData> getMergedMetadataForBundle(
        {required String bundlePath, dynamic hint}) =>
    RustLib.instance.api
        .getMergedMetadataForBundle(bundlePath: bundlePath, hint: hint);

Future<BookMetaDataFromProvider?> getMetadataFromProvider(
        {required ProviderEnum provider, required String isbn, dynamic hint}) =>
    RustLib.instance.api
        .getMetadataFromProvider(provider: provider, isbn: isbn, hint: hint);

class Author {
  final String firstName;
  final String lastName;

  const Author({
    required this.firstName,
    required this.lastName,
  });

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Author &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName;
}

class BarcodeDetectResult {
  final String value;
  final List<Point> corners;

  const BarcodeDetectResult({
    required this.value,
    required this.corners,
  });

  @override
  int get hashCode => value.hashCode ^ corners.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeDetectResult &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          corners == other.corners;
}

class BarcodeDetectResults {
  final List<BarcodeDetectResult> results;

  const BarcodeDetectResults({
    required this.results,
  });

  @override
  int get hashCode => results.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeDetectResults &&
          runtimeType == other.runtimeType &&
          results == other.results;
}

class BookMetaData {
  String isbn;
  String? title;
  List<Author> authors;
  String? blurb;
  List<String> keywords;
  int? priceCent;

  BookMetaData({
    required this.isbn,
    this.title,
    required this.authors,
    this.blurb,
    required this.keywords,
    this.priceCent,
  });

  @override
  int get hashCode =>
      isbn.hashCode ^
      title.hashCode ^
      authors.hashCode ^
      blurb.hashCode ^
      keywords.hashCode ^
      priceCent.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookMetaData &&
          runtimeType == other.runtimeType &&
          isbn == other.isbn &&
          title == other.title &&
          authors == other.authors &&
          blurb == other.blurb &&
          keywords == other.keywords &&
          priceCent == other.priceCent;
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

  @override
  int get hashCode =>
      title.hashCode ^
      authors.hashCode ^
      blurb.hashCode ^
      keywords.hashCode ^
      marketPrice.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookMetaDataFromProvider &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          authors == other.authors &&
          blurb == other.blurb &&
          keywords == other.keywords &&
          marketPrice == other.marketPrice;
}

class BundleMetaData {
  int? weightGrams;
  ItemState? itemState;
  final List<BookMetaData> books;

  BundleMetaData({
    this.weightGrams,
    this.itemState,
    required this.books,
  });

  @override
  int get hashCode =>
      weightGrams.hashCode ^ itemState.hashCode ^ books.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BundleMetaData &&
          runtimeType == other.runtimeType &&
          weightGrams == other.weightGrams &&
          itemState == other.itemState &&
          books == other.books;
}

class ISBNMetadataPair {
  final String isbn;
  final List<ProviderMetadataPair> metadatas;

  const ISBNMetadataPair({
    required this.isbn,
    required this.metadatas,
  });

  @override
  int get hashCode => isbn.hashCode ^ metadatas.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ISBNMetadataPair &&
          runtimeType == other.runtimeType &&
          isbn == other.isbn &&
          metadatas == other.metadatas;
}

enum ItemState {
  brandNew,
  veryGood,
  good,
  medium,
}

class Point {
  final int x;
  final int y;

  const Point({
    required this.x,
    required this.y,
  });

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;
}

enum ProviderEnum {
  babelio,
  googleBooks,
  booksPrice,
  abeBooks,
  lesLibraires,
  justBooks,
}

class ProviderMetadataPair {
  final ProviderEnum provider;
  final BookMetaDataFromProvider? metadata;

  const ProviderMetadataPair({
    required this.provider,
    this.metadata,
  });

  @override
  int get hashCode => provider.hashCode ^ metadata.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderMetadataPair &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          metadata == other.metadata;
}
