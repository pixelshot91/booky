import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/enrichment/bundle_selection.dart';

void main() {
  runApp(const BookyApp());
}

class BookyApp extends StatelessWidget {
  const BookyApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: BundleSelection(),
      );
}
