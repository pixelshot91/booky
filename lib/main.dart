import 'dart:io';

import 'package:flutter/material.dart';

import 'drag_and_drop.dart' as drag_and_drop;
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookAdPublisher',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const drag_and_drop.SelectImages(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Ad> ad;
  @override
  void initState() {
    super.initState();
    ad = api.getMetadataFromImages(imgsPath: [
      '/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/DCIM/Camera/20230220_182059.jpg',
      '/run/user/1000/gvfs/mtp:host=SAMSUNG_SAMSUNG_Android_RFCRA1CG6KT/Internal storage/DCIM/Camera/20230220_182113.jpg'
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an automatic online book ad from picture'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // To render the results of a Future, a FutureBuilder is used which
            // turns a Future into an AsyncSnapshot, which can be used to
            // extract the error state, the loading state and the data if
            // available.
            //
            // Here, the generic type that the FutureBuilder manages is
            // explicitly named, because if omitted the snapshot will have the
            // type of AsyncSnapshot<Object?>.
            FutureBuilder<Ad>(
              future: ad,
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headline4;
                if (snap.error != null) {
                  // An error has been encountered, so give an appropriate response and
                  // pass the error details to an unobstructive tooltip.
                  debugPrint(snap.error.toString());
                  return Tooltip(
                    message: snap.error.toString(),
                    child: Text('Error during image decoding', style: style),
                  );
                }

                final ad = snap.data;
                if (ad == null) return const Text("Extracting info from images");

                return AdPage(ad: ad);
              },
            )
          ],
        ),
      ),
    );
  }
}

extension IntExt on int {
  int divide(int other) => this ~/ other;
}

extension DoubleExt on double {
  double multiply(double other) => this * other;
}

class AdPage extends StatefulWidget {
  const AdPage({required Ad ad}) : initialAd = ad;

  final Ad initialAd;

  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  late Ad ad;

  @override
  void initState() {
    super.initState();
    ad = widget.initialAd;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: ad.title,
            onChanged: (newText) => setState(() => ad.title = newText),
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              labelText: 'Ad title',
            ),
            style: const TextStyle(fontSize: 30),
          ),
          TextFormField(
            initialValue: ad.description,
            maxLines: 20,
            onChanged: (newText) => setState(() => ad.description = newText),
            decoration: const InputDecoration(
              icon: Icon(Icons.text_snippet),
              labelText: 'Ad description',
            ),
          ),
          TextFormField(
            initialValue: ad.priceCent /*?*/ .divide(100).toString(),
            onChanged: (newText) =>
                setState(() => ad.priceCent = double.tryParse(newText)! /*?*/ .multiply(100).round()),
            decoration: const InputDecoration(
              icon: Icon(Icons.euro),
              labelText: 'Price',
            ),
            style: const TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(children: [
              const Icon(
                Icons.image,
                color: Colors.grey,
              ),
              const SizedBox(width: 16),
              ...ad.imgsPath
                  .map((imgPath) => Image.file(
                        File(imgPath),
                        height: 200,
                        isAntiAlias: true,
                        filterQuality: FilterQuality.medium,
                      ))
                  .toList(),
            ]),
          ),
          ElevatedButton(
              onPressed: ad.priceCent == null
                  ? null
                  : () {
                      print('Try to publish...');
                      api.publishAd(ad: ad);
                    },
              child: const Text("Publish"))
        ],
      ),
    );
  }
}
