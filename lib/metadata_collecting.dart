import 'package:flutter/material.dart';

import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'main.dart';

class MetadataCollectingWidget extends StatefulWidget {
  const MetadataCollectingWidget({required this.step, required this.onSubmit});
  final MetadataCollectingStep step;
  final void Function(AdEditingStep newStep) onSubmit;

  @override
  State<MetadataCollectingWidget> createState() => _MetadataCollectingWidgetState();
}

class Metadatas {
  final Map<ProviderEnum, Future<BookMetaData>> mdFromProviders;
  final BookMetaData manual; // = BookMetaData(title: '', authors: [], keywords: []);
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
              mdFromProviders: Map.fromEntries(ProviderEnum.values.map((provider) => MapEntry(
                  provider, api.getMetadataFromProvider(provider: provider, isbn: isbn).then((value) => value!))))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: widget.step.isbns.map((isbn) {
          // metadata[isbn].
          // if (metadata[isbn] == null) {
          //   metadata.a
          // }
          // if
          final manual = metadata[isbn]!.manual;

          return Row(
            children: [
              // ImageWidget(imgPath),
              Text('ISBN: $isbn'),
              Column(
                children: [
                  TextFormField(
                    initialValue: manual.title,
                    onChanged: (newText) => setState(() => manual.title = newText),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: 'Book title',
                    ),
                    style: const TextStyle(fontSize: 30),
                  ),
                  TextFormField(
                    initialValue: manual.blurb,
                    onChanged: (newText) => setState(() => manual.blurb = newText),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Book blurb',
                    ),
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              ),
              ...metadata[isbn]!.mdFromProviders.entries.map((entry) => Text(entry.key.name)
                  /*FutureBuilder(
          future: metadata[isbn],
          builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
          }
          final book = snap.data!;

          return Column(children: [

          ]),
          })*/
                  ),

              // ...isbns[imgPath]?.map((isbn) => Text(isbn)).toList() ?? [Text('no ISBN')],
            ],
          );
        }).toList(),
      ),
    );
  }
}
