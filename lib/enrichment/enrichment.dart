import 'package:flutter_rust_bridge_template/helpers.dart';

import '../bundle.dart';

sealed class BookyStep {}

class BundleSelectionStep implements BookyStep {}

class ISBNDecodingStep implements BookyStep {
  Bundle bundle;
  ISBNDecodingStep({required this.bundle});
}

class MetadataCollectingStep implements BookyStep {
  Bundle bundle;
  MetadataCollectingStep({required this.bundle});
}

class AdEditingStep implements BookyStep {
  Bundle bundle;

  Iterable<BookMetaDataManual> metadata = {};

  AdEditingStep({required this.bundle, required this.metadata});
}

// Example State
/*AdEditingStep(
    bundle: Bundle(
        Directory('/home/julien/Perso/LeBonCoin/chain_automatisation/open_cv_test/test_images/booky_example/normal')),
    metadata: {
      'myisbn': BookMetaDataManual(
          title: 'Mock title',
          authors: [const Author(firstName: 'Mock firstname', lastName: 'mock lastname')],
          blurb: 'This is a mock blurb',
          keywords: ['kw1', 'kw2', 'kw3'],
          priceCent: 1234)
    },
  );*/
/*     MetadataCollectingStep(imgsPaths: [
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194742.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194746.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194753.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194758.jpg'
  ], isbns: {
    '9782253029854',
    // '9782277223634',
  });*/
