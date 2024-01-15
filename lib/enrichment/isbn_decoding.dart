import 'dart:async';
import 'dart:io';

import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:kt_dart/collection.dart';
import 'package:vector_math/vector_math_64.dart';

import '../helpers.dart';
import '../isbn_helper.dart';
import 'enrichment.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});

  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<rust.BarcodeDetectResults>> decodedIsbns = KtMutableMap.empty();

  late Future<ISBNManager> isbnManager;

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
    isbnManager = Future(() async {
      final manualMetaData = await widget.step.bundle.getManualMetadata();
      return ISBNManager(manualMetaData.books.map((b) => ISBN.fromString(b.isbn)!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN decoding')),
      body: FutureWidget(
        future: isbnManager,
        builder: (isbnManager) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Flex(
            direction: constraints.maxWidth > 600 ? Axis.horizontal : Axis.vertical,
            children: [
              SizedBox(
                width: 300,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ISBNsEditor(
                      isbnManager: isbnManager,
                      onISBNsChanged: () => _addISBNAndSave(isbnManager),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
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
                                              final maybeIsbn = ISBN.fromString(result.value);

                                              return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    () {
                                                      if (maybeIsbn != null) {
                                                        final isbn = maybeIsbn;
                                                        return ElevatedButton(
                                                            onPressed: isbnManager.contains(isbn)
                                                                ? null
                                                                : () async {
                                                                    // TODO: add confirmation sound

                                                                    isbnManager.addSureISBN(isbn,
                                                                        onSureTransition: () {});
                                                                  },
                                                            child: Text(isbn.str));
                                                      } else {
                                                        if (result.value.isEmpty) {
                                                          return const Text(
                                                            'Unable to decode',
                                                            style: TextStyle(fontStyle: FontStyle.italic),
                                                          );
                                                        }
                                                        // Not an ISBN, still displayed it but without button
                                                        return Text(result.value,
                                                            style: const TextStyle(
                                                                decoration: TextDecoration.lineThrough));
                                                      }
                                                    }(),
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
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addISBNAndSave(ISBNManager isbnManager) async {
    final md = await widget.step.bundle.getManualMetadata();
    final isbns = isbnManager.getSureISBNs();
    md.setISBN(isbns);
    widget.step.bundle.overwriteMetadata(md);

    try {
      await widget.step.bundle.autoMetadataFile.delete();
    } on PathNotFoundException {
      // autoMetadata file may not exist
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
