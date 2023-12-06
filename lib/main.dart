import 'package:booky/repo_selection.dart';
import 'package:booky/route_observer.dart';
import 'package:flutter/material.dart';

void main() {
  // Required for path_provider to get the directory
  WidgetsFlutterBinding.ensureInitialized();

  runApp(BookyApp());
}

class BookyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorObservers: [routeObserver],
        home: const RepoSelection(),
      );
}
