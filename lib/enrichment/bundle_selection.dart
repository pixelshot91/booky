import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../helpers.dart';
import 'enrichment.dart';

class BundleSelection extends StatefulWidget {
  const BundleSelection({required this.onSubmit});

  final void Function(ISBNDecodingStep newStep) onSubmit;

  @override
  State<BundleSelection> createState() => _BundleSelectionState();
}

class _BundleSelectionState extends State<BundleSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Bundle Section')), body: _getBody());
  }

  Widget _getBody() {
    try {
      final bundles = common.bookyDir
          .listSync()
          .whereType<Directory>()
          .sorted((d1, d2) => d1.path.compareTo(d2.path))
          .map((d) => Bundle(d));

      return GridView.extent(
        maxCrossAxisExtent: 500,
        childAspectRatio: 2,
        children: bundles
            .map((bundle) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    child: BundleWidget(bundle, onDelete: () {
                      setState(() {});
                    }),
                    onTap: () => widget.onSubmit(ISBNDecodingStep(bundle: bundle)),
                  ),
                ))
            .toList(),
      );
    } catch (e) {
      if (e is PathNotFoundException || e is FileSystemException) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Device not connected',
                style: TextStyle(fontSize: 30),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        );
      }
      rethrow;
    }
  }
}

class BundleWidget extends StatelessWidget {
  const BundleWidget(this.bundle, {required this.onDelete});

  final Bundle bundle;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      // decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        children: [
          Text(path.basename(bundle.directory.path)),
          Expanded(
            child: Row(
              children: [
                ...bundle.images
                    .map((f) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageWidget(f),
                        ))
                    .toList(),
                const Expanded(child: SizedBox.expand()),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final segments = path.split(bundle.directory.path);
                    segments[segments.length - 2] = 'booky_deleted';
                    bundle.directory.renameSync(path.joinAll(segments));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Deleted'),
                    ));
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
