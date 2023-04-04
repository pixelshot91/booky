import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';
import 'package:flutter_rust_bridge_template/personal_info.dart' as personal_info;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'common.dart';
import 'credential.dart';
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';

class AdEditingWidget extends StatefulWidget {
  const AdEditingWidget({required this.step, required this.onSubmit});
  final AdEditingStep step;
  final void Function(bool newStep) onSubmit;

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
  return '"$title" ${vecFmt(authors.map((a) => '${a.firstName} ${a.lastName}'))}';
}

class _AdEditingWidgetState extends State<AdEditingWidget> {
  late Ad ad;
  late Credential credential;

  @override
  void initState() {
    super.initState();
    final metadataFromIsbn = widget.step.metadata.entries;

    final title = metadataFromIsbn.length == 1 ? (metadataFromIsbn.first.value.title ?? '') : '';
    var description = _getDescription(metadataFromIsbn);

    description += '\n\n' + personal_info.customMessage;

    final keywords = metadataFromIsbn.map((entry) => entry.value.keywords).expand((kw) => kw).toSet().join(', ');
    if (keywords.isNotEmpty) {
      description += '\n\nMots-clés:\n' + keywords;
    }

    ad = Ad(title: title, description: description, priceCent: 1000, imgsPath: widget.step.imgsPaths);

    credential = Credential.loadFromFile();
    print('credential ${credential.lbcToken} ${credential.dataDomeCookie}');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ad editing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
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
                maxLines: null,
                scrollPhysics: const NeverScrollableScrollPhysics(),
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
              TextFormField(
                initialValue: credential.lbcToken,
                onChanged: (newText) => setState(() => credential.lbcToken = newText),
                decoration: const InputDecoration(
                  icon: Icon(Icons.key),
                  labelText: 'LBC Bearer token',
                ),
                style: const TextStyle(fontSize: 20),
                autovalidateMode: AutovalidateMode.always,
                validator: (token) {
                  final remainingDuration = JwtDecoder.getRemainingTime(token!);
                  if (remainingDuration.isNegative) {
                    return 'Token expired';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: credential.dataDomeCookie,
                onChanged: (newText) => setState(() => credential.dataDomeCookie = newText),
                decoration: const InputDecoration(
                  icon: Icon(Icons.cookie),
                  labelText: 'datadome cookie',
                ),
                style: const TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                  onPressed: (ad.title.length < 2 ||
                          ad.description.length < 15 ||
                          ad.description.length > 4000 ||
                          ad.priceCent == null)
                      ? null
                      : () async {
                          print('Try to publish...');

                          final res = await api.publishAd(
                              ad: ad,
                              credential: LbcCredential(
                                  lbcToken: credential.lbcToken, datadomeCookie: credential.dataDomeCookie));

                          if (!context.mounted) return;
                          if (res) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success')));
                            credential.saveToFile();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failure')));
                          }
                        },
                  child: const Text('Publish'))
            ],
          ),
        ),
      ),
    );
  }
}
