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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: widget.step.imgsPaths
            .map((imgPath) => Column(
                  children: [
                    ImageWidget(imgPath),
                    ...isbns[imgPath]?.map((isbn) => Text(isbn)).toList() ?? [Text('no ISBN')],
                  ],
                ))
            .toList(),
      ),
    );
  }
}
