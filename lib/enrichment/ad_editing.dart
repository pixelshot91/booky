import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/personal_info.dart' as personal_info;
import 'package:path/path.dart' as path;

import '../copiable_text_field.dart';
import '../draggable_files_widget.dart';
import '../ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../helpers.dart';
import 'enrichment.dart';

class AdEditingWidget extends StatefulWidget {
  const AdEditingWidget({required this.step, required this.onSubmit});
  final AdEditingStep step;
  final void Function() onSubmit;

  @override
  State<AdEditingWidget> createState() => _AdEditingWidgetState();
}

String vecFmt(Iterable<String> it) {
  final vec = it.toList();
  if (vec.length == 0) return '';
  if (vec.length == 1) return 'de ${vec[0]}';
  if (vec.length == 2) return 'de ${vec[0]} et ${vec[1]}';
  throw UnimplementedError('More than 2 authors');
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

    final totalPrice = metadataFromIsbn.map((e) => e.value.priceCent ?? 0).sum;

    ad = Ad(
        title: title,
        description: description,
        priceCent: totalPrice,
        imgsPath: widget.step.bundle.compressedImages.map((e) => e.path).toList());
  }

  String _getDescription(Iterable<MapEntry<String, BookMetaDataManual>> metadataFromIsbn) {
    if (metadataFromIsbn.length == 1) {
      final blurb = metadataFromIsbn.single.value.blurb;
      if (blurb == null) return '';
      return 'Résumé:\n' + blurb;
    } else {
      final bookTitles = metadataFromIsbn
          .map((entry) => _bookFormatTitleAndAuthor(entry.value.title!, entry.value.authors))
          .join('\n');
      final blurbs = metadataFromIsbn
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
            children: [
              CopiableTextField(TextFormField(
                controller: TextEditingController(text: ad.title),
                onChanged: (newText) => setState(() => ad.title = newText),
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
                onChanged: (newText) => setState(() => ad.description = newText),
                decoration: const InputDecoration(
                  icon: Icon(Icons.text_snippet),
                  labelText: 'Ad description',
                ),
              )),
              CopiableTextField(TextFormField(
                controller: TextEditingController(text: ad.priceCent.divide(100).toString()),
                onChanged: (newText) =>
                    setState(() => ad.priceCent = double.tryParse(newText)! /*?*/ .multiply(100).round()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.euro),
                  labelText: 'Price',
                ),
                style: const TextStyle(fontSize: 20),
              )),
              TextFormField(
                initialValue: metadata.weightGrams?.toString(),
                decoration: const InputDecoration(
                  icon: Icon(Icons.scale),
                  labelText: 'Weight (grams)',
                ),
                style: const TextStyle(fontSize: 20),
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
              ElevatedButton(
                  onPressed: () {
                    final d = widget.step.bundle.directory;
                    final segments = path.split(d.path);
                    segments[segments.length - 2] = 'booky_done';
                    d.renameSync(path.joinAll(segments));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Moved'),
                    ));
                    widget.onSubmit();
                  },
                  child: const Text('Mark as published'))
            ],
          ),
        ),
      ),
    );
  }
}
