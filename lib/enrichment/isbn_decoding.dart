import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/ffi.dart';
import 'package:image/image.dart' as image;
import 'package:kt_dart/collection.dart';

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
  KtMutableMap<String, Future<BarcodeDetectResults>> decodedIsbns = KtMutableMap.empty();
  KtMutableSet<String> selectedIsbns = KtMutableSet.empty();

  @override
  void initState() {
    super.initState();
    widget.step.bundle.images.forEach((image) {
      decodedIsbns[image.path] = api.detectBarcodeInImage(imgPath: image.path);
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
                                                          decoration: isbn.startsWith('978')
                                                              ? null
                                                              : TextDecoration.lineThrough),
                                                    )),
                                                const SizedBox(width: 20),
                                                SizedBox(
                                                    width: 200, child: ISBNPreview(imgPath, corners: result.corners)),
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

class ISBNPreview extends StatefulWidget {
  const ISBNPreview(this.fullImageFile, {required this.corners});

  final File fullImageFile;
  final List<Point> corners;

  @override
  State<ISBNPreview> createState() => _ISBNPreviewState();
}

extension PointExt on Point {
  image.Point toImgPoint() => image.Point(x, y);
}

class _ISBNPreviewState extends State<ISBNPreview> {
  ui.Image? barcodePreview;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final fullImage = image.decodeJpg(await widget.fullImageFile.readAsBytes())!;

      /// Add some space around the barcode to be sure the text ISBN will be in the frame
      const padding = 50;

      final topLeft = widget.corners[1].toImgPoint() + image.Point(-padding, -padding);
      final topRight = widget.corners[2].toImgPoint() + image.Point(padding, -padding);
      final bottomLeft = widget.corners[0].toImgPoint() + image.Point(-padding, padding);
      final bottomRight = widget.corners[3].toImgPoint() + image.Point(padding, padding);

      /// By default, copyRectify try to conserve the ratio of the full image
      /// But the barcode zone ratio is has no link with the full image ratio
      /// So the barcode ratio is computed manually then given to `copyRectify` through its `toImage` parameter
      final height = max(bottomLeft.y - topLeft.y, bottomRight.y - topRight.y);
      final width = max(topRight.x - topLeft.x, bottomRight.x - bottomLeft.x);
      final dest = image.Image(height: height.toInt(), width: width.toInt());

      final rectified = image.copyRectify(
        fullImage,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        toImage: dest,
      );

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
