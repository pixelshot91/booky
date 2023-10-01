import 'dart:io';
import 'dart:math';

import 'package:booky/bridge_definitions.dart';
import 'package:booky/common.dart' as common;
import 'package:booky/personal_info.dart' as personal_info;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart' as path;

import '../copiable_text_field.dart';
import '../draggable_files_widget.dart';
import '../helpers.dart';
import 'bundle_selection.dart';
import 'enrichment.dart';

class Ad {
  final String title;
  final String description;
  final int priceCent;
  final int weightGrams;
  final ItemState itemState;
  final List<String> imgsPath;

  const Ad({
    required this.title,
    required this.description,
    required this.priceCent,
    required this.weightGrams,
    required this.itemState,
    required this.imgsPath,
  });
}

class AdEditingWidget extends StatefulWidget {
  const AdEditingWidget({required this.step});

  final AdEditingStep step;

  @override
  State<AdEditingWidget> createState() => _AdEditingWidgetState();
}

String vecFmt(Iterable<String> it) {
  final vec = it.toList();
  if (vec.length == 0) return '';
  if (vec.length == 1) return 'de ${vec[0]}';
  if (vec.length == 2) return 'de ${vec[0]} et ${vec[1]}';
  print('Warning: more than 2 authors, only show the first one');
  return 'de ${vec[0]}';
}

String _bookFormat(BookMetaData book, {bool withISBN = false}) {
  return '"${book.title}" ${vecFmt(book.authors.map((a) => a.toText()))}' + (withISBN ? ' (ISBN: ${book.isbn})' : '');
}

class _AdEditingWidgetState extends State<AdEditingWidget> {
  late Future<Ad> ad;

  @override
  void initState() {
    super.initState();

    ad = Future(() async {
      final bundleMetaData = await widget.step.bundle.getMergedMetadata();
      final books = bundleMetaData.books;

      var title = '';
      if (books.length == 1) {
        final onlyBook = books.single;
        title = _bookFormat(onlyBook);
      }

      var description = '';

      final bookTitles = books.map((md) => _bookFormat(md, withISBN: true)).join('\n');
      description += bookTitles + '\n\n';

      _getDescription(books)?.let((d) => description += d + '\n\n');

      description += personal_info.customMessage;

      final keywords = books.map((entry) => entry.keywords).expand((kw) => kw).toSet().join(', ');
      if (keywords.isNotEmpty) {
        description += '\n\nMots-clés:\n' + keywords;
      }

      final totalPriceIncludingShipping = books.map((e) => e.priceCent ?? 0).sum;
      final weightGramsWithWrapping = (bundleMetaData.weightGrams! * 1.2).toInt();
      var totalPriceExcludingShipping =
          totalPriceIncludingShipping - _estimatedShippingCost(grams: weightGramsWithWrapping);

      const minimumSellingPrice = 100;
      totalPriceExcludingShipping = max(totalPriceExcludingShipping, minimumSellingPrice);
      return Ad(
          title: title,
          description: description,
          priceCent: totalPriceExcludingShipping,
          weightGrams: weightGramsWithWrapping,
          itemState: bundleMetaData.itemState!,
          imgsPath: (await widget.step.bundle.compressedImages).map((e) => e.path).toList());
    });
  }

  String? _getDescription(Iterable<BookMetaData> metadataFromIsbn) {
    final booksWithBlurb = metadataFromIsbn.where((entry) => entry.blurb?.isNotEmpty == true);
    if (booksWithBlurb.length == 0) {
      return null;
    } else if (booksWithBlurb.length == 1) {
      final onlyBookWithBlurb = booksWithBlurb.single;
      String titleAndAuthor = '';
      // Even if only one book has a blurb, multiple book are in the same ad, so we need to specify which book this blurb is about
      if (metadataFromIsbn.length > 1) {
        titleAndAuthor = _bookFormat(onlyBookWithBlurb) + '\n';
      }
      return 'Résumé:\n' + titleAndAuthor + onlyBookWithBlurb.blurb!;
    } else {
      final blurbs = booksWithBlurb.map((entry) => _bookFormat(entry) + ':\n' + entry.blurb!).join('\n\n');
      return 'Résumés:\n' + blurbs;
    }
  }

