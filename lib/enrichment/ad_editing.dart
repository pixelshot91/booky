import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/personal_info.dart' as personal_info;
import 'package:path/path.dart' as path;

import '../copiable_text_field.dart';
import '../draggable_files_widget.dart';
import '../ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../helpers.dart';
import 'bundle_selection.dart';
import 'enrichment.dart';

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

String _bookFormatTitleAndAuthor(String title, Iterable<Author> authors) {
  return '"$title" ${vecFmt(authors.map((a) => a.toText()))}';
}

class _AdEditingWidgetState extends State<AdEditingWidget> {
  late Ad ad;

  @override
  void initState() {
    super.initState();
    final metadataFromIsbn = widget.step.metadata.entries;

    var title = '';
    if (metadataFromIsbn.length == 1) {
      final onlyMetadata = metadataFromIsbn.single.value;
      title = _bookFormatTitleAndAuthor(onlyMetadata.title!, onlyMetadata.authors);
    }
    var description = _getDescription(metadataFromIsbn);

    description += '\n\n' + personal_info.customMessage;

    final keywords = metadataFromIsbn.map((entry) => entry.value.keywords).expand((kw) => kw).toSet().join(', ');
    if (keywords.isNotEmpty) {
      description += '\n\nMots-clés:\n' + keywords;
    }

    final totalPriceIncludingShipping = metadataFromIsbn.map((e) => e.value.priceCent ?? 0).sum;
    final weightGramsWithWrapping = (widget.step.bundle.metadata.weightGrams! * 1.2).toInt();
    var totalPriceExcludingShipping =
        totalPriceIncludingShipping - _estimatedShippingCost(grams: weightGramsWithWrapping);

    const minimumSellingPrice = 100;
    totalPriceExcludingShipping = max(totalPriceExcludingShipping, minimumSellingPrice);
    ad = Ad(
        title: title,
        description: description,
        priceCent: totalPriceExcludingShipping,
        weightGrams: weightGramsWithWrapping,
        imgsPath: widget.step.bundle.compressedImages.map((e) => e.path).toList());
  }

  String _getDescription(Iterable<MapEntry<String, BookMetaDataManual>> metadataFromIsbn) {
    final booksWithBlurb = metadataFromIsbn.where((entry) => entry.value.blurb?.isNotEmpty == true);
    if (booksWithBlurb.length == 0) {
      return '';
    } else if (booksWithBlurb.length == 1) {
      final onlyBookWithBlurb = booksWithBlurb.single.value;
      String titleAndAuthor = '';
      // Even if only one book has a blurb, multiple book are in the same ad, so we need to specify which book this blurb is about
      if (metadataFromIsbn.length > 1) {
        titleAndAuthor = _bookFormatTitleAndAuthor(onlyBookWithBlurb.title!, onlyBookWithBlurb.authors) + '\n';
      }
      return 'Résumé:\n' + titleAndAuthor + onlyBookWithBlurb.blurb!;
    } else {
      final bookTitles =
          booksWithBlurb.map((entry) => _bookFormatTitleAndAuthor(entry.value.title!, entry.value.authors)).join('\n ');
      final blurbs = booksWithBlurb
          .map((entry) =>
              _bookFormatTitleAndAuthor(entry.value.title!, entry.value.authors) + ':\n' + entry.value.blurb!)
          .join('\n');
      final description = bookTitles + '\n\nRésumés:\n' + blurbs;
      return description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.step.bundle.metadata;
    return Scaffold(
      appBar: AppBar(title: const Text('Ad editing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CopiableTextField(TextFormField(
                controller: TextEditingController(text: ad.title),
                decoration: const InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Ad title',
                ),
                style: const TextStyle(fontSize: 30),
              )),
              TextFormField(
                initialValue: metadata.itemState?.loc,
                decoration: const InputDecoration(
                  icon: Icon(Icons.diamond),
                  labelText: 'State',
                ),
                style: const TextStyle(fontSize: 20),
              ),
              CopiableTextField(TextFormField(
                controller: TextEditingController(text: ad.description),
                maxLines: null,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                decoration: const InputDecoration(
                  icon: Icon(Icons.text_snippet),
                  labelText: 'Ad description',
                ),
              )),
              CopiableTextField(TextFormField(
                controller: TextEditingController(text: ad.priceCent.divide(100).toString()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.euro),
                  labelText: 'Price (without shipping cost)',
                ),
                style: const TextStyle(fontSize: 20),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.scale,
                      color: Colors.grey,
                    ),
                    Expanded(child: _LBCStyledWeight(ad.weightGrams)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(children: [
                  const Icon(
                    Icons.collections,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  DraggableFilesWidget(
                    uris: ad.imgsPath.map((path) => Uri.file(path)),
                    child: Column(
                      children: [
                        Row(
                          children:
                              ad.imgsPath.map((img) => SizedBox(height: 200, child: ImageWidget(File(img)))).toList(),
                        ),
                        const Text('Drag and drop images')
                      ],
                    ),
                  ),
                ]),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      final d = widget.step.bundle.directory;
                      final segments = path.split(d.path);
                      segments[segments.length - 2] = 'booky_done';
                      d.renameSync(path.joinAll(segments));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Moved'),
                      ));
                      Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const BundleSelection()));
                    },
                    child: const Text('Mark as published')),
              )
            ],
          ),
        ),
      ),
    );
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
