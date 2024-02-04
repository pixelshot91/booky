import 'package:booky/enrichment/ad_editing.dart';
import 'package:booky/helpers.dart';
import 'package:booky/localization.dart';
import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:booky/widgets/scrollable_bundle_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kt_dart/kt.dart';

import 'enrichment.dart';

/*

sealed class TextValue {}

class TextFromAutoMd {}
class ManualText {
  const ManualText(this.text);
  final String text;
}
*/
/*

enum ValueSource {
  autoMd,
  manual,
}

/// Able to distinguish:
///  - empty string, stored as text = '', ValueSource = manual
///    In this case, the field appear empty, with a hint
///  - 'No value, take the default one', stored as text = '', ValueSource = default
///    In this case the `default text` is shown, in a custom style
class TextWithDefaultValue {

}
*/

class BooksMetadataCollectingWidget extends StatefulWidget {
  const BooksMetadataCollectingWidget({required this.step});

  final MetadataCollectingStep step;

  @override
  State<BooksMetadataCollectingWidget> createState() => _BooksMetadataCollectingWidgetState();
}

class _Metadata {
  _Metadata({required this.providerMetadatas, required this.bookControllerSet});

  Map<rust.ProviderEnum, rust.BookMetaDataFromProvider?> providerMetadatas;
  final _BookControllerSet bookControllerSet;
}

class _BooksMetadataCollectingWidgetState extends State<BooksMetadataCollectingWidget> {
  KtMap<String, _Metadata>? controllers;

  @override
  void initState() {
    super.initState();

    Future(() async {
      final autoMd = await rust.getAutoMetadataFromBundle(path: widget.step.bundle.autoMetadataFile.path);
      final mergeMd = await rust.getMergedMetadataForBundle(bundlePath: widget.step.bundle.directory.path);
      final map = Map.fromEntries(autoMd.map((entry) {
        final bookControllerSet = _BookControllerSet();
        final mergeMDForBook = mergeMd.books.singleWhere((book) => book.isbn == entry.isbn);
        bookControllerSet.titleTextFieldController.text = mergeMDForBook.title ?? '';
        bookControllerSet.authorsTextFieldController.text = _authorsToString((mergeMDForBook.authors ?? []));
        bookControllerSet.blurbTextFieldController.text = mergeMDForBook.blurb ?? '';
        bookControllerSet.keywordsTextFieldController.text = _keywordsToString((mergeMDForBook.keywords ?? []));
        bookControllerSet.priceTextFieldController.text = mergeMDForBook.priceCent?.divide(100).toString() ?? '';
        return MapEntry(
            entry.isbn,
            _Metadata(
                providerMetadatas:
                    entry.metadatas.map((md) => MapEntry(md.provider, md.metadata)).let((e) => Map.fromEntries(e)),
                bookControllerSet: bookControllerSet));
      })).kt;

      if (mounted) {
        setState(() {
          // Use the order from metadata.json, and not the one coming from autoMd
          // (which is out of order because the json is a map so the Rust parser may not respect the order)
          controllers = Map.fromEntries(mergeMd.books.map((b) => MapEntry(b.isbn, map[b.isbn]!))).kt;
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
            notnull: (controllers) => Row(
                  children: [
                    Card(
                      child: SizedBox(
                        width: 100,
                        child: ScrollableBundleImages(widget.step.bundle, Axis.vertical),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...controllers.entries
                                .map((entry) => _BookMetadataCollectingWidget(
                                      isbn: entry.key,
                                      metadatas: entry.value,
                                    ))
                                .toList()
                                .dart,
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    final bundleMetadata = await rust.getMergedMetadataForBundle(
                                        bundlePath: widget.step.bundle.directory.path);
                                    bundleMetadata.books.forEach((book) {
                                      final bookController = controllers[book.isbn]!.bookControllerSet;
                                      book.title = bookController.titleTextFieldController.text;
                                      book.authors = _stringToAuthors(bookController.authorsTextFieldController.text);
                                      book.blurb = bookController.blurbTextFieldController.text;
                                      book.keywords =
                                          _stringToKeywords(bookController.keywordsTextFieldController.text);
                                      book.priceCent = double.parse(bookController.priceTextFieldController.text)
                                          .multiply(100)
                                          .round();
                                    });
                                    await rust.setManualMetadataForBundle(
                                        bundlePath: widget.step.bundle.directory.path, bundleMetadata: bundleMetadata);
                                    if (context.mounted) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                              builder: (context) => AdEditingWidget(
                                                      step: AdEditingStep(
                                                    bundle: widget.step.bundle,
                                                  ))));
                                    }
                                  },
                                  child: const Text('Validate Metadatas')),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
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

String _authorsToString(List<rust.Author> authors) => authors.map((a) => a.toText()).join('\n');

List<rust.Author> _stringToAuthors(String s) {
  if (s.isEmpty) return [];
  return s.split('\n').map((line) => rust.Author(firstName: '', lastName: line)).toList();
}

class _BookMetadataCollectingWidget extends StatefulWidget {
  const _BookMetadataCollectingWidget({required this.isbn, required this.metadatas});

  final String isbn;
  final _Metadata metadatas;

  @override
  State<_BookMetadataCollectingWidget> createState() => _BookMetadataCollectingWidgetState();
}

class _BookMetadataCollectingWidgetState extends State<_BookMetadataCollectingWidget> {
  /*@override
  void initState() {
    super.initState();
    final manualMD = widget.metadatas.providerMetadatas.mergeAllProvider();
    final controllers = widget.metadatas.bookControllerSet;
    /*if (controllers.titleTextFieldController.text.isEmpty) {
      controllers.titleTextFieldController.text = manualMD.title ?? '';
    }*/
    /*controllers.authorsTextFieldController.text = _authorsToString(manualMD.authors);
    controllers.blurbTextFieldController.text = manualMD.blurb ?? '';
    controllers.keywordsTextFieldController.text = _keywordsToString(manualMD.keywords);
    if (manualMD.marketPrice.isEmpty) {
      controllers.priceTextFieldController.text = '';
    } else {
      final minMarketPrice = manualMD.marketPrice.min;
      controllers.priceTextFieldController.text = minMarketPrice.round().toString();
    }*/
  }*/

  void _updateManualTitle(String newTitle) {
    setState(() => widget.metadatas.bookControllerSet.titleTextFieldController.text = newTitle);
  }

  void _updateManualAuthors(String newAuthors) {
    setState(() => widget.metadatas.bookControllerSet.authorsTextFieldController.text = newAuthors);
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
    const providers = rust.ProviderEnum.values;
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
                  ...providers.map((rust.ProviderEnum p) => Text(p.loc, style: columnHeaderStyle))
                ].map((e) => Center(child: e)).toList()),
                TableRow(children: [
                  TextFormField(
                    controller: widget.metadatas.bookControllerSet.titleTextFieldController,
                    maxLines: null,
                    contextMenuBuilder: recaseContextMenuBuilder,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: 'Book title',
                    ),
                  ),
                  ...iter.map((data) {
                    final title = data?.title;
                    if (title == null) return _noneText;
                    return _SelectableTextAndUse(
                      data!.title!,
                      onUse: _updateManualTitle,
                    );
                  }),
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
                    return _SelectableTextAndUse(
                      _authorsToString(authors),
                      onUse: _updateManualAuthors,
                    );
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
