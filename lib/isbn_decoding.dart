import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/main.dart';

import 'common.dart';

class ISBNDecodingWidget extends StatefulWidget {
  const ISBNDecodingWidget({required this.step, required this.onSubmit});
  final ISBNDecodingStep step;
  final void Function(MetadataCollectingStep newStep) onSubmit;

  @override
  State<ISBNDecodingWidget> createState() => _ISBNDecodingWidgetState();
}

class _ISBNDecodingWidgetState extends State<ISBNDecodingWidget> {
  Map<String, List<String>> isbns = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('initState');
    widget.step.imgsPaths.forEach((imgPath) {
      Future.microtask(() async {
        final decoder_process = await Process.run(
            '/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode',
            ['-in=' + imgPath]);
        if (decoder_process.exitCode != 0) {
          print('stdout is ${decoder_process.stdout}');
          print('stderr is ${decoder_process.stderr}');
          throw Exception('decoder status is ${decoder_process.exitCode}');
        }
        // final s = String.fromCharCodes((decoder_process.stdout as List<int>));
        final s = decoder_process.stdout as String;
        print('s = $s');
        setState(() {
          isbns[imgPath] = s.split(' ');
        });
      });
    });
/*
    let output = Command::new(
    "/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode",
    )
        .arg("-in=".to_string() + &picture_path)
        .output()
        .expect("failed to execute process");
    if !output.status.success() {
    println!("stdout is {:?}", std::str::from_utf8(&output.stdout).unwrap());
    println!("stderr is {:?}", std::str::from_utf8(&output.stderr).unwrap());
    panic!("output.status is {}", output.status)
    }
    let output = std::str::from_utf8(&output.stdout).unwrap();
    println!("output is {:?}", output);
    output
        .split_ascii_whitespace()
        .map(|x| x.to_string())
        .collect_vec()*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: widget.step.imgsPaths
            .map((imgPath) => Column(
                  children: [
                    ImageWidget(imgPath),
                    ...isbns[imgPath]!.map((isbn) => Text(isbn)).toList(),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
