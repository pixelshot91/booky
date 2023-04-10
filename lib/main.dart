import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/common.dart';

import 'ad_editing.dart';
import 'drag_and_drop.dart' as drag_and_drop;
import 'isbn_decoding.dart';
import 'metadata_collecting.dart';

void main() {
  runApp(const MyApp());
}

sealed class BookyStep {}

class ImageSelectionStep implements BookyStep {}

class ISBNDecodingStep implements BookyStep {
  List<String> imgsPaths = [];
  ISBNDecodingStep({required this.imgsPaths});
}

class MetadataCollectingStep implements BookyStep {
  List<String> imgsPaths = [];
  Set<String> isbns = {};
  MetadataCollectingStep({required this.imgsPaths, required this.isbns});
}

class AdEditingStep implements BookyStep {
  List<String> imgsPaths = [];
  Map<String, BookMetaDataManual> metadata = {};

  AdEditingStep({required this.imgsPaths, required this.metadata});
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BookyStep step = ImageSelectionStep();
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
          ImageSelectionStep() => drag_and_drop.SelectImages(onSelect: (List<String> paths) {
            setState(() {
              step = ISBNDecodingStep(imgsPaths: paths);
            });
          }),
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
