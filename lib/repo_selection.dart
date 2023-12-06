import 'dart:io';

import 'package:booky/enrichment/bundle_selection.dart';
import 'package:booky/helpers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../common.dart' as common;

/// Select a directory that will contain all the booky files
/// Can be a external device, or a local directory
class RepoSelection extends StatefulWidget {
  const RepoSelection();

  @override
  State<RepoSelection> createState() => _RepoSelectionState();
}

class _RepoSelectionState extends State<RepoSelection> {
  // Create all the main directories to avoid having 'No such file exception' when moving bundles around
  Future<List<Directory>> createAllDirs(Directory repoPath) {
    return Future.wait(common.BundleType.values.map((bundleType) async {
      final dir = common.BookyRepo(repoPath).getDir(bundleType);
      return await dir.create(recursive: true);
    }));
  }

  Future<bool> _isDeviceConnected() async => common.externalDeviceRepo.exists();

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return FutureWidget(
          future: () async {
            final extDir = (await path_provider.getExternalStorageDirectory())!;
            await createAllDirs(extDir);
            return extDir;
          }(),
          builder: (extDir) => BundleSelection(common.BookyRepo(extDir)));
    }

    return FutureWidget(
        future: _isDeviceConnected(),
        builder: (isDeviceConnected) {
          if (isDeviceConnected) {
            return BundleSelection(common.BookyRepo(common.externalDeviceRepo));
          }
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
        });
  }
}
