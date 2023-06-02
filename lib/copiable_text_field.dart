import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

class CopyableTextField extends StatelessWidget {
  const CopyableTextField(this.textFormField);
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

/// Used to add some padding so all the field are aligned, whether they contained a copyable text or not
class NonCopyableTextField extends StatelessWidget {
  const NonCopyableTextField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(icon: Icon(Icons.copy), onPressed: null),
          ),
          Expanded(child: child),
        ],
      );
}
