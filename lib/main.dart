import 'package:booky/repo_selection.dart';
import 'package:booky/route_observer.dart';
import 'package:booky/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Required for path_provider to get the directory
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  runApp(BookyApp());
}

class BookyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorObservers: [routeObserver],
        home: const RepoSelection(),
      );
}
