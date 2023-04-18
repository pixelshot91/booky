import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge_template/helpers.dart';

import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'main.dart';

const noneText = Text('None', style: TextStyle(fontStyle: FontStyle.italic));

class SelectableTextAndUse extends StatelessWidget {
  const SelectableTextAndUse(this.s, {required this.onUse});
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

class MetadataCollectingWidget extends StatefulWidget {
  MetadataCollectingWidget({required this.step, required this.onSubmit});
  final MetadataCollectingStep step;
  final void Function(AdEditingStep newStep) onSubmit;

  final blurbTextFieldController = TextEditingController();
  final titleTextFieldController = TextEditingController();
  final priceTextFieldController = TextEditingController();

  @override
  State<MetadataCollectingWidget> createState() => _MetadataCollectingWidgetState();
}

class Metadatas {
  final Map<ProviderEnum, Future<BookMetaDataFromProvider?>> mdFromProviders;
  BookMetaDataManual manual;
  Metadatas({required this.mdFromProviders, required this.manual});
}

class _MetadataCollectingWidgetState extends State<MetadataCollectingWidget> {
  Map<String, Metadatas> metadata = {};

  void replaceIfBetterString(String? providerStr, String manualStr, void Function() onReplace) {
    if (providerStr == null || manualStr.length > providerStr.length) return;
    onReplace();
  }

  void _updateManualTitle(String isbn, String newTitle) {
    setState(() {
      metadata[isbn]!.manual.title = newTitle;
      widget.titleTextFieldController.text = newTitle;
    });
  }

  void _updateManualBlurb(String isbn, String newBlurb) {
    setState(() {
      metadata[isbn]!.manual.blurb = newBlurb;
      widget.blurbTextFieldController.text = newBlurb;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.step.isbns.forEach((isbn) {
      metadata.putIfAbsent(
          isbn,
          () => Metadatas(
              manual: BookMetaDataManual(title: '', authors: [], blurb: '', keywords: [], priceCent: null),
              mdFromProviders: Map.fromEntries(ProviderEnum.values.map((provider) {
                final md = api.getMetadataFromProvider(provider: provider, isbn: isbn);
                md.then((value) {
                  if (value != null) {
                    replaceIfBetterString(value.title, metadata[isbn]!.manual.title!, () {
                      _updateManualTitle(isbn, value.title!);
                    });
                    replaceIfBetterString(value.blurb, metadata[isbn]!.manual.blurb!, () {
                      _updateManualBlurb(isbn, value.blurb!);
                    });
                  }
                });
                return MapEntry(provider, md);
              }))));
    });
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
            ...widget.step.isbns.map((isbn) {
              final manual = metadata[isbn]!.manual;
              const columnHeaderStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SelectableText('ISBN: $isbn', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                                future: metadata[isbn]!.mdFromProviders.entries.first.value,
                                builder: (data) => TextFormField(
                                      controller: widget.titleTextFieldController,
                                      onChanged: (newText) => setState(() => manual.title = newText),
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.title),
                                        labelText: 'Book title',
                                      ),
                                    )),
                            ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureWidget(
                                future: e.value,
                                builder: (data) => data == null ? noneText : SelectableText(data.title ?? ''))),
                          ]),
                          TableRow(children: [
                            FutureWidget(
                              future: metadata[isbn]!.mdFromProviders.entries.first.value,
                              builder: (data) => TextFormField(
                                initialValue: data?.authors.toText(),
                                onChanged: (newText) => setState(() => manual.authors =
                                    newText.split('\n').map((line) => Author(firstName: '', lastName: line)).toList()),
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  labelText: 'Authors',
                                ),
                              ),
                            ),
                            ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureWidget(
                                future: e.value,
                                builder: (data) {
                                  final authors = data?.authors;
                                  if (authors == null || authors.isEmpty) {
                                    return noneText;
                                  }
                                  return SelectableText(authors.toText());
                                })),
                          ]),
                          TableRow(children: [
                            FutureWidget(
                                future: metadata[isbn]!.mdFromProviders.entries.first.value,
                                builder: (data) => TextFormField(
                                      controller: widget.blurbTextFieldController,
                                      onChanged: (newText) => setState(() => metadata[isbn]!.manual.blurb = newText),
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.description),
                                        labelText: 'Book blurb',
                                      ),
                                    )),
                            ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureWidget(
                                future: e.value,
                                builder: (data) {
                                  final blurb = data?.blurb;
                                  if (blurb == null) {
                                    return noneText;
                                  }
                                  return SelectableTextAndUse(
                                    blurb,
                                    onUse: (b) => _updateManualBlurb(isbn, b),
                                  );
                                })),
                          ]),
                          TableRow(children: [
                            FutureWidget(
                                future: metadata[isbn]!.mdFromProviders.entries.first.value,
                                builder: (data) => TextFormField(
                                      controller: widget.priceTextFieldController,
                                      onChanged: (newText) => setState(() => metadata[isbn]!.manual.priceCent =
                                          double.parse(newText).multiply(100).round()),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                      ],
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.euro),
                                        labelText: 'Price',
                                      ),
                                    )),
                            ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureWidget(
                                future: e.value,
                                builder: (data) {
                                  final marketPrices = data?.marketPrice.toList()?..sort();
                                  if (marketPrices == null || marketPrices.isEmpty) {
                                    return noneText;
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
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(AdEditingStep(
                        bundle: widget.step.bundle,
                        metadata: metadata.map((key, value) => MapEntry(key, value.manual))));
                  },
                  child: const Text('Validate Metadatas')),
            )
          ],
        ),
      ),
    );
  }
}
