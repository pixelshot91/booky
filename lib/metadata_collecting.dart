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
  final BookMetaData manual;
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
      body: SingleChildScrollView(
        child: Column(
          children: widget.step.isbns.map((isbn) {
            final manual = metadata[isbn]!.manual;
            return Card(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  SelectableText('ISBN: $isbn'),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text('Manual'),
                        Text('Babelio'),
                        Text('GoogleBooks'),
                        TextFormField(
                          initialValue: manual.title,
                          onChanged: (newText) => setState(() => manual.title = newText),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.title),
                            labelText: 'Book title',
                          ),
                          style: const TextStyle(fontSize: 30),
                        ),
                        ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureBuilder(
                            future: e.value, builder: (context, snapMD) => SelectableText(snapMD.data!.title))),
                        TextFormField(
                          initialValue: manual.blurb,
                          onChanged: (newText) => setState(() => manual.blurb = newText),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            labelText: 'Book blurb',
                          ),
                          style: const TextStyle(fontSize: 30),
                        ),
                        ...metadata[isbn]!.mdFromProviders.entries.map((e) => FutureBuilder(
                            future: e.value,
                            builder: (context, snapMD) {
                              final blurb = snapMD.data!.blurb;
                              if (blurb == null) return Text('None', style: TextStyle(fontStyle: FontStyle.italic));
                              return SelectableText(blurb);
                            }))
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
