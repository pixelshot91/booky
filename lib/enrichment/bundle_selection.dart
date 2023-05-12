import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_rust_bridge_template/camera/camera.dart';
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../ffi.dart';
import '../helpers.dart';
import 'enrichment.dart';
import 'isbn_decoding.dart';

class BundleSelection extends StatefulWidget {
  const BundleSelection();

  @override
  State<BundleSelection> createState() => _BundleSelectionState();
}

class _BundleSelectionState extends State<BundleSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bundle Section'),
          actions: [
            IconButton(
              icon: const Icon(Icons.cloud_download),
              onPressed: () async {
                _listBundles().forEach((bundle) async {
                  final isbnsList = await Future.wait(bundle.images.map((img) => common.extractIsbnsFromImage(img)));
                  Set<String> isbns = isbnsList.expand((i) => i).toSet();
                  await api.getMetadataFromIsbns(
                    isbns: isbns.toList(),
                    path: bundle.autoMetadataFile.path,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Json wrote to file')));
                  }
                });
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.camera),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const CameraWidget()))),
        body: _getBody());
  }

  Widget _getBody() {
    try {
      final bundles = _listBundles();

      return BundleList(bundles);
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

  static Iterable<Bundle> _listBundles() {
    return common.bookyDir
        .listSync()
        .whereType<Directory>()
        .sorted((d1, d2) => d1.path.compareTo(d2.path))
        .map((d) => Bundle(d));
  }
}

class BundleList extends StatefulWidget {
  const BundleList(this.bundles);
  final Iterable<Bundle> bundles;

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
          .map((bundle) => GestureDetector(
                child: BundleWidget(bundle, onDelete: () {
                  setState(() {});
                }),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => ISBNDecodingWidget(
                                step: ISBNDecodingStep(bundle: bundle),
                              )));
                },
              ))
          .toList(),
    );
  }
}

class BundleWidget extends StatefulWidget {
  const BundleWidget(this.bundle, {required this.onDelete});

  final Bundle bundle;
  final void Function() onDelete;

  @override
  State<BundleWidget> createState() => _BundleWidgetState();
}

class _BundleWidgetState extends State<BundleWidget> {
  late Future<List<ISBNMetadataPair>> cachedAutoMetadata;
  @override
  void initState() {
    super.initState();
    cachedAutoMetadata = api.getAutoMetadataFromBundle(path: widget.bundle.autoMetadataFile.path);
  }

  @override
  Widget build(BuildContext context) {
    const maxImagesShown = 3;
    final imagesShown = widget.bundle.compressedImages
        .take(maxImagesShown)
        .mapIndexed((index, f) {
          final thumbnail = ImageWidget(f);
          if (index == maxImagesShown - 1) {
            final nbImagesNotShown = widget.bundle.compressedImages.length - maxImagesShown;
            if (nbImagesNotShown > 0) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      thumbnail,
                      Positioned.fill(child: ColoredBox(color: Colors.black.withOpacity(0.3))),
                      Text(
                        '+$nbImagesNotShown',
                        style: const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  );
                },
              );
            }
          }
          return thumbnail;
        })
        .map((w) => Padding(padding: const EdgeInsets.all(8.0), child: w))
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            // Text(path.basename(widget.bundle.directory.path)),
            FutureWidget(
                future: cachedAutoMetadata,
                builder: (autoMetadata) {
                  final firstBook = autoMetadata.firstOrNull;
                  if (firstBook == null) return const Text('No book identified');
                  final md = firstBook.metadatas.mergeAllProvider();
                  final priceRange = md.marketPrice.toList();
                  return Row(children: [
                    // Text(firstBook.isbn),
                    Expanded(
                        child: md.title.ifIs(
                            notnull: (t) => TextWithTooltip(t),
                            nul: () => const Text(
                                  'No title found',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ))),
                    priceRange.isEmpty
                        ? const Text('?')
                        : Text('${priceRange.first.toInt()} - ${priceRange.last.toInt()} €'),
                  ]);
                }),
            Expanded(
              child: Row(
                children: [
                  ...imagesShown,
                  const Expanded(child: SizedBox.expand()),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (Platform.isLinux)
                        IconButton(
                            onPressed: () => Process.run('pcmanfm', [widget.bundle.directory.path]),
                            icon: const Icon(Icons.open_in_new)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          final segments = path.split(widget.bundle.directory.path);
                          segments[segments.length - 2] = 'booky_deleted';
                          widget.bundle.directory.renameSync(path.joinAll(segments));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Deleted'),
                          ));
                          widget.onDelete();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
