import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';
import 'package:flutter_rust_bridge_template/personal_info.dart' as personal_info;

import 'common.dart';
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';

class AdEditingWidget extends StatefulWidget {
  const AdEditingWidget({required this.step, required this.onSubmit});
  final AdEditingStep step;
  final void Function(bool newStep) onSubmit;

  @override
  State<AdEditingWidget> createState() => _AdEditingWidgetState();
}

String vecFmt(List<String> vec) {
  if (vec.length == 0) return '';
  if (vec.length == 1) return 'de ${vec[0]}';
  if (vec.length == 2) return 'de ${vec[0]} et ${vec[1]}';
  throw UnimplementedError('More than 2 authors');
}

String _bookFormatTitleAndAuthor(BookMetaData book) {
  final authors = book.authors.map((a) => '${a.firstName} ${a.lastName}').toList();
  return '"${book.title}" ${vecFmt(authors)}';
}

class _AdEditingWidgetState extends State<AdEditingWidget> {
  late Ad ad;

  @override
  void initState() {
    super.initState();
    final bookTitles = widget.step.metadata.entries.map((entry) => _bookFormatTitleAndAuthor(entry.value)).join('\n');
    final blurbs = widget.step.metadata.entries
        .map((entry) => _bookFormatTitleAndAuthor(entry.value) + ':\n' + entry.value.blurb!)
        .join('\n');
    var description = bookTitles + '\n\nRésumé:\n' + blurbs + '\n\n' + personal_info.customMessage;
    final keywords = widget.step.metadata.entries.map((entry) => entry.value.keywords).join(', ');
    if (keywords.isNotEmpty) {
      description += '\n\nMots-clés:\n' + keywords;
    }
    ad = Ad(title: '', description: description, priceCent: 1000, imgsPath: widget.step.imgsPaths);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: ad.title,
            onChanged: (newText) => setState(() => ad.title = newText),
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              labelText: 'Ad title',
            ),
            style: const TextStyle(fontSize: 30),
          ),
          TextFormField(
            initialValue: ad.description,
            maxLines: 20,
            onChanged: (newText) => setState(() => ad.description = newText),
            decoration: const InputDecoration(
              icon: Icon(Icons.text_snippet),
              labelText: 'Ad description',
            ),
          ),
          TextFormField(
            initialValue: ad.priceCent /*?*/ .divide(100).toString(),
            onChanged: (newText) =>
                setState(() => ad.priceCent = double.tryParse(newText)! /*?*/ .multiply(100).round()),
            decoration: const InputDecoration(
              icon: Icon(Icons.euro),
              labelText: 'Price',
            ),
            style: const TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(children: [
              const Icon(
                Icons.image,
                color: Colors.grey,
              ),
              const SizedBox(width: 16),
              ...ad.imgsPath.map((imgPath) => ImageWidget(imgPath)).toList(),
            ]),
          ),
          ElevatedButton(
              onPressed: ad.priceCent == null
                  ? null
                  : () {
                      print('Try to publish...');
                      api.publishAd(ad: ad);
                    },
              child: const Text('Publish'))
        ],
      ),
    );
  }
}
