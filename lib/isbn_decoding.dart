import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';

import 'common.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step, required this.onSubmit});
  final ISBNDecodingStep step;
  final void Function(MetadataCollectingStep newStep) onSubmit;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  Map<String, Future<List<String>>> isbns = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('initState');
    widget.step.imgsPaths.forEach((imgPath) {
      isbns[imgPath] = Future(() async {
        final decoder_process = await Process.run(
            '/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode',
            ['-in=' + imgPath]);
        if (decoder_process.exitCode != 0) {
          print('stdout is ${decoder_process.stdout}');
          print('stderr is ${decoder_process.stderr}');
          throw Exception('decoder status is ${decoder_process.exitCode}');
        }
        final s = decoder_process.stdout as String;
        return s.split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ...widget.step.imgsPaths
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
          Spacer(),
          FutureBuilder(
              future: Future.wait(isbns.values),
              builder: (context, snap) {
                return ElevatedButton(
                    onPressed: () {
                      final isbnSet = snap.data!.expand((e) => e).toSet();
                      print('isbnSet = $isbnSet');
                      widget.onSubmit(MetadataCollectingStep(imgsPaths: widget.step.imgsPaths, isbns: isbnSet));
                    },
                    child: const Text('Validate ISBNs'));
              })
        ],
      ),
    );
  }
}
