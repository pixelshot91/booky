import 'dart:async';
import 'dart:io';

import 'package:booky/camera/camera.dart';
import 'package:booky/common.dart';
import 'package:booky/enrichment/isbn_decoding.dart';
import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart' as path;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:stream_transform/stream_transform.dart';

import '../bundle.dart';
import '../common.dart' as common;
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

class BundleMetaDataWithIndex {
  BundleMetaDataWithIndex(this.index, this.md);

  final int index;
  final rust.BundleMetaData? md;
}

class CustomSearchHintDelegate extends SearchDelegate<String> {
  CustomSearchHintDelegate({
    required String hintText,
    required this.bundlesWithMD,
    required this.bundlesScrollController,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );
  final Future<List<BundleMetaDataWithIndex>?> bundlesWithMD;

  AutoScrollController bundlesScrollController;

  bool matchOnISBN = true, matchOnTitle = true, matchOnAuthor = true;

  // Return null to display default back button
  @override
  Widget? buildLeading(BuildContext context) => null;

  @override
  PreferredSizeWidget buildBottom(BuildContext context) => PreferredSize(
      preferredSize: const Size.fromHeight(50),
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
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) => FutureWidget(
        future: bundlesWithMD,
        builder: (bundlesWithMD) {
          if (bundlesWithMD == null) return const Text('Error while fetching bundles');

          if (query.isEmpty) {
            return Center(
                child: Text(
              '${bundlesWithMD.length} bundles yet to be published',
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ));
          }

          final bundlesMatchingISBN = matchOnISBN
              ? bundlesWithMD.where((b) => b.md?.books.any((book) => book.isbn.contains(query)) ?? false)
              : const Iterable<BundleMetaDataWithIndex>.empty();
          final bundlesMatchingTitle = matchOnTitle
              ? bundlesWithMD
                  .where((b) => b.md?.books.any((book) => book.title?.containsIgnoringCase(query) ?? false) ?? false)
              : const Iterable<BundleMetaDataWithIndex>.empty();
          final Iterable<BundleMetaDataWithIndex> bundlesMatchingAuthor = matchOnAuthor
              ? bundlesWithMD.where((b) =>
                  b.md?.books.any((book) => book.authors
                      .any((author) => '${author.firstName} ${author.lastName}'.containsIgnoringCase(query))) ??
                  false)
              : const Iterable<BundleMetaDataWithIndex>.empty();
          final bundleMatching = bundlesMatchingISBN.followedBy(bundlesMatchingTitle).followedBy(bundlesMatchingAuthor);
          return ListView.builder(
            itemBuilder: (context, index) {
              final b = bundleMatching.elementAt(index);
              return ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.md?.books.firstOrNull?.title ?? 'None',
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await bundlesScrollController.scrollToIndex(b.index,
                                preferPosition: AutoScrollPosition.middle);
                            await bundlesScrollController.highlight(b.index);
                          },
                          child: const Text('See in list')),
                    ],
                  ),
                ),
              );
            },
            itemCount: bundleMatching.length,
          );
        },
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  List<Widget> buildActions(BuildContext context) =>
      <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.clear))];
}

class BundleSelection extends StatefulWidget {
  const BundleSelection(this.repo);

  final BookyRepo repo;

  @override
  State<BundleSelection> createState() => _BundleSelectionState();
}

class _BundleSelectionState extends State<BundleSelection> {
  int? bundleNb;
  int? compressedBundleNb;
  int? autoMdCollectedBundleNb;
  BundleType bundleType = BundleType.toPublish;

  late final AutoScrollController gridViewController;

  @override
  void initState() {
    super.initState();
    gridViewController = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
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
                // Process all the bundleMD once when the searchbar open
                final bundlesWithMD = Future<List<BundleMetaDataWithIndex>?>(() async {
                  final bundlesDir = widget.repo.getDir(bundleType);
                  final mds = await rust.getMergedMetadataForAllBundles(bundlesDir: bundlesDir.path);
                  return mds.mapIndexed((index, element) => BundleMetaDataWithIndex(index, element)).toList();
                });
                showSearch(
                    context: context,
                    delegate: CustomSearchHintDelegate(
                        hintText: 'Search all the bundles',
                        bundlesWithMD: bundlesWithMD,
                        bundlesScrollController: gridViewController)
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
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute<void>(builder: (context) => CameraWidgetInit(ShootMultipleBundle(widget.repo))));
            _refreshBundleList();
          }),
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
          if (bundles.isEmpty) return _showEmptyBundleList();
          return _bundleListWidget(bundles);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'To publish'),
            BottomNavigationBarItem(icon: Icon(Icons.shelves), label: 'Published'),
            BottomNavigationBarItem(
                icon: Icon(Icons.delete_outlined), activeIcon: Icon(Icons.delete), label: 'Deleted'),
          ],
          currentIndex: bundleType.index,
          onTap: (index) {
            setState(() {
              bundleType = BundleType.values[index];
            });
          }),
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
        await rust.getMetadataFromIsbns(
          isbns: isbns,
          path: bundle.autoMetadataFile.path,
        );
      } on PanicException catch (e) {
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

  Future<Iterable<Bundle>?> _listBundles() async {
    try {
      final dirs = await widget.repo.getDir(bundleType).list().whereType<Directory>().toList();
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
        print('compressing ${image.fullScale.path}');
        await image.compressToThumbnail();
        await image.compressToImageToExport();
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
            color: defaultScrollShadowColor,
            size: 30,
            child: GridView.extent(
              controller: gridViewController,
              padding: const EdgeInsets.only(bottom: 2 * kFloatingActionButtonMargin + 48),
              maxCrossAxisExtent: 500,
              childAspectRatio: 2,
              children: bundles
                  .mapIndexed((index, bundle) => AutoScrollTag(
                      key: ValueKey(index),
                      controller: gridViewController,
                      index: index,
                      highlightColor: Colors.black.withOpacity(0.5),
                      child: GestureDetector(
                        child: BundleWidget(
                          key: const PageStorageKey('BundleWidget'),
                          widget.repo,
                          bundle,
                          refreshParent: _refreshBundleList,
                          downloadMetadataForBundles: _downloadMetadataForBundles,
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) =>
                                      BooksMetadataCollectingWidget(step: MetadataCollectingStep(bundle: bundle))));
                          _refreshBundleList();
                        },
                      )))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showEmptyBundleList() {
    final String text;
    switch (bundleType) {
      case BundleType.toPublish:
        text = 'Tap the camera button to create new bundles';
      case BundleType.published:
        text = 'Published bundles will show here';
      case BundleType.deleted:
        text = 'Deleted bundles will show here';
    }
    return Center(
        child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 30, color: Colors.grey),
    ));
  }

  void _refreshBundleList() {
    setState(() {});
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
  const BundleWidget(this.repo, this.bundle,
      {required this.refreshParent, super.key, required this.downloadMetadataForBundles});

  final common.BookyRepo repo;
  final Bundle bundle;
  final void Function() refreshParent;
  final void Function(Iterable<Bundle> bundles) downloadMetadataForBundles;

  @override
  State<BundleWidget> createState() => _BundleWidgetState();
}

