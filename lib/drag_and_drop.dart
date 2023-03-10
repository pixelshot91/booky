import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class SelectImages extends StatelessWidget {
  const SelectImages({required this.onSelect});
  final void Function(List<String> paths) onSelect;

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
          child: _DropZone(onSelect: onSelect),
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
  const _DropZone({required this.onSelect});
  final void Function(List<String> paths) onSelect;

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
    final pathsRaw = await event.session.items.first.dataReader!.readValue(Formats.plainText);
    final paths = pathsRaw!.split('\n');
    final imgsPath = paths.where((e) => e.isNotEmpty).map((rawPath) {
      print('A${rawPath}B');
      var path = rawPath;
      const mtpPrefix = 'mtp://';
      if (rawPath.startsWith(mtpPrefix)) {
        final p = rawPath.substring(mtpPrefix.length).trim();
        // final deviceName = p.substring(0, p.indexOf('/'));
        // final pathInDevice = p.substring(p.indexOf('/'));
        path = '/run/user/1000/gvfs/mtp:host=' + p.replaceAll('%20', ' ');
      }
      print('path = $path');
      return path;
    }).toList();
    // The good way would be to read the Format.uri
    // But it convert the device name to lowercase
    // Because the device name can be mixed case it is thus not possible to retrieve the original device name
    /*print('len = ${event.session.items}');
    final futureImgPaths = event.session.items.map((item) async {
      final dataReader = item.dataReader!;

      for (final f in Formats.standardFormats.whereType<ValueFormat>()) {
        print('f($f) = ${await dataReader.readValue(f)}');
      }

      /*final format = dataReader!.getFormats([Formats.plainText]).first;
      switch (format) {
        case Formats.plainText:
          final text = (await dataReader.readValue(Formats.plainText))!;
          break;
      }*/
      print('plainText = ${await dataReader.readValue(Formats.plainText)}');
      final uri = await dataReader.readValue(Formats.uri);
      // print('uri = ${uri?.uri.toFilePath(windows: false)}');

      // final text = (await dataReader.readValue(Formats.plainText))!;
      final text = uri!.uri.toString();
      print('text is $text');
      const mtpPrefix = 'mtp://';
      var path = text;
      if (text.startsWith(mtpPrefix)) {
        final p = text.substring(mtpPrefix.length);
        final deviceName = p.substring(0, p.indexOf('/'));
        final pathInDevice = p.substring(p.indexOf('/'));
        path = '/run/user/1000/gvfs/mtp:host=' + deviceName.toUpperCase() + pathInDevice.replaceAll('%20', ' ');
      }
      print('path = $path');
      return path;
    }).toList();*/

    // final imgPaths = await Future.wait(futureImgPaths);
    widget.onSelect(imgsPath);
    /*
    final dataReader = event.session.items.first.dataReader!;
    final sugg = await dataReader.getSuggestedName();
    print('sugg = $sugg');

    final formats = dataReader.getFormats(Formats.standardFormats);
    print("PerformDropEvent = ${formats}");
    final imgsPaths = formats.map((format) async {
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
    });*/
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
