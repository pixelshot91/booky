// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// 
// // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // 
// // // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // // 
// // // // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // // // 
// // // // // import 'package:booky/repo_selection.dart';
// // // // // import 'package:booky/route_observer.dart';
// // // // // import 'package:booky/src/rust/frb_generated.dart';
// // // // // import 'package:flutter/foundation.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // 
// // // // // Future<void> main() async {
// // // // //   // wait for the splash screen to finish its animation
// // // // //   // disable in debug mode to avoid long pumpAndSettle in the `flutter drive` test
// // // // //   if (!kDebugMode) {
// // // // //     await Future<void>.delayed(const Duration(seconds: 1));
// // // // //   }
// // // // // 
// // // // //   // Required for path_provider to get the directory
// // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // // 
// // // // //   // In integration test, main is called multiple time, one for each 'testWidgets' calls
// // // // //   // And calling `init` multiple time throw a Bad State exception
// // // // //   if (RustLib.instance.initialized == false) {
// // // // //     await RustLib.init();
// // // // //   }
// // // // // 
// // // // //   runApp(BookyApp());
// // // // // }
// // // // // 
// // // // // class BookyApp extends StatelessWidget {
// // // // //   @override
// // // // //   Widget build(BuildContext context) => MaterialApp(
// // // // //         navigatorObservers: [routeObserver],
// // // // //         home: const RepoSelection(),
// // // // //       );
// // // // // }
// // // // // 
// // // // 
// // // // import 'package:flutter/material.dart';
// // // // import 'package:booky/src/rust/api/simple.dart';
// // // // import 'package:booky/src/rust/frb_generated.dart';
// // // // 
// // // // Future<void> main() async {
// // // //   await RustLib.init();
// // // //   runApp(const MyApp());
// // // // }
// // // // 
// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});
// // // // 
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       home: Scaffold(
// // // //         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
// // // //         body: Center(
// // // //           child: Text(
// // // //               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // 
// // // 
// // // import 'package:flutter/material.dart';
// // // import 'package:booky/src/rust/api/simple.dart';
// // // import 'package:booky/src/rust/frb_generated.dart';
// // // 
// // // Future<void> main() async {
// // //   await RustLib.init();
// // //   runApp(const MyApp());
// // // }
// // // 
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // // 
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
// // //         body: Center(
// // //           child: Text(
// // //               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // 
// // 
// // import 'package:flutter/material.dart';
// // import 'package:booky/src/rust/api/simple.dart';
// // import 'package:booky/src/rust/frb_generated.dart';
// // 
// // Future<void> main() async {
// //   await RustLib.init();
// //   runApp(const MyApp());
// // }
// // 
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// // 
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
// //         body: Center(
// //           child: Text(
// //               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // 
// 
// import 'package:flutter/material.dart';
// import 'package:booky/src/rust/api/simple.dart';
// import 'package:booky/src/rust/frb_generated.dart';
// 
// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }
// 
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
// 
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
//         ),
//       ),
//     );
//   }
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