  Widget _nonCopyableField(IconData icon, Widget child) {
    const iconColor = Color(0xff898989);
    return NonCopyableTextField(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: 16.0),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ad editing')),
        body: FutureWidget(
          future: ad,
          builder: (ad) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CopyableTextField(TextFormField(
                    controller: TextEditingController(text: ad.title),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: 'Ad title',
                    ),
                    style: const TextStyle(fontSize: 30),
                  )),
                  _nonCopyableField(Icons.diamond, SizedBox(width: 300, child: _LBCStyledState(ad.itemState))),
                  CopyableTextField(TextFormField(
                    controller: TextEditingController(text: ad.description),
                    maxLines: null,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.text_snippet),
                      labelText: 'Ad description',
                    ),
                  )),
                  CopyableTextField(TextFormField(
                    controller: TextEditingController(text: ad.priceCent.divide(100).toString()),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.euro),
                      labelText: 'Price (without shipping cost)',
                    ),
                    style: const TextStyle(fontSize: 20),
                  )),
                  _nonCopyableField(
                    Icons.scale,
                    SizedBox(width: 300, child: _LBCStyledWeight(ad.weightGrams)),
                  ),
                  _nonCopyableField(
                      Icons.collections,
                      DraggableFilesWidget(
                        uris: ad.imgsPath.map((path) => Uri.file(path)),
                        child: Column(
                          children: [
                            Row(
                              children: ad.imgsPath
                                  .map((img) => SizedBox(height: 200, child: ImageWidget(File(img))))
                                  .toList(),
                            ),
                            const Text('Drag and drop images')
                          ],
                        ),
                      )),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          final initialDirectory = widget.step.bundle.directory;
                          final segments = path.split(initialDirectory.path);
                          segments[segments.length - 2] = common.BundleType.published.getDirName;
                          final finalDirectory = Directory(path.joinAll(segments));
                          initialDirectory.renameSync(finalDirectory.path);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Moved'),
                            action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await finalDirectory.rename(initialDirectory.path);
                                }),
                          ));
                          Navigator.push(
                              context, MaterialPageRoute<void>(builder: (context) => const BundleSelection()));
                        },
                        child: const Text('Mark as published')),
                  )
                ]
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: e,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );

  int _estimatedShippingCost({required int grams}) {
    final shippingCosts = [
      _ShippingCostIfWeightIsUnder(maxWeightGram: 500, priceCent: 349),
      _ShippingCostIfWeightIsUnder(maxWeightGram: 1000, priceCent: 399),
      _ShippingCostIfWeightIsUnder(maxWeightGram: 2000, priceCent: 499),
      _ShippingCostIfWeightIsUnder(maxWeightGram: 5000, priceCent: 649),
    ];
    final shippingCost = shippingCosts.firstWhere((sc) => sc.maxWeightGram > grams);
    return shippingCost.priceCent;
  }
}

class _ShippingCostIfWeightIsUnder {
  _ShippingCostIfWeightIsUnder({required this.maxWeightGram, required this.priceCent});

  final int maxWeightGram;
  final int priceCent;
}

class _WeightCategory<T> {
  const _WeightCategory({required this.maxWeight, required this.description});

  final int maxWeight;
  final T description;
}

class _LBCStyledState extends StatelessWidget {
  const _LBCStyledState(this.state);

  final ItemState state;

  @override
  Widget build(BuildContext context) => LBCRadioButton(state.loc);
}

class _LBCStyledWeight extends StatelessWidget {
  const _LBCStyledWeight(this.weightGrams);

  final num weightGrams;

  @override
  Widget build(BuildContext context) {
    const weightCategories = [
      _WeightCategory(maxWeight: 100, description: "Jusqu'à 100 g"),
      _WeightCategory(maxWeight: 250, description: 'De 100 g à 250 g'),
      _WeightCategory(maxWeight: 500, description: 'De 250 g à 500 g'),
      _WeightCategory(maxWeight: 1000, description: 'De 500 g à 1 kg'),
      _WeightCategory(maxWeight: 2000, description: 'De 1 kg à 2 kg'),
      _WeightCategory(maxWeight: 5000, description: 'De 2 kg à 5 kg'),
      _WeightCategory(maxWeight: 10000, description: 'De 5 kg à 10 kg'),
      _WeightCategory(maxWeight: 20000, description: 'De 10 kg à 20 kg'),
      _WeightCategory(maxWeight: 20000, description: 'De 20 kg à 30 kg'),
    ];
    return LBCRadioButton(weightCategories.firstWhere((c) => c.maxWeight > weightGrams).description);
  }
}
