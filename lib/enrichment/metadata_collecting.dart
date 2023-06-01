import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge_template/bundle.dart';
import 'package:flutter_rust_bridge_template/enrichment/ad_editing.dart';
import 'package:flutter_rust_bridge_template/helpers.dart';
import 'package:kt_dart/kt.dart';

import '../ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'enrichment.dart';

class BooksMetadataCollectingWidget extends StatefulWidget {
  const BooksMetadataCollectingWidget({required this.step});

  final MetadataCollectingStep step;
  @override
  State<BooksMetadataCollectingWidget> createState() => _BooksMetadataCollectingWidgetState();
}

class _Metadata {
  _Metadata({required this.providerMetadatas, required this.bookControllerSet});

  Map<ProviderEnum, BookMetaDataFromProvider?> providerMetadatas;
  final _BookControllerSet bookControllerSet;
}

class _BooksMetadataCollectingWidgetState extends State<BooksMetadataCollectingWidget> {
  Map<String, _Metadata>? controllers;

  @override
  void initState() {
    super.initState();

    Future(() async {
      final autoMd = await api.getAutoMetadataFromBundle(path: widget.step.bundle.autoMetadataFile.path);
      if (mounted) {
        setState(() {
          controllers = Map.fromEntries(autoMd.map((entry) => MapEntry(
              entry.isbn,
              _Metadata(
                  providerMetadatas:
                      entry.metadatas.map((md) => MapEntry(md.provider, md.metadata)).let((e) => Map.fromEntries(e)),
                  bookControllerSet: _BookControllerSet()))));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Metadata Collecting'),
        ),
        body: controllers.ifIs(
            nul: () => const CircularProgressIndicator(),
            notnull: (controllers) => SingleChildScrollView(
                  child: Column(
                    children: [
                      ...controllers.entries
                          .map((entry) => _BookMetadataCollectingWidget(
                                isbn: entry.key,
                                metadatas: entry.value,
                              ))
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (context) => AdEditingWidget(
                                          step: AdEditingStep(
                                              bundle: widget.step.bundle,
                                              metadata: controllers.map((key, value) => MapEntry(
                                                  key,
                                                  BookMetaDataManual(
                                                    title: value.bookControllerSet.titleTextFieldController.text,
                                                    authors: _stringToAuthors(
                                                        value.bookControllerSet.authorsTextFieldController.text),
                                                    blurb: value.bookControllerSet.blurbTextFieldController.text,
                                                    keywords: _stringToKeywords(
                                                        value.bookControllerSet.keywordsTextFieldController.text),
                                                    priceCent: double.parse(
                                                            value.bookControllerSet.priceTextFieldController.text)
                                                        .multiply(100)
                                                        .round(),
                                                  )))))));
                            },
                            child: const Text('Validate Metadatas')),
                      )
                    ],
                  ),
                )));
  }
}

class _BookControllerSet {
  final TextEditingController titleTextFieldController = TextEditingController();
  final TextEditingController authorsTextFieldController = TextEditingController();
  final TextEditingController blurbTextFieldController = TextEditingController();
  final TextEditingController keywordsTextFieldController = TextEditingController();
  final TextEditingController priceTextFieldController = TextEditingController();
}

String _keywordsToString(List<String> keywords) => keywords.join(', ');
List<String> _stringToKeywords(String s) => s.split(', ').toList();

String _authorsToString(List<Author> authors) => authors.map((a) => a.toText()).join('\n');
List<Author> _stringToAuthors(String s) => s.split('\n').map((line) => Author(firstName: '', lastName: line)).toList();

class _BookMetadataCollectingWidget extends StatefulWidget {
  const _BookMetadataCollectingWidget({required this.isbn, required this.metadatas});

  final String isbn;
  final _Metadata metadatas;

  @override
  State<_BookMetadataCollectingWidget> createState() => _BookMetadataCollectingWidgetState();
}

