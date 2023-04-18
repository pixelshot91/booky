import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

class CopiableTextField extends StatelessWidget {
  const CopiableTextField(this.textFormField);
  final TextFormField textFormField;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
              onPressed: () async {
                final item = DataWriterItem();
                item.add(Formats.plainText(textFormField.controller!.text));
                await ClipboardWriter.instance.write([item]);
              },
              icon: const Icon(Icons.copy)),
          Expanded(child: textFormField),
        ],
      );
}
