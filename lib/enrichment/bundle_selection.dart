import 'dart:async';
import 'dart:io';

import 'package:booky/camera/camera.dart';
import 'package:booky/enrichment/isbn_decoding.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart' as path;
import 'package:stream_transform/stream_transform.dart';

import '../bundle.dart';
import '../common.dart' as common;
import '../ffi.dart';
import '../helpers.dart';
import '../widgets/scrollable_bundle_images.dart';
import 'enrichment.dart';
import 'metadata_collecting.dart';

PopupMenuItem<void> _popUpMenuIconText(
        {required IconData icon, required String label, required void Function() onPressed}) =>
    PopupMenuItem<void>(
        onTap: onPressed,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Expanded(child: Text(label)),
          ],
        ));

class CustomSearchHintDelegate extends SearchDelegate<String> {
  CustomSearchHintDelegate({
    required String hintText,
    required this.bundles,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );
  final Future<Iterable<Bundle>?> bundles;

  bool matchOnISBN = true, matchOnTitle = true, matchOnAuthor = true;

  // Return null to display default back button
  @override
  Widget? buildLeading(BuildContext context) => null;

  @override
  PreferredSizeWidget buildBottom(BuildContext context) => PreferredSize(
      preferredSize: const Size.fromHeight(30.0),
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FilterChip(
                selected: matchOnISBN,
                label: const Text('ISBN'),
                onSelected: (value) {
                  setState(() => matchOnISBN = value);
                  query = query; // Force suggestions rebuild
                },
              ),
              FilterChip(
                selected: matchOnTitle,
                label: const Text('Title'),
                onSelected: (value) {
                  setState(() => matchOnTitle = value);
                  query = query; // Force suggestions rebuild
                },
              ),
              FilterChip(
                selected: matchOnAuthor,
                label: const Text('Author'),
                onSelected: (value) {
                  setState(() => matchOnAuthor = value);
                  query = query; // Force suggestions rebuild
                },
              ),
            ],
          ),
        );
      }));

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureWidget(
      future: bundles,
      builder: (bundles) {
        if (bundles == null) return const Text('Loading bundles');

        final bundlesWithMD = bundles.map((b) async {
          return b.getMergedMetadata();
          // return (b, listOfAutoMd);
        });
        return FutureWidget(
          future: Future.wait(bundlesWithMD),
          builder: (bundlesWithMD) {
            final whereNotNull = bundlesWithMD.whereNotNull();
            final bundlesMatchingISBN = matchOnISBN
                ? whereNotNull.where((b) => b.books.any((book) => book.isbn.contains(query)) ?? false)
                : const Iterable<BundleMetaData>.empty();
            final bundlesMatchingTitle = matchOnTitle
                ? whereNotNull
                    .where((b) => b.books.any((book) => book.title?.containsIgnoringCase(query) ?? false) ?? false)
                : const Iterable<BundleMetaData>.empty();
            final bundlesMatchingAuthor = matchOnAuthor
                ? whereNotNull.where((b) =>
                    b.books.any((book) => book.authors
                        .any((author) => '${author.firstName} ${author.lastName}'.containsIgnoringCase(query))) ??
                    false)
                : const Iterable<BundleMetaData>.empty();
            final bundleMatching =
                bundlesMatchingISBN.followedBy(bundlesMatchingTitle).followedBy(bundlesMatchingAuthor);
            return ListView.builder(
              itemBuilder: (context, index) {
                final b = bundleMatching.elementAt(index);
                return ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      b.books.firstOrNull?.title ?? 'None',
                    ),
                  ),
                );
              },
              itemCount: bundleMatching.length,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => const Text('results');

  @override
  List<Widget> buildActions(BuildContext context) =>
      <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.clear))];
}

class BundleSelection extends StatefulWidget {
  const BundleSelection();

  @override
  State<BundleSelection> createState() => _BundleSelectionState();
}

class _BundleSelectionState extends State<BundleSelection> {
  int? bundleNb;
  int? compressedBundleNb;
  int? autoMdCollectedBundleNb;

