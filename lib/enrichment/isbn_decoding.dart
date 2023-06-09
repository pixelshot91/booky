import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge_template/ffi.dart';
import 'package:image/image.dart' as image;
import 'package:kt_dart/collection.dart';
import 'package:vector_math/vector_math_64.dart';

import '../common.dart' as common;
import '../helpers.dart';
import 'enrichment.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});
  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<BarcodeDetectResults>> decodedIsbns = KtMutableMap.empty();
  KtMutableSet<String> selectedIsbns = KtMutableSet.empty();

  @override
  void initState() {
    super.initState();
    Future(() async {
      final images = await widget.step.bundle.images;
      images.forEach((image) {
        decodedIsbns[image.path] = api.detectBarcodeInImage(imgPath: image.path);
      });
    });

    selectedIsbns = (widget.step.bundle.metadata.isbns ?? []).toSet().kt;
  }

  String? _isbn10Validator(String text) {
    final isbnNumbers = text.characters.map((e) {
      final res = int.tryParse(e);
      if (res != null) return res;
      if (e == 'X') return 10;
      throw Exception('Impossible char $e. Should be forbidden by the regex');
    });

    final sum = isbnNumbers.mapIndexed((index, element) {
      final weight = 10 - index;
      return weight * element;
    }).sum;
    if (sum % 11 != 0) return 'Not a valid ISBN-10';
    return null;
  }

  String? _isbn13Validator(String text) {
    try {
      final isbnNumbers = text.characters.map((e) => int.parse(e));
      final sum = isbnNumbers.mapIndexed((index, element) {
        final weight = index % 2 == 0 ? 1 : 3;
        return weight * element;
      }).sum;
      if (sum % 10 != 0) return 'Not a valid ISBN-13';
      return null;
    } on FormatException {
      return 'ISBN-13 can only contain digits';
    }
  }

  String? _isbnValidator(String text) {
    if (text.length == 10) return _isbn10Validator(text);
    if (text.length == 13) return _isbn13Validator(text);
    return 'wrong number of digit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN decoding')),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: FutureWidget(
              future: widget.step.bundle.images,
              builder: (images) => Wrap(
                children: images
                    .map((imgPath) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: 600,
                                    child: InteractiveViewer(
                                      maxScale: 10,
                                      child: ImageWidget(imgPath),
                                    )),
                                FutureWidget(
                                    future: decodedIsbns[imgPath.path]!,
                                    builder: (results) {
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
                                                    onPressed: selectedIsbns.contains(isbn)
                                                        ? null
                                                        : () => setState(() => selectedIsbns.add(isbn)),
                                                    child: Text(
                                                      isbn,
                                                      style: TextStyle(
                                                          decoration: isbn.startsWith(common.isbnPrefix)
                                                              ? null
                                                              : TextDecoration.lineThrough),
                                                    )),
                                                const SizedBox(width: 20),
                                                ISBNPreview(imgFile: imgPath, result: result),
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
                        validator: (s) => _isbnValidator(s!),
                        onFieldSubmitted: (newIsbn) {
                          if (_isbnValidator(newIsbn) != null) return;
                          setState(() => selectedIsbns.add(newIsbn));
                        },
                        decoration: const InputDecoration(hintText: 'Type manually the ISBN here'),
                      ),
                      const SizedBox(height: 20),
                      ...selectedIsbns.iter.map((isbn) => Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() => selectedIsbns.remove(isbn));
                                },
                              ),
                              SelectableText(isbn),
                            ],
                          )),
                      const SizedBox(height: 20),
                      () {
                        final md = widget.step.bundle.metadata;
                        final isbnsDidNotChanged = (md.isbns ?? []).toImmutableSet() == selectedIsbns;
                        return ElevatedButton(
                            onPressed: isbnsDidNotChanged
                                ? null
                                : () async {
                                    final md = widget.step.bundle.metadata;

                                    md.isbns = selectedIsbns.toList().asList();
                                    final res = await widget.step.bundle.overwriteMetadata(md);
                                    print('res = $res');
                                    if (res) {
                                      widget.step.bundle.autoMetadataFile.delete();
                                    }
                                    if (!mounted) return;
                                    if (res) {
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Error while trying to update metadata.json')));
                                    }
                                  },
                            child: const Text('Validate ISBNs'));
                      }(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension _PointExt on Point {
  image.Point toImgPoint() => image.Point(x, y);
}

class ISBNPreview extends StatefulWidget {
  const ISBNPreview({required this.imgFile, required this.result});
  final File imgFile;
  final BarcodeDetectResult result;

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
