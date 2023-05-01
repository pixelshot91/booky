import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

      return BundleList(bundles, onSubmit: widget.onSubmit);
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

class BundleList extends StatefulWidget {
  const BundleList(this.bundles, {required this.onSubmit});
  final Iterable<Bundle> bundles;

  final void Function(ISBNDecodingStep newStep) onSubmit;

  @override
  State<BundleList> createState() => _BundleListState();
}

class _BundleListState extends State<BundleList> {
  @override
  void initState() {
    super.initState();
    for (final bundle in widget.bundles) {
      for (final image in bundle.images) {
        final segments = path.split(image.path);
        segments.insert(segments.length - 1, 'compressed');
        print('new path ${path.joinAll(segments)}');
        final targetPath = path.joinAll(segments);
        if (!File(targetPath).existsSync()) {
          _testCompressAndGetFile(image, targetPath);
        }
      }
    }
  }

  Future<File?> _testCompressAndGetFile(File file, String targetPath) async {
    await Directory(path.dirname(targetPath)).create();
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minHeight: 800,
      minWidth: 800,
      quality: 70,
    );

    print(file.lengthSync());
    print(result?.lengthSync());

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 500,
      childAspectRatio: 2,
      children: widget.bundles
          .map((bundle) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  child: BundleWidget(bundle, onDelete: () {
                    setState(() {});
                  }),
                  onTap: () {
                    widget.onSubmit(ISBNDecodingStep(bundle: bundle));
                  },
                ),
              ))
          .toList(),
    );
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
                ...bundle.compressedImages
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