  final gridViewController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future(_compressImages);
  }

  Future<void> _compressImages() async {
    (await _listBundles())?.let((bundles) => _compressedAllBundleImages(bundles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const PageStorageKey('Scaffold'),
      appBar: AppBar(
        title: const Text('Bundle Section'),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: CustomSearchHintDelegate(hintText: 'Search all the bundles', bundles: _listBundles())
                      ..showResults(context));
              }),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              Future(_compressImages);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () async {
              final listBundles = await _listBundles();
              if (listBundles == null) {
                return;
              }
              _downloadMetadataForBundles(listBundles);
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<void>(
                  child: const Text('Invalidate all metadata from provider'),
                  onTap: () async {
                    final bundleList = await _listBundles();
                    if (bundleList == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Error while listing bundles')));
                      }
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Error while invalidating automatic metadata')));
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
      body: FutureWidget(
        future: _listBundles(),
        builder: (bundles) {
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
        },
      ),
    );
  }

  void _downloadMetadataForBundles(Iterable<Bundle> bundles) {
    setState(() {
      bundleNb = bundles.length;
      autoMdCollectedBundleNb = 0;
    });
    bundles.forEach((bundle) async {
      if (await bundle.autoMetadataFile.exists()) {
        if (mounted) {
          setState(() {
            autoMdCollectedBundleNb = autoMdCollectedBundleNb! + 1;
          });
        }
        return;
      }
      final List<String> isbns = (await bundle.getManualMetadata()).books.map((book) => book.isbn).toList();

      try {
        await api.getMetadataFromIsbns(
          isbns: isbns,
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
  }

  static Future<Iterable<Bundle>?> _listBundles() async {
    try {
      final dirs = await (await common.bookyDir()).toPublish.list().whereType<Directory>().toList();
      return dirs.sorted((d1, d2) => d1.path.compareTo(d2.path)).map((d) => Bundle(d));
    } catch (e) {
      if (e is PathNotFoundException || e is FileSystemException) {
        print('Exception in _listBundles. e = $e');
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
      final imagesFutures = (await bundle.images).map((image) async {
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
    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minHeight: 800,
      minWidth: 800,
      quality: 70,
    );
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
          child: ScrollShadow(
            // Controller are theoretically optional on vertically scrolling content, but on Linux without a controller, nothing is shown
            controller: gridViewController,
            color: defaultScrollShadowColor,
            size: 30,
            child: GridView.extent(
              controller: gridViewController,
              padding: const EdgeInsets.only(bottom: 2 * kFloatingActionButtonMargin + 48),
              maxCrossAxisExtent: 500,
              childAspectRatio: 2,
              children: bundles
                  .map((bundle) => GestureDetector(
                        child: BundleWidget(
                          key: const PageStorageKey('BundleWidget'),
                          bundle,
                          refreshParent: () => setState(() {}),
                          downloadMetadataForBundles: _downloadMetadataForBundles,
                        ),
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
  const BundleWidget(this.bundle, {required this.refreshParent, super.key, required this.downloadMetadataForBundles});

  final Bundle bundle;
  final void Function() refreshParent;
  final void Function(Iterable<Bundle> bundles) downloadMetadataForBundles;

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
    cachedAutoMetadata = widget.bundle.getAutoMetadata();
/*    cachedAutoMetadata = api.getAutoMetadataFromBundle(path: widget.bundle.autoMetadataFile.path).then((value) {
      return Map.fromEntries(value.map((e) {
        final providerMdMap = Map.fromEntries(e.metadatas.map((e) => MapEntry(e.provider, e.metadata))).kt;
        return MapEntry(e.isbn, providerMdMap);
      })).kt;
    });*/
  }

  @override
  Widget build(BuildContext context) => Card(
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
                          child: Column(
                        children: [
                          FutureWidget(
                            future: widget.bundle.getMergedMetadata(),
                            builder: (mergeMD) {
                              return Text(mergeMD.books.firstOrNull?.title ?? 'No title found');
                            },
                          ),
                          md.title.ifIs(
                              notnull: (t) => TextWithTooltip(t),
                              nul: () => const Text(
                                    'No title found',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  )),
                        ],
                      )),
                      priceRange.isEmpty
                          ? const Text('?')
                          : Text('${priceRange.first.toInt()} - ${priceRange.last.toInt()} €'),
                    ]);
                  }),
              Expanded(
                child: Row(
                  children: [
                    FutureWidget(future: cachedAutoMetadata, builder: (md) => MetadataIcons(md)),
                    Expanded(child: ScrollableBundleImages(widget.bundle, Axis.horizontal)),
                    _ActionButtons(
                        bundle: widget.bundle,
                        refreshParent: widget.refreshParent,
                        downloadMetadataForBundles: widget.downloadMetadataForBundles),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.bundle, required this.refreshParent, required this.downloadMetadataForBundles});

  final Bundle bundle;
  final void Function() refreshParent;
  final void Function(Iterable<Bundle> bundles) downloadMetadataForBundles;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              if (Platform.isLinux)
                _popUpMenuIconText(
                  icon: Icons.open_in_new,
                  label: 'Open in file explorer',
                  onPressed: () => Process.run('pcmanfm', [bundle.directory.path]),
                ),
              _popUpMenuIconText(
                icon: Icons.image_search,
                label: 'ISBN decoding',
                onPressed: () {
                  // Pushing a new route here synchronously does nothing as the PopUpMenuButton called a Navigator.pop immediately after to close the PopUpMenu
                  Future(() => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => ISBNDecodingWidget(step: ISBNDecodingStep(bundle: bundle)))));
                },
              ),
              _popUpMenuIconText(
                icon: Icons.cloud_download,
                label: 'Download auto-metadata',
                onPressed: () {
                  downloadMetadataForBundles([bundle]);
                },
              ),
              _popUpMenuIconText(
                icon: Icons.delete_sweep,
                label: 'Delete metadata from provider',
                onPressed: () async {
                  final res = await bundle.removeAutoMetadata();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res ? 'Automatic Metadata deleted' : 'Error while deleting automatic metadata'),
                    ));
                  }
                  refreshParent();
                },
              ),
              _popUpMenuIconText(
                icon: Icons.delete,
                label: 'Delete this bundle',
                onPressed: () async {
                  final initialDirectoryLocation = bundle.directory;
                  final segments = path.split(initialDirectoryLocation.path);
                  segments[segments.length - 2] = 'booky_deleted';
                  final finalDirectoryLocation = await initialDirectoryLocation.rename(path.joinAll(segments));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Deleted'),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await finalDirectoryLocation.rename(initialDirectoryLocation.path);
                            refreshParent();
                          }),
                    ));
                    refreshParent();
                  }
                },
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => BooksMetadataCollectingWidget(step: MetadataCollectingStep(bundle: bundle)))),
            icon: const Icon(Icons.send),
            iconSize: 30,
          ),
        ],
      );
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
    final allBooksHavePrice = mergedMd.all((key, value) => (value.marketPrice.length) >= 1);

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
