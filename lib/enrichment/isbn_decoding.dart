import 'dart:io';
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
                                      // convertFlutterUiToImage(ui.Image.file(imgPath));

                                      return Column(
                                          children: snap.data!
                                              .map(
                                                (isbn) => Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
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
                                                      SizedBox(width: 100, child: ISBNPreview(imgPath)),
                                                      // image.copyRectify(src, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
                                                      /*SizedBox(
                                                        width: 200,
                                                        height: 200,
                                                        child: ClipRect(
                                                          child: Transform(
                                                            transform: Matrix4.translationValues(-50, 0, 100)
                                                              ..scale(3.0),
                                                            child: Image.file(
                                                              imgPath,
                                                              alignment: Alignment.topLeft,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),*/
                                                      /* copyCrop(Image(imgPath), x: x, y: y, width: width, height: height)*/
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
  // image.Image? barcodePreview;
  ui.Image? barcodePreview;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final fullImage = image.decodeJpg(await widget.fullImageFile.readAsBytes())!;
      final rectified = image.copyRectify(fullImage,
          topLeft: image.Point(332, 2854),
          topRight: image.Point(939, 2844),
          bottomLeft: image.Point(337, 3162),
          bottomRight: image.Point(944, 3152));
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
    return RawImage(image: barcodePreview);
    // return Image.memory(barcodePreview);
  }
}
