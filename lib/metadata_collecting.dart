import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/common.dart';

import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'main.dart';

const noneText = Text('None', style: TextStyle(fontStyle: FontStyle.italic));

class MetadataCollectingWidget extends StatefulWidget {
  const MetadataCollectingWidget({required this.step, required this.onSubmit});
  final MetadataCollectingStep step;
  final void Function(AdEditingStep newStep) onSubmit;

  @override
  State<MetadataCollectingWidget> createState() => _MetadataCollectingWidgetState();
}

class Metadatas {
  final Map<ProviderEnum, Future<BookMetaData?>> mdFromProviders;
  BookMetaData manual;
  Metadatas({required this.mdFromProviders, required this.manual});
}

class _MetadataCollectingWidgetState extends State<MetadataCollectingWidget> {
  Map<String, Metadatas> metadata = {};

  @override
  void initState() {
    super.initState();
    widget.step.isbns.forEach((isbn) {
      metadata.putIfAbsent(
          isbn,
          () => Metadatas(
              manual: BookMetaData(title: '', authors: [], keywords: []),
              mdFromProviders: Map.fromEntries(ProviderEnum.values.map((provider) {
                final md = api.getMetadataFromProvider(provider: provider, isbn: isbn);
                if (provider == ProviderEnum.Babelio) {
                  md.then((value) {
                    if (value != null) {
                      metadata[isbn]!.manual = value;
                    }
                  });
                }
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
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SelectableText('ISBN: $isbn'),
                      Expanded(
                        child: Table(
                          children: [
                            const TableRow(children: [
                              Text('Manual'),
                              Text('Babelio'),
                              Text('GoogleBooks'),
                            ]),
                            TableRow(children: [
                              FutureWidget(
                                  future: metadata[isbn]!.mdFromProviders.entries.first.value,
                                  builder: (data) => TextFormField(
                                        initialValue: data?.title,
                                        onChanged: (newText) => setState(() => manual.title = newText),
                                        decoration: const InputDecoration(
                                          icon: Icon(Icons.title),
                                          labelText: 'Book title',
                                        ),
                                      )),
                              ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureWidget(
                                  future: e.value,
                                  builder: (data) => data == null ? noneText : SelectableText(data.title))),
                            ]),
                            TableRow(children: [
                              FutureWidget(
                                future: metadata[isbn]!.mdFromProviders.entries.first.value,
                                builder: (data) => TextFormField(
                                  initialValue: data?.authors.toText(),
                                  onChanged: (newText) => setState(() => manual.authors = newText
                                      .split('\n')
                                      .map((line) => Author(firstName: '', lastName: line))
                                      .toList()),
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
                                        initialValue: data?.blurb,
                                        onChanged: (newText) => setState(() => manual.blurb = newText),
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
                                    return SelectableText(blurb);
                                  })),
                            ]),
                          ],
                        ),
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
                        imgsPaths: widget.step.imgsPaths,
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
