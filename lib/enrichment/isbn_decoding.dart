import 'dart:async';
import 'dart:io';

import 'package:booky/isbn_helper.dart';
import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:kt_dart/collection.dart';
import 'package:vector_math/vector_math_64.dart';

import '../helpers.dart';
import 'enrichment.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});

  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<rust.BarcodeDetectResults>> decodedIsbns = KtMutableMap.empty();

  // TODO: Should be a list to preserve order
  late Future<KtMutableSet<String>> isbns;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) {
      Future(() async {
        final images = await widget.step.bundle.images;
        images.forEach((image) {
          decodedIsbns[image.fullScale.path] = rust.detectBarcodeInImage(imgPath: image.fullScale.path);
        });
      });
    }

    isbns = Future(() async {
      final manualMetaData = await widget.step.bundle.getManualMetadata();
      return (manualMetaData.books.map((b) => b.isbn)).toSet().kt;
    });
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN decoding')),
      body: FutureWidget(
        future: isbns,
        builder: (isbns) => SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: FutureWidget(
                future: widget.step.bundle.images,
                builder: (images) => Wrap(
                  children: images
                      .map((img) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height: 600,
                                      child: InteractiveViewer(
                                        maxScale: 10,
                                        child: ImageWidget(img.fullScale),
                                      )),
                                  FutureWidget(
                                      future: decodedIsbns[img.fullScale.path] ?? Future(() => null),
                                      builder: (results) {
                                        if (results == null) return const Text('No result');
                                        return Column(
                                            children: results.results.map(
                                          (result) {
                                            final isbn = result.value;

                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: isbns.contains(isbn)
                                                          ? null
                                                          : () async => await _addISBNAndSave(isbn, isbns),
                                                      child: Text(
                                                        isbn,
                                                        style: TextStyle(
                                                            decoration: isbnValidator(isbn) == null
                                                                ? null
                                                                : TextDecoration.lineThrough),
                                                      )),
                                                  const SizedBox(width: 20),
                                                  ISBNPreview(imgFile: img.fullScale, result: result),
                                                ],
                                              ),
                                            );
                                          },
                                        ).toList());
                                      })
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )),
              // const Spacer(),
              SizedBox(
                width: 300,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9X]{0,13}')),
                          ],
                          autovalidateMode: AutovalidateMode.always,
                          validator: (s) => isbnValidator(s!),
                          onFieldSubmitted: (newIsbn) async => await _addISBNAndSave(newIsbn, isbns),
                          decoration: const InputDecoration(hintText: 'Type manually the ISBN here'),
                        ),
                        const SizedBox(height: 20),
                        ...isbns.iter.map((isbn) => Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final md = await widget.step.bundle.getManualMetadata();

                                    md.books.removeWhere((book) => book.isbn == isbn);

                                    final res = await widget.step.bundle.overwriteMetadata(md);
                                    print('res = $res');
                                    if (mounted) {
                                      if (res) {
                                        setState(() => isbns.remove(isbn));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('Error while trying to update metadata.json')));
                                      }
                                    }
                                  },
                                ),
                                SelectableText(isbn),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addISBNAndSave(String newIsbn, KtMutableSet<String> isbns) async {
    if (isbnValidator(newIsbn) != null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: not a valid ISBN. isbn is '$newIsbn'")));
      }
    }

    // TODO: reject if the ISBN already exist
    final md = await widget.step.bundle.getManualMetadata();
    md.books.add(rust.BookMetaData(isbn: newIsbn, authors: [], keywords: []));

    final res = await widget.step.bundle.overwriteMetadata(md);
    print('res = $res');
    if (res) {
      try {
        await widget.step.bundle.autoMetadataFile.delete();
      } on PathNotFoundException {
        // autoMetadata file may not exist
      }
      setState(() => isbns.add(newIsbn));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error while trying to update metadata.json')));
      }
    }
  }
}

extension _PointExt on rust.Point {
  image.Point toImgPoint() => image.Point(x, y);
}

class ISBNPreview extends StatefulWidget {
  const ISBNPreview({required this.imgFile, required this.result});

  final File imgFile;
  final rust.BarcodeDetectResult result;

  @override
  State<ISBNPreview> createState() => _ISBNPreviewState();
}

class _ISBNPreviewState extends State<ISBNPreview> {
  late num barcodeWidth;
  late Vector3 translate;

  @override
  void initState() {
    super.initState();

    /// Add some space around the barcode to be sure the text ISBN will be in the frame
    const padding = 50;
    final topLeft = widget.result.corners[1].toImgPoint() + image.Point(-padding, -padding);
    final topRight = widget.result.corners[2].toImgPoint() + image.Point(padding, -padding);
    barcodeWidth = topRight.x - topLeft.x;
    translate = Vector3(-topLeft.x.toDouble(), -topLeft.y.toDouble(), 0.0);
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 300.0;

    return SizedBox(
        width: maxWidth,
        height: maxWidth,
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                maxScale: 4,
                minScale: 0.01,
                // Allow to scale down so much that the image does not fill the viewport anymore
                boundaryMargin: const EdgeInsets.all(500.0),
                transformationController: TransformationController(Matrix4.identity()
                  ..scale(maxWidth / barcodeWidth)
                  ..translate(translate)),
                constrained: false,
                child: ImageWidget(widget.imgFile),
              ),
            ),
            // TODO: When scrolling over the InteractiveViewer, both the InteractiveViewer and the surrounding SingleChildScrollView handle it
            // Ideally, if the InteractiveViewer handles the scroll event, it should absorb it and prevent the SingleChildScrollView from scrolling
            // For some reason holding shift while scrolling prevent the SingleChildScrollView from scrolling
            const Text('Shift+scroll to zoom in and out of the image'),
          ],
        ));
  }
}
