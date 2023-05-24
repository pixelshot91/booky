import 'package:flutter/material.dart';
import 'package:kt_dart/collection.dart';

import '../common.dart' as common;
import '../helpers.dart';
import 'enrichment.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step});
  final ISBNDecodingStep step;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  KtMutableMap<String, Future<List<String>>> decodedIsbns = KtMutableMap.empty();
  KtMutableSet<String> selectedIsbns = KtMutableSet.empty();

  @override
  void initState() {
    super.initState();
    widget.step.bundle.images.forEach((image) {
      decodedIsbns[image.path] = common.extractIsbnsFromImage(image);
    });
    selectedIsbns = (widget.step.bundle.metadata.isbns ?? []).toSet().kt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISBN decoding')),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                children: widget.step.bundle.images
                    .map((imgPath) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(height: 600, child: ImageWidget(imgPath)),
                                FutureBuilder(
                                    future: decodedIsbns[imgPath.path]!,
                                    builder: (context, snap) {
                                      if (snap.hasData == false) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Column(
                                          children: snap.data!
                                              .map(
                                                (isbn) => Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: ElevatedButton(
                                                      onPressed: selectedIsbns.contains(isbn)
                                                          ? null
                                                          : () => setState(() => selectedIsbns.add(isbn)),
                                                      child: Text(
                                                        isbn,
                                                        style: TextStyle(
                                                            decoration: isbn.startsWith('978')
                                                                ? null
                                                                : TextDecoration.lineThrough),
                                                      )),
                                                ),
                                              )
                                              .toList());
                                    })
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onSubmitted: (newIsbn) {
                          setState(() => selectedIsbns.add(newIsbn));
                        },
                        decoration: const InputDecoration(hintText: 'Type manually the ISBN here'),
                      ),
                      const SizedBox(height: 20),
                      ...selectedIsbns.iter.map((isbn) => Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() => selectedIsbns.remove(isbn));
                                },
                              ),
                              Text(isbn),
                            ],
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            final md = widget.step.bundle.metadata;
                            md.isbns = selectedIsbns.toList().asList();
                            final res = await widget.step.bundle.overwriteMetadata(md);
                            print('res = $res');
                            if (!mounted) return;
                            if (res) {
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error while trying to update metadata.json')));
                            }
                          },
                          child: const Text('Validate ISBNs')),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
