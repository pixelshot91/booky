import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';

import 'helpers.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step, required this.onSubmit});
  final ISBNDecodingStep step;
  final void Function(MetadataCollectingStep newStep) onSubmit;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  // TODO: Don't use Map because operator[] accept Object as parameter instead of o Key type
  Map<String, Future<List<String>>> isbns = {};

  @override
  void initState() {
    super.initState();
    widget.step.bundle.images.forEach((image) {
      final imgPath = image.path;
      isbns[imgPath] = Future(() async {
        final decoderProcess = await Process.run(
            '/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode',
            ['-in=' + imgPath]);
        if (decoderProcess.exitCode != 0) {
          print('stdout is ${decoderProcess.stdout}');
          print('stderr is ${decoderProcess.stderr}');
          throw Exception('decoder status is ${decoderProcess.exitCode}');
        }
        final s = decoderProcess.stdout as String;
        return s.split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Wrap(
            children: [
              ...widget.step.bundle.images
                  .map((imgPath) => Column(
                        children: [
                          ImageWidget(imgPath),
                          FutureBuilder(
                              future: isbns[imgPath]!,
                              builder: (context, snap) {
                                if (snap.hasData == false) {
                                  return const CircularProgressIndicator();
                                }
                                return Column(children: snap.data!.map((isbn) => Text(isbn)).toList());
                              })
                        ],
                      ))
                  .toList(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
                future: Future.wait(isbns.values),
                builder: (context, snap) {
                  return ElevatedButton(
                      onPressed: () {
                        final isbnSet = snap.data!.expand((e) => e).toSet();
                        print('isbnSet = $isbnSet');
                        widget.onSubmit(MetadataCollectingStep(bundle: widget.step.bundle, isbns: isbnSet));
                      },
                      child: const Text('Validate ISBNs'));
                }),
          )
        ],
      ),
    );
  }
}
