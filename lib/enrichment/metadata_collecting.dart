import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge_template/enrichment/ad_editing.dart';
import 'package:flutter_rust_bridge_template/helpers.dart';

import '../ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'enrichment.dart';

class BooksMetadataCollectingWidget extends StatefulWidget {
  const BooksMetadataCollectingWidget({required this.step});

  final MetadataCollectingStep step;
  @override
  State<BooksMetadataCollectingWidget> createState() => _BooksMetadataCollectingWidgetState();
}

class _BooksMetadataCollectingWidgetState extends State<BooksMetadataCollectingWidget> {
  late Map<String, _BookControllerSet> controllers;

  @override
  void initState() {
    super.initState();
    controllers = Map.fromEntries(widget.step.isbns.map((isbn) => MapEntry(isbn, _BookControllerSet())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata Collecting'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...controllers.entries
                .map((entry) => _BookMetadataCollectingWidget(
                      isbn: entry.key,
                      controllers: entry.value,
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
                                          title: value.titleTextFieldController.text,
                                          authors: value.authorsTextFieldController.text
                                              .split('\n')
                                              .map((line) => Author(firstName: '', lastName: line))
                                              .toList(),
                                          blurb: value.blurbTextFieldController.text,
                                          keywords: [],
                                          priceCent:
                                              double.parse(value.priceTextFieldController.text).multiply(100).round(),
                                        )))))));
                  },
                  child: const Text('Validate Metadatas')),
            )
          ],
        ),
      ),
    );
  }
}

class _BookControllerSet {
  final TextEditingController titleTextFieldController = TextEditingController();
  final TextEditingController authorsTextFieldController = TextEditingController();
  final TextEditingController blurbTextFieldController = TextEditingController();
  final TextEditingController priceTextFieldController = TextEditingController();
}

class _BookMetadataCollectingWidget extends StatefulWidget {
  const _BookMetadataCollectingWidget({required this.isbn, required this.controllers});

  final String isbn;
  final _BookControllerSet controllers;

  @override
  State<_BookMetadataCollectingWidget> createState() => _BookMetadataCollectingWidgetState();
}

class _BookMetadataCollectingWidgetState extends State<_BookMetadataCollectingWidget> {
  late Map<ProviderEnum, Future<BookMetaDataFromProvider?>> metadata;

  @override
  void initState() {
    super.initState();
    final isbn = widget.isbn;
    metadata = Map.fromEntries(ProviderEnum.values.map((provider) {
      final md = api.getMetadataFromProvider(provider: provider, isbn: isbn);
      md.then((value) {
        if (value != null) {
          _replaceIfBetterString(value.title, widget.controllers.titleTextFieldController.text, () {
            _updateManualTitle(value.title!);
          });

          final joinedAuthors = value.authors.toText();
          _replaceIfBetterString(joinedAuthors, widget.controllers.authorsTextFieldController.text, () {
            _updateManualAuthors(joinedAuthors);
          });
          _replaceIfBetterString(value.blurb, widget.controllers.blurbTextFieldController.text, () {
            _updateManualBlurb(value.blurb!);
          });
          // TODO: handle keywords
        }
      });
      return MapEntry(provider, md);
    }));
  }

  void _replaceIfBetterString(String? providerStr, String manualStr, void Function() onReplace) {
    if (providerStr == null || manualStr.length > providerStr.length) return;
    onReplace();
  }

  void _updateManualTitle(String newTitle) {
    setState(() => widget.controllers.titleTextFieldController.text = newTitle);
  }

  void _updateManualAuthors(String newAuthor) {
    setState(() => widget.controllers.authorsTextFieldController.text = newAuthor);
  }

  void _updateManualBlurb(String newBlurb) {
    setState(() => widget.controllers.blurbTextFieldController.text = newBlurb);
  }

  @override
  Widget build(BuildContext context) {
    const columnHeaderStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
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
                  const Text('Babelio', style: columnHeaderStyle),
                  const Text('GoogleBooks', style: columnHeaderStyle),
                  const Text('BooksPrice', style: columnHeaderStyle),
                ].map((e) => Center(child: e)).toList()),
                TableRow(children: [
                  FutureWidget(
                      future: metadata.entries.first.value,
                      builder: (data) => TextFormField(
                            controller: widget.controllers.titleTextFieldController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.title),
                              labelText: 'Book title',
                            ),
                          )),
                  ...metadata.entries.map((e) => FutureWidget(
                      future: e.value, builder: (data) => data == null ? _noneText : SelectableText(data.title ?? ''))),
                ]),
                TableRow(children: [
                  FutureWidget(
                    future: metadata.entries.first.value,
                    builder: (data) => TextFormField(
                      controller: widget.controllers.authorsTextFieldController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Authors',
                      ),
                    ),
                  ),
                  ...metadata.entries.map((e) => FutureWidget(
                      future: e.value,
                      builder: (data) {
                        final authors = data?.authors;
                        if (authors == null || authors.isEmpty) {
                          return _noneText;
                        }
                        return SelectableText(authors.toText());
                      })),
                ]),
                TableRow(children: [
                  FutureWidget(
                      future: metadata.entries.first.value,
                      builder: (data) => TextFormField(
                            controller: widget.controllers.blurbTextFieldController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.description),
                              labelText: 'Book blurb',
                            ),
                          )),
                  ...metadata.entries.map((e) => FutureWidget(
                      future: e.value,
                      builder: (data) {
                        final blurb = data?.blurb;
                        if (blurb == null) {
                          return _noneText;
                        }
                        return _SelectableTextAndUse(
                          blurb,
                          onUse: (b) => _updateManualBlurb(b),
                        );
                      })),
                ]),
                TableRow(children: [
                  FutureWidget(
                      future: metadata.entries.first.value,
                      builder: (data) => TextFormField(
                            controller: widget.controllers.priceTextFieldController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                            ],
                            decoration: const InputDecoration(
                              icon: Icon(Icons.euro),
                              labelText: 'Price',
                            ),
                          )),
                  ...metadata.entries.map((e) => FutureWidget(
                      future: e.value,
                      builder: (data) {
                        final marketPrices = data?.marketPrice.toList()?..sort();
                        if (marketPrices == null || marketPrices.isEmpty) {
                          return _noneText;
                        }
                        return SelectableText(
                          '${marketPrices.first.toStringAsFixed(2)} - ${marketPrices.last.toStringAsFixed(2)}',
                        );
                      })),
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
