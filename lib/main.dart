import 'dart:io';

import 'package:booky/common.dart' as common;
import 'package:booky/enrichment/bundle_selection.dart';
import 'package:booky/route_observer.dart';
import 'package:flutter/material.dart';

void main() {
  // Required for path_provider to get the directory
  WidgetsFlutterBinding.ensureInitialized();

  runApp(BookyApp());
}

class BookyApp extends StatelessWidget {
  // Create all the main directories to avoid having 'No such file exception' when moving bundles around
  final Future<List<Directory>> createAllDirs = Future.wait(common.BundleType.values.map((bundleType) async {
    final dir = (await common.bookyDir()).getDir(bundleType);
    return await dir.create(recursive: true);
  }));

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: createAllDirs,
      builder: (context, _) => MaterialApp(
            navigatorObservers: [routeObserver],
            home: const BundleSelection(),
          ));
}
