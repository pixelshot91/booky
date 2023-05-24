import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:kt_dart/collection.dart';

import '../common.dart' as common;
import '../helpers.dart';
import '../image_helper.dart';
import 'enrichment.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});
  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<List<String>>> decodedIsbns = KtMutableMap.empty();
  KtMutableSet<String> selectedIsbns = KtMutableSet.empty();

  @override
  void initState() {
    super.initState();
    widget.step.bundle.images.forEach((image) {
      decodedIsbns[image.path] = common.extractIsbnsFromImage(image);
    });
    selectedIsbns = (widget.step.bundle.metadata.isbns ?? []).toSet().kt;
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
              child: Wrap(
                children: widget.step.bundle.images
                    .map((imgPath) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(height: 600, child: ImageWidget(imgPath)),
                                FutureBuilder(
                                    future: decodedIsbns[imgPath.path]!,
                                    builder: (context, snap) {
                                      if (snap.hasData == false) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Column(
                                          children: snap.data!
                                              .map(
                                                (isbn) => Padding(
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
                                                                decoration: isbn.startsWith('978')
                                                                    ? null
                                                                    : TextDecoration.lineThrough),
                                                          )),
                                                      const SizedBox(width: 20),
                                                      SizedBox(width: 200, child: ISBNPreview(imgPath)),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList());
                                    })
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onSubmitted: (newIsbn) {
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
                              Text(isbn),
                            ],
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            final md = widget.step.bundle.metadata;
                            md.isbns = selectedIsbns.toList().asList();
                            final res = await widget.step.bundle.overwriteMetadata(md);
                            print('res = $res');
                            if (!mounted) return;
                            if (res) {
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error while trying to update metadata.json')));
                            }
                          },
                          child: const Text('Validate ISBNs')),
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

class ISBNPreview extends StatefulWidget {
  const ISBNPreview(this.fullImageFile);

  final File fullImageFile;

  @override
  State<ISBNPreview> createState() => _ISBNPreviewState();
}

class _ISBNPreviewState extends State<ISBNPreview> {
  ui.Image? barcodePreview;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final fullImage = image.decodeJpg(await widget.fullImageFile.readAsBytes())!;
      print('fullImage.width = ${fullImage.width}, fullImage.height= ${fullImage.height}');
      const padding = 40;

      final topLeft = image.Point(332, 2854);
      final topRight = image.Point(939, 2844);
      final bottomLeft = image.Point(337, 3162);
      final bottomRight = image.Point(944, 3152);

      /// By default, copyRectify try to conserve the ratio of the full image
      /// But the barcode zone ratio is has no link with the full image ratio
      /// So the barcode ratio is compute manually then given to `copyRectify` by its `toImage` parameter
      final height = max(bottomLeft.y - topLeft.y, bottomRight.y - topRight.y);
      final width = max(topRight.x - topLeft.x, bottomRight.x - bottomLeft.x);
      final dest = image.Image(height: height.toInt(), width: width.toInt());

      final rectified = image.copyRectify(
        fullImage,
        topLeft: topLeft + image.Point(-padding, -padding),
        topRight: topRight + image.Point(padding, -padding),
        bottomLeft: bottomLeft + image.Point(-padding, padding),
        bottomRight: bottomRight + image.Point(padding, padding),
        toImage: dest,
      );
      print('rectified.width = ${rectified.width}, rectified.height= ${rectified.height}');
      print('dest.width = ${dest.width}, rectified.height= ${dest.height}');

      final rectifiedUi = await convertImageToFlutterUi(rectified);
      setState(() {
        barcodePreview = rectifiedUi;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final barcodePreview = this.barcodePreview;
    if (barcodePreview == null) {
      return const CircularProgressIndicator();
    }
    return RawImage(
      image: barcodePreview,
      fit: BoxFit.fitWidth,
    );
  }
}
