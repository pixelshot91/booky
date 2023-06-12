import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter_rust_bridge_template/camera/camera.dart';
import 'package:flutter_rust_bridge_template/enrichment/isbn_decoding.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart' as path;

import '../bundle.dart';
import '../common.dart' as common;
import '../ffi.dart';
import '../helpers.dart';
import 'enrichment.dart';
import 'metadata_collecting.dart';

class BundleSelection extends StatefulWidget {
  const BundleSelection();

  @override
  State<BundleSelection> createState() => _BundleSelectionState();
}

class _BundleSelectionState extends State<BundleSelection> {
  int? bundleNb;
  int? compressedBundleNb;
  int? autoMdCollectedBundleNb;

  @override
  void initState() {
    super.initState();
    _listBundles()?.let((bundles) => _compressedAllBundleImages(bundles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bundle Section'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
                _listBundles()?.let((bundles) => _compressedAllBundleImages(bundles));
              },
            ),
            IconButton(
              icon: const Icon(Icons.cloud_download),
              onPressed: () async {
                final listBundles = _listBundles();
                if (listBundles == null) {
                  return;
                }
                setState(() {
                  bundleNb = listBundles.length;
                  autoMdCollectedBundleNb = 0;
                });
                listBundles.forEach((bundle) async {
                  if (await bundle.autoMetadataFile.exists()) {
                    if (mounted) {
                      setState(() {
                        autoMdCollectedBundleNb = autoMdCollectedBundleNb! + 1;
                      });
                    }
                    return;
                  }
                  Set<String> isbns = bundle.metadata.isbns?.toSet() ?? {};

                  try {
                    await api.getMetadataFromIsbns(
                      isbns: isbns.toList(),
                      path: bundle.autoMetadataFile.path,
                    );
                  } on FfiException catch (e) {
                    print(
                        'FfiException thrown during getMetadataFromIsbns with isbns=${isbns.toList()}, path=${bundle.autoMetadataFile.path}');
                    print('exception is $e');
                  }
                  if (mounted) {
                    setState(() {
                      autoMdCollectedBundleNb = autoMdCollectedBundleNb! + 1;
                    });
                  }
                });
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<void>(
                    child: const Text('Invalidate all metadata from provider'),
                    onTap: () async {
                      final bundleList = _listBundles();
                      if (bundleList == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Error while listing bundles')));
                        return;
                      }

                      final res = await bundleList
                          .map((bundle) => bundle.removeAutoMetadata())
                          .let((futures) => Future.wait(futures));
                      if (mounted) {
                        if (res.every((e) => e)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All automatic metadata have been invalidated')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error while invalidating automatic metadata')));
                        }
                      }
                    },
                  )
                ];
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.camera),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const CameraWidget()))),
        body: _getBody());
  }

  Widget _getBody() {
    final bundles = _listBundles();

    if (bundles == null) {
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
    return _bundleListWidget(bundles);
  }

  static Iterable<Bundle>? _listBundles() {
    try {
      return common.bookyDir
          .listSync()
          .whereType<Directory>()
          .sorted((d1, d2) => d1.path.compareTo(d2.path))
          .map((d) => Bundle(d));
    } catch (e) {
      if (e is PathNotFoundException || e is FileSystemException) {
        return null;
      }
      print('Unhandled exception $e');
      rethrow;
    }
  }

  Future<void> _compressedAllBundleImages(Iterable<Bundle> bundles) async {
    if (!Platform.isAndroid) return;
    if (mounted) {
      setState(() {
        bundleNb = bundles.length;
        compressedBundleNb = 0;
      });
    }
    final bundleFutures = bundles.map<Future<void>>((bundle) async {
      final imagesFutures = bundle.images.map((image) async {
        final segments = path.split(image.path);
        segments.insert(segments.length - 1, 'compressed');
        final targetPath = path.joinAll(segments);
        if (!(await File(targetPath).exists())) {
          await _testCompressAndGetFile(image, targetPath);
        }
      });
      await Future.wait(imagesFutures);
      if (mounted) {
        setState(() => compressedBundleNb = compressedBundleNb! + 1);
      }
    });
    await Future.wait(bundleFutures);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Compression finished'),
      ));
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

  Widget _bundleListWidget(Iterable<Bundle> bundles) {
    final compressedBundleNb = this.compressedBundleNb;
    final autoMdCollectedBundleNb = this.autoMdCollectedBundleNb;
    return Column(
      children: [
        if (compressedBundleNb != null) ProgressIndicator('Compressing', total: bundleNb, itemDone: compressedBundleNb),
        if (autoMdCollectedBundleNb != null)
          ProgressIndicator('Collecting autoMetadata', total: bundleNb, itemDone: autoMdCollectedBundleNb),
        Expanded(
          child: GridView.extent(
            padding: const EdgeInsets.only(bottom: 2 * kFloatingActionButtonMargin + 48),
            maxCrossAxisExtent: 500,
            childAspectRatio: 2,
            children: bundles
                .map((bundle) => GestureDetector(
                      child: BundleWidget(bundle, refreshParent: () => setState(() {})),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (context) =>
                                    BooksMetadataCollectingWidget(step: MetadataCollectingStep(bundle: bundle))));
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator(this.description, {required this.total, required this.itemDone});
  final String description;
  final int? total;
  final int itemDone;

  @override
  Widget build(BuildContext context) {
    if (itemDone == total) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: total.ifIs(
          nul: () => const LinearProgressIndicator(),
          notnull: (total) => Row(
                children: [
                  Text(description),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: LinearProgressIndicator(value: itemDone / total),
                    ),
                  ),
                  Text('$itemDone / $total')
                ],
              )),
    );
  }
}

class BundleWidget extends StatefulWidget {
  const BundleWidget(this.bundle, {required this.refreshParent});

  final Bundle bundle;
  final void Function() refreshParent;

  @override
  State<BundleWidget> createState() => _BundleWidgetState();
}

class _BundleWidgetState extends State<BundleWidget> {
  late Future<KtMutableMap<String, KtMutableMap<ProviderEnum, BookMetaDataFromProvider?>>> cachedAutoMetadata;
  @override
  void initState() {
    super.initState();
    _loadAutoMetadata();
  }

  @override
  void didUpdateWidget(covariant BundleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAutoMetadata();
  }

  void _loadAutoMetadata() {
    cachedAutoMetadata = api.getAutoMetadataFromBundle(path: widget.bundle.autoMetadataFile.path).then((value) {
      return Map.fromEntries(value.map((e) {
        final providerMdMap = Map.fromEntries(e.metadatas.map((e) => MapEntry(e.provider, e.metadata))).kt;
        return MapEntry(e.isbn, providerMdMap);
      })).kt;
    });
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
                  final firstBook = autoMetadata.iter.firstOrNull;
                  if (firstBook == null) return const Text('No book identified');
                  final md = firstBook.value.dart.mergeAllProvider();
                  final priceRange = md.marketPrice.toList();
                  return Row(children: [
                    if (autoMetadata.size > 1) _NumberOfBookBadge(autoMetadata.size),
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
                  FutureWidget(future: cachedAutoMetadata, builder: (md) => MetadataIcons(md)),
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
                        icon: const Icon(Icons.image_search),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) =>
                                      ISBNDecodingWidget(step: ISBNDecodingStep(bundle: widget.bundle))));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: () async {
                          final res = await widget.bundle.removeAutoMetadata();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(res ? 'Automatic Metadata deleted' : 'Error while deleting automatic metadata'),
                            ));
                          }

                          widget.refreshParent();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          final segments = path.split(widget.bundle.directory.path);
                          segments[segments.length - 2] = 'booky_deleted';
                          widget.bundle.directory.renameSync(path.joinAll(segments));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Deleted'),
                          ));
                          widget.refreshParent();
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

