import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../helpers.dart';
import 'enrichment.dart';

class BundleSelection extends StatelessWidget {
  const BundleSelection({required this.onSubmit});

  final void Function(ISBNDecodingStep newStep) onSubmit;

  @override
  Widget build(BuildContext context) {
    final bundleDirs = common.bookyDir.listSync().whereType<Directory>().sorted((d1, d2) => d1.path.compareTo(d2.path));

    return Scaffold(
      appBar: AppBar(title: const Text('Bundle Section')),
      body: GridView.extent(
        maxCrossAxisExtent: 500,
        childAspectRatio: 2,
        children: bundleDirs
            .map((d) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    child: BundleWidget(d),
                    onTap: () => onSubmit(ISBNDecodingStep(bundle: Bundle(d))),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class BundleWidget extends StatelessWidget {
  const BundleWidget(this.directory);

  final Directory directory;

  @override
  Widget build(BuildContext context) {
    return Card(
      // decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        children: [
          Text(path.basename(directory.path)),
          Expanded(
            child: Row(
              children: [
                ...directory
                    .listSync()
                    .whereType<File>()
                    .where((f) => path.extension(f.path) == '.jpg')
                    .sorted((f1, f2) => f1.lastModifiedSync().compareTo(f2.lastModifiedSync()))
                    .map((f) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageWidget(f),
                        ))
                    .toList(),
                const Expanded(child: SizedBox.expand()),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}