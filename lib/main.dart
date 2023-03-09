import 'package:flutter/material.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Ad> ad;
  @override
  void initState() {
    super.initState();
    ad = api.getMetadataFromImages(imgsPath: [
      '/home/julien/Perso/LeBonCoin/chain_automatisation/test_images/20230204_194746.jpg'
    ]); //.then((ad) => print('ad = $ad'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
  AdPage({super.key, required Ad ad}) : initialAd = ad;

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
    return Column(
      children: [
        TextFormField(
          initialValue: ad.title,
          onChanged: (newText) {
            setState(() {
              ad.title = newText;
            });
          },
        ),
        TextFormField(
          initialValue: ad.description,
          maxLines: 20,
          onChanged: (newText) {
            setState(() {
              ad.description = newText;
            });
          },
        ),
        TextFormField(
          initialValue: ad.priceCent /*?*/ .divide(100).toString(),
          onChanged: (newText) => setState(() => ad.priceCent = double.tryParse(newText)! /*?*/ .multiply(100).round()),
        ),
        ElevatedButton(
            onPressed: ad.priceCent == null
                ? null
                : () {
                    print('Try to publish');
                  },
            child: const Text("Publish"))
      ],
    );
  }
}