class _BundleWidgetState extends State<BundleWidget> {
  late Future<rust.BundleMetaData?> cachedMergedMd;

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
    cachedMergedMd = widget.bundle.getMergedMetadata();
  }

  Widget _buildTitleLine(rust.BundleMetaData? bundleMergedMD) {
    if (bundleMergedMD == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No metadata'),
          SizedBox(width: 10),
          Icon(
            Icons.edit_note,
            color: Colors.red,
          ),
          Icon(
            Icons.error,
            color: Colors.red,
          ),
        ],
      );
    }
    final firstBook = bundleMergedMD.books.firstOrNull;
    if (firstBook == null) return const Text('No book identified');
    return Row(children: [
      if (bundleMergedMD.books.length > 1) _NumberOfBookBadge(bundleMergedMD.books.length),
      Expanded(
          child: Column(
        children: [
          firstBook.title.ifIs(
              notnull: (t) => TextWithTooltip(t),
              nul: () => const Text(
                    'No title found',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )),
        ],
      )),
      bundleMergedMD.books
          .map((b) => b.priceCent)
          .whereNotNull()
          .let((prices) => prices.isEmpty ? const Text('?') : Text('${prices.sum ~/ 100} €')),
    ]);
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FutureWidget(
            future: cachedMergedMd,
            builder: (bundleMergedMD) => Column(
              children: [
                _buildTitleLine(bundleMergedMD),
                Expanded(
                  child: Row(
                    children: [
                      if (bundleMergedMD != null) MetadataIcons(bundleMergedMD),
                      Expanded(child: ScrollableBundleImages(widget.bundle, Axis.horizontal)),
                      _ActionButtons(
                          repo: widget.repo,
                          bundle: widget.bundle,
                          refreshParent: widget.refreshParent,
                          downloadMetadataForBundles: widget.downloadMetadataForBundles),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons(
      {required this.repo,
      required this.bundle,
      required this.refreshParent,
      required this.downloadMetadataForBundles});

  final common.BookyRepo repo;
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
                icon: Icons.camera_alt,
                label: 'Edit bundle',
                onPressed: () {
                  // Pushing a new route here synchronously does nothing as the PopUpMenuButton called a Navigator.pop immediately after to close the PopUpMenu
                  Future(() async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (context) => CameraWidgetInit(EditOneBundle(bundle.directory))));
                    refreshParent();
                  });
                },
              ),
              _popUpMenuIconText(
                icon: Icons.image_search,
                label: 'ISBN decoding',
                onPressed: () {
                  // Pushing a new route here synchronously does nothing as the PopUpMenuButton called a Navigator.pop immediately after to close the PopUpMenu
                  Future(() async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (context) => ISBNDecodingWidget(step: ISBNDecodingStep(bundle: bundle))));
                    refreshParent();
                  });
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
                  segments[segments.length - 2] = common.BundleType.deleted.getDirName;
                  final destination = path.joinAll(segments);
                  try {
                    final finalDirectoryLocation = await initialDirectoryLocation.rename(destination);
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
                  } on Exception catch (e) {
                    if (context.mounted) {
                      print(
                          'Error. Could not delete bundle. try to rename from ${initialDirectoryLocation.path} to $destination e = $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error. Could not delete bundle'),
                      ));
                    }
                  }
                },
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (context) =>
                          BooksMetadataCollectingWidget(step: MetadataCollectingStep(bundle: bundle))));
              refreshParent();
            },
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
  const MetadataIcons(this.bundleMergeMD);

  final rust.BundleMetaData bundleMergeMD;

  @override
  Widget build(BuildContext context) {
    if (bundleMergeMD.books.length == 0) return const SizedBox.shrink();

    final books = bundleMergeMD.books;
    final allBooksHaveTitle = books.every((b) => (b.title?.length ?? 0) > 0);
    final allBooksHaveAuthor = books.every((b) => b.authors.length > 0);
    final allBooksHaveBlurb = books.every((b) => (b.blurb?.length ?? 0) > 0);
    final allBooksHaveKeywords = books.every((b) => b.keywords.length > 0);
    final allBooksHavePrice = books.every((b) => b.priceCent != null);

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
