import 'package:flutter/material.dart';
import 'package:kt_dart/collection.dart';

import '../common.dart' as common;
import '../helpers.dart';
import 'enrichment.dart';
import 'metadata_collecting.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});
  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<List<String>>> isbns = KtMutableMap.empty();

  @override
  void initState() {
    super.initState();
    widget.step.bundle.images.forEach((image) {
      isbns[image.path] = common.extractIsbnsFromImage(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN decoding')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              children: widget.step.bundle.images
                  .map((imgPath) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 600, child: ImageWidget(imgPath)),
                              FutureBuilder(
                                  future: isbns[imgPath.path]!,
                                  builder: (context, snap) {
                                    if (snap.hasData == false) {
                                      return const CircularProgressIndicator();
                                    }
                                    return Column(
                                        children: snap.data!
                                            .map((isbn) => Text(
                                                  isbn,
                                                  style: TextStyle(
                                                      decoration:
                                                          isbn.startsWith('978') ? null : TextDecoration.lineThrough),
                                                ))
                                            .toList());
                                  })
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: Future.wait(isbns.values.iter),
                  builder: (context, snap) {
                    return ElevatedButton(
                        onPressed: () {
                          final isbnSet = snap.data!.expand((e) => e).where((isbn) => isbn.startsWith('978')).toSet();
                          print('isbnSet = $isbnSet');
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => BooksMetadataCollectingWidget(
                                      step: MetadataCollectingStep(bundle: widget.step.bundle, isbns: isbnSet))));
                        },
                        child: const Text('Validate ISBNs'));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
