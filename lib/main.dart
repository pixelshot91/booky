// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:booky/repo_selection.dart';
// import 'package:booky/route_observer.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   // Required for path_provider to get the directory
//   WidgetsFlutterBinding.ensureInitialized();
//
//   runApp(BookyApp());
// }
//
// class BookyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         navigatorObservers: [routeObserver],
//         home: const RepoSelection(),
//       );
// }
//

import 'package:flutter/material.dart';
import 'package:booky/src/rust/api/simple.dart';
import 'package:booky/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
              'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
        ),
      ),
    );
  }
}