class _NumberOfBookBadge extends StatelessWidget {
  const _NumberOfBookBadge(this.number);
  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 4.0),
      child: Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.black87),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )),
    );
  }
}

class MetadataIcons extends StatelessWidget {
  const MetadataIcons(this.metadata);
  final KtMutableMap<String, KtMutableMap<ProviderEnum, BookMetaDataFromProvider?>> metadata;

  @override
  Widget build(BuildContext context) {
    if (metadata.size == 0) return const SizedBox.shrink();

    final mergedMd = metadata.mapValues((p0) => p0.value.dart.mergeAllProvider());
    final allBooksHaveTitle = mergedMd.all((key, value) => (value.title?.length ?? 0) > 0);
    final allBooksHaveAuthor = mergedMd.all((key, value) => (value.authors.length) >= 1);
    final allBooksHaveBlurb = mergedMd.all((key, value) => (value.blurb?.length ?? 0) > 50);
    final allBooksHaveKeywords = mergedMd.all((key, value) => (value.keywords.length) > 5);
    final allBooksHavePrice = mergedMd.all((key, value) => (value.marketPrice.length) > 1);

    return Column(
      children: [
        _IconStatus(Icons.title, allBooksHaveTitle),
        _IconStatus(Icons.person, allBooksHaveAuthor),
        _IconStatus(Icons.description, allBooksHaveBlurb),
        _IconStatus(Icons.manage_search, allBooksHaveKeywords),
        _IconStatus(Icons.euro, allBooksHavePrice),
      ],
    );
  }
}

class _IconStatus extends StatelessWidget {
  const _IconStatus(this.icon, this.isChecked);
  final IconData icon;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Icon(
            icon,
            color: Colors.black26,
          ),
          if (isChecked)
            const Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                shadows: [Shadow(blurRadius: 1, color: Colors.white)],
                size: 14,
              ),
            )
        ],
      ),
    );
  }
}