class _BookMetadataCollectingWidgetState extends State<_BookMetadataCollectingWidget> {
  @override
  void initState() {
    super.initState();
    final manualMD = widget.metadatas.providerMetadatas.mergeAllProvider();
    final controllers = widget.metadatas.bookControllerSet;
    controllers.titleTextFieldController.text = manualMD.title ?? '';
    controllers.authorsTextFieldController.text = _authorsToString(manualMD.authors);
    controllers.blurbTextFieldController.text = manualMD.blurb ?? '';
    controllers.keywordsTextFieldController.text = _keywordsToString(manualMD.keywords);
    if (manualMD.marketPrice.isEmpty) {
      controllers.priceTextFieldController.text = '';
    } else {
      final minMarketPrice = manualMD.marketPrice.min;
      controllers.priceTextFieldController.text = minMarketPrice.round().toString();
    }
  }

  void _updateManualBlurb(String newBlurb) {
    setState(() => widget.metadatas.bookControllerSet.blurbTextFieldController.text = newBlurb);
  }

  void _updateManualKeywords(String newKeywords) {
    setState(() => widget.metadatas.bookControllerSet.keywordsTextFieldController.text = newKeywords);
  }

  @override
  Widget build(BuildContext context) {
    const columnHeaderStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const providers = ProviderEnum.values;
    final iter = providers.map((provider) => widget.metadatas.providerMetadatas[provider]);
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SelectableText('ISBN: ${widget.isbn}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Table(
              children: [
                TableRow(
                    children: [
                  const Text('Manual', style: columnHeaderStyle),
                  ...providers.map((p) => Text(p.name, style: columnHeaderStyle))
                ].map((e) => Center(child: e)).toList()),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.titleTextFieldController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: 'Book title',
                    ),
                  ),
                  ...iter.map((data) => data == null ? _noneText : SelectableText(data.title ?? '')),
                ]),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.authorsTextFieldController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Authors',
                    ),
                  ),
                  ...iter.map((data) {
                    final authors = data?.authors;
                    if (authors == null || authors.isEmpty) {
                      return _noneText;
                    }
                    return SelectableText(_authorsToString(authors));
                  }),
                ]),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.blurbTextFieldController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      labelText: 'Book blurb',
                    ),
                  ),
                  ...iter.map((data) {
                    final blurb = data?.blurb;
                    if (blurb == null) {
                      return _noneText;
                    }
                    return _SelectableTextAndUse(
                      blurb,
                      onUse: (b) => _updateManualBlurb(b),
                    );
                  }),
                ]),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.keywordsTextFieldController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.manage_search),
                      labelText: 'Keywords',
                    ),
                  ),
                  ...iter.map((data) {
                    final keywords = data?.keywords;
                    if (keywords?.isEmpty ?? true) {
                      return _noneText;
                    }
                    return _SelectableTextAndUse(
                      _keywordsToString(keywords!),
                      onUse: (kw) => _updateManualKeywords(kw),
                    );
                  }),
                ]),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.priceTextFieldController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                    ],
                    decoration: const InputDecoration(
                      icon: Icon(Icons.euro),
                      labelText: 'Price',
                    ),
                  ),
                  ...iter.map((data) {
                    final marketPrices = data?.marketPrice.toList()?..sort();
                    if (marketPrices == null || marketPrices.isEmpty) {
                      return _noneText;
                    }
                    return SelectableText(
                      '${marketPrices.first.toStringAsFixed(2)} - ${marketPrices.last.toStringAsFixed(2)}',
                    );
                  }),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _noneText = Text('None', style: TextStyle(fontStyle: FontStyle.italic));

class _SelectableTextAndUse extends StatelessWidget {
  const _SelectableTextAndUse(this.s, {required this.onUse});
  final String s;
  final void Function(String) onUse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(onPressed: () => onUse(s), child: const Text('Use')),
        SelectableText(s),
      ],
    );
  }
}
