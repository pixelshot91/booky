import 'package:booky/enrichment/bundle_selection.dart';
import 'package:flutter/material.dart';

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
