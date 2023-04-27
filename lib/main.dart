import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/camera/camera.dart';

import 'enrichment/enrichment.dart';

void main() {
  runApp(const BookyApp());
}

enum BookyAppActivity {
  camera,
  enrichment,
}

class BookyApp extends StatefulWidget {
  const BookyApp();

  @override
  State<BookyApp> createState() => _BookyAppState();
}

class _BookyAppState extends State<BookyApp> {
  BookyAppActivity activity = Platform.isAndroid ? BookyAppActivity.camera : BookyAppActivity.enrichment;

  @override
  Widget build(BuildContext context) {
    switch (activity) {
      case BookyAppActivity.camera:
        return const CameraApp();
      case BookyAppActivity.enrichment:
        return const EnrichmentApp();
    }
  }
}
