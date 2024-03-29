import 'dart:io';
import 'dart:math';

import 'package:booky/common.dart' as common;
import 'package:booky/personal_info.dart' as personal_info;
import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../copiable_text_field.dart';
import '../draggable_files_widget.dart';
import '../helpers.dart';
import 'enrichment.dart';

class Ad {
  final String title;
  final String description;
  final int priceCent;
  final int weightGrams;
  final rust.ItemState itemState;
  final List<MultiResImage> imgs;

  const Ad({
    required this.title,
    required this.description,
    required this.priceCent,
    required this.weightGrams,
    required this.itemState,
    required this.imgs,
  });
}

class AdEditingWidget extends StatelessWidget {
  const AdEditingWidget({required this.step});

  final AdEditingStep step;

  String fmtAuthors(List<rust.Author>? authors) {
    if (authors == null || authors.length == 0) return '';

    if (authors.length == 1) return ' de ${authors[0].toText()}';
    if (authors.length == 2) return ' de ${authors[0].toText()} et ${authors[1].toText()}';

    // TODO: handle more than 2 authors
    print('Warning: more than 2 authors, only show the first one');
    return ' de ${authors[0].toText()}';
  }

  String _bookFormat(rust.BookMetaData book, {bool withISBN = false}) {
    return '"${book.title ?? 'livre'}"${fmtAuthors(book.authors)}' + (withISBN ? ' (ISBN: ${book.isbn})' : '');
  }

  String? _getDescription(Iterable<rust.BookMetaData> metadataFromIsbn) {
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

  @override
  Widget build(BuildContext context) {
    final ad = Future(() async {
      final images = await step.bundle.images;

      final bundleMetaData = await step.bundle.getMergedMetadata();
      if (bundleMetaData == null) {
        // TODO: Use better default value when no information is known on the bundle (use null instead of 0)
        return Ad(
            title: '', description: '', priceCent: 0, weightGrams: 0, itemState: rust.ItemState.medium, imgs: images);
      }
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

      final keywords = books.map((entry) => entry.keywords ?? []).expand((kw) => kw).toSet().join(', ');
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
          imgs: images);
    });
    return Scaffold(
        appBar: AppBar(title: const Text('Ad editing')),
        body: FutureWidget(
            future: ad,
            builder: (ad) {
              return AdEditingWidget2(step.bundle, ad);
            }));
  }
}

class AdEditingWidget2 extends StatefulWidget {
  const AdEditingWidget2(this.bundle, this.ad);

  final Bundle bundle;
  final Ad ad;

  @override
  State<AdEditingWidget2> createState() => _AdEditingWidget2State();
}

class _AdEditingWidget2State extends State<AdEditingWidget2> {
  late final titleController = TextEditingController(text: widget.ad.title);
  late final descriptionController = TextEditingController(text: widget.ad.description);
  late final priceController = TextEditingController(text: widget.ad.priceCent.divide(100).toString());

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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopyableTextField(TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Ad title',
                ),
                style: const TextStyle(fontSize: 30),
              )),
              _nonCopyableField(Icons.diamond, SizedBox(width: 300, child: _LBCStyledState(widget.ad.itemState))),
              CopyableTextField(TextFormField(
                controller: descriptionController,
                maxLines: null,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                decoration: const InputDecoration(
                  icon: Icon(Icons.text_snippet),
                  labelText: 'Ad description',
                ),
              )),
              CopyableTextField(TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.euro),
                  labelText: 'Price (without shipping cost)',
                ),
                style: const TextStyle(fontSize: 20),
              )),
              _nonCopyableField(
                Icons.scale,
                SizedBox(width: 300, child: _LBCStyledWeight(widget.ad.weightGrams)),
              ),
              _nonCopyableField(Icons.collections, DraggableFilesWidget(images: widget.ad.imgs)),
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      final ad = Ad(
                          title: titleController.text,
                          description: descriptionController.text,
                          priceCent: int.parse(priceController.text),
                          weightGrams: widget.ad.weightGrams,
                          itemState: widget.ad.itemState,
                          imgs: widget.ad.imgs);
                      final manualMd = await widget.bundle.getManualMetadata();
                      widget.bundle.overwriteMetadata(manualMd);
                      final initialDirectory = widget.bundle.directory;
                      final segments = path.split(initialDirectory.path);
                      segments[segments.length - 2] = common.BundleType.published.getDirName;
                      final finalDirectory = Directory(path.joinAll(segments));
                      await initialDirectory.rename(finalDirectory.path);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Moved'),
                          action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                await finalDirectory.rename(initialDirectory.path);
                              }),
                        ));
                        // TODO: Use named route to avoid poping the entire route stack
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
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
      );
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

  final rust.ItemState state;

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
