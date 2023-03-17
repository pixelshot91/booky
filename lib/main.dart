import 'package:flutter/material.dart';

import 'ad_editing.dart';
import 'drag_and_drop.dart' as drag_and_drop;
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'isbn_decoding.dart';
import 'metadata_collecting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
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
  Map<String, BookMetaData> metadata = {};

  AdEditingStep({required this.imgsPaths, required this.metadata});
}

class _MyAppState extends State<MyApp> {
  BookyStep step = //ImageSelectionStep();
      MetadataCollectingStep(imgsPaths: [
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194742.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194746.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194753.jpg',
    '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194758.jpg'
  ], isbns: {
    '9782253029854',
    '9782277223634',
  });
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

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.imgsPaths);
  final List<String> imgsPaths;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Ad> ad;
  @override
  void initState() {
    super.initState();
    // ad = api.getMetadataFromImages(imgsPath: widget.imgsPaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an automatic online book ad from picture'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // To render the results of a Future, a FutureBuilder is used which
            // turns a Future into an AsyncSnapshot, which can be used to
            // extract the error state, the loading state and the data if
            // available.
            //
            // Here, the generic type that the FutureBuilder manages is
            // explicitly named, because if omitted the snapshot will have the
            // type of AsyncSnapshot<Object?>.
            FutureBuilder<Ad>(
              future: ad,
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headlineMedium;
                if (snap.error != null) {
                  // An error has been encountered, so give an appropriate response and
                  // pass the error details to an unobstructive tooltip.
                  debugPrint(snap.error.toString());
                  return Tooltip(
                    message: snap.error.toString(),
                    child: Text('Error during image decoding', style: style),
                  );
                }

                final ad = snap.data;
                if (ad == null) return const Text('Extracting info from images');

                return const Text('extract finish');
              },
            )
          ],
        ),
      ),
    );
  }
}

extension IntExt on int {
  int divide(int other) => this ~/ other;
}

extension DoubleExt on double {
  double multiply(double other) => this * other;
}
