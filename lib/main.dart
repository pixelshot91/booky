import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/helpers.dart';

import 'ad_editing.dart';
import 'bundle.dart';
import 'bundle_selection.dart';
import 'isbn_decoding.dart';
import 'metadata_collecting.dart';

void main() {
  runApp(const MyApp());
}

sealed class BookyStep {}

class BundleSelectionStep implements BookyStep {}

class ISBNDecodingStep implements BookyStep {
  Bundle bundle;
  ISBNDecodingStep({required this.bundle});
}

class MetadataCollectingStep implements BookyStep {
  Bundle bundle;
  Set<String> isbns = {};
  MetadataCollectingStep({required this.bundle, required this.isbns});
}

class AdEditingStep implements BookyStep {
  Bundle bundle;

  Map<String, BookMetaDataManual> metadata = {};

  AdEditingStep({required this.bundle, required this.metadata});
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BookyStep step = BundleSelectionStep();
  /* AdEditingStep(imgsPaths: [
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194742.jpg'
  ], metadata: {
    'myisbn': BookMetaData(
        title: 'Mock title',
        authors: [Author(firstName: 'Mock firstname', lastName: 'mock lastname')],
        keywords: ['mock kw'])
  });*/
  /*     MetadataCollectingStep(imgsPaths: [
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194742.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194746.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194753.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194758.jpg'
  ], isbns: {
    '9782253029854',
    // '9782277223634',
  });*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BookAdPublisher',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: switch (step) {
          BundleSelectionStep() =>
            BundleSelection(onSubmit: (ISBNDecodingStep newStep) => setState(() => step = newStep)),
          ISBNDecodingStep() => ISBNDecodingWidget(
              step: step as ISBNDecodingStep,
              onSubmit: (MetadataCollectingStep newStep) => setState(() => step = newStep)),
          MetadataCollectingStep() => MetadataCollectingWidget(
              step: step as MetadataCollectingStep,
              onSubmit: (AdEditingStep newStep) => setState(() => step = newStep)),
          AdEditingStep() => AdEditingWidget(
              step: step as AdEditingStep,
              onSubmit: (bool publishSuccess) => print('onSubmit with bool = $publishSuccess')),
          BookyStep() => throw UnimplementedError('Not possible')
        });
  }
}
