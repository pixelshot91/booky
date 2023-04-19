import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';
import 'package:path/path.dart' as path;

import 'bundle.dart';

class BundleSelection extends StatelessWidget {
  const BundleSelection({required this.onSubmit});

  final void Function(ISBNDecodingStep newStep) onSubmit;

  @override
  Widget build(BuildContext context) {
    final bundleDirs =
        Directory('/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/DCIM/booky/')
            .listSync()
            .whereType<Directory>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bundle Section')),
      body: Wrap(
        children: bundleDirs
            .map((d) => Padding(
                  padding: const EdgeInsets.all(8.0),
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
    return Column(
      children: [
        Container(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Wrap(
              children: directory
                  .listSync()
                  .whereType<File>()
                  .where((f) => path.extension(f.path) == '.jpg')
                  .sorted((f1, f2) => f1.lastModifiedSync().compareTo(f2.lastModifiedSync()))
                  .map((f) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          f,
                          height: 150,
                          filterQuality: FilterQuality.medium,
                        ),
                      ))
                  .toList(),
            )),
        Text(path.basename(directory.path))
      ],
    );
  }
}
