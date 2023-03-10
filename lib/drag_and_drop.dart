import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class SelectImages extends StatelessWidget {
  const SelectImages();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Drop the images to create a new ad'),
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _DropZone(),
        ),
      );
}

extension _ReadValue on DataReader {
  Future<T?> readValue<T extends Object>(ValueFormat<T> format) {
    final c = Completer<T?>();
    final progress = getValue<T>(format, (value) {
      c.complete(value);
    }, onError: (e) {
      c.completeError(e);
    });
    if (progress == null) {
      c.complete(null);
    }
    return c.future;
  }
}

class _DropZone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: const [
        ...Formats.standardFormats,
      ],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: _onDropOver,
      onPerformDrop: _onPerformDrop,
      onDropLeave: _onDropLeave,
      child: Stack(
        children: [
          Positioned.fill(child: _content),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isDragOver ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _preview,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropOperation _onDropOver(DropOverEvent event) {
    setState(() {
      _isDragOver = true;
      _preview = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.black.withOpacity(0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text('${event.session.items.length} images selected')),
              ),
            ),
          ),
        ),
      );
    });
    return event.session.allowedOperations.firstOrNull ?? DropOperation.none;
  }

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    final dataReader = event.session.items.first.dataReader!;
    final sugg = await dataReader.getSuggestedName();
    print('sugg = $sugg');

    final formats = dataReader.getFormats(Formats.standardFormats);
    print("PerformDropEvent = ${formats}");
    formats.forEach((format) async {
      switch (format) {
        case Formats.plainText:
          final text = (await dataReader.readValue(Formats.plainText))!;
          print('text is $text');
          const mtpPrefix = 'mtp://';
          var path = text;
          if (text.startsWith(mtpPrefix)) {
            path = '/run/user/1000/gvfs/mtp:host=' + text.substring(mtpPrefix.length).replaceAll('%20', ' ');
          }
          print('path = $path');
          break;
        default:
          print('format not handled');
      }
    });
  }

  void _onDropLeave(DropEvent event) {
    setState(() {
      _isDragOver = false;
    });
  }

  bool _isDragOver = false;

  Widget _preview = const SizedBox();
  final Widget _content = const Center(
    child: Text(
      'Drop images here',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 32,
      ),
    ),
  );
}
