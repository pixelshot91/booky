import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import 'helpers.dart';

class DraggableFilesWidget extends StatefulWidget {
  const DraggableFilesWidget({required this.uris, required this.child});

  final Iterable<Uri> uris;
  final Widget child;
  @override
  State<DraggableFilesWidget> createState() => _DraggableFilesWidgetState();
}

class _DraggableFilesWidgetState extends State<DraggableFilesWidget> {
  late final List<GlobalKey<DragItemWidgetState>> dragItemKeys;

  @override
  void initState() {
    super.initState();
    dragItemKeys = widget.uris.map((_) => GlobalKey<DragItemWidgetState>()).toList();
  }

  @override
  Widget build(BuildContext context) => DraggableWidget(
        dragItemsProvider: (context) => dragItemKeys.map((e) => e.currentState!).toList(),
        child: Column(
          children: [
            Row(
              children: widget.uris
                  .mapIndexed((index, uri) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DragItemWidget(
                            key: dragItemKeys[index],
                            dragItemProvider: (_) => DragItem()..add(Formats.uri(NamedUri(uri))),
                            allowedOperations: () => const [DropOperation.copy],
                            child: SizedBox(height: 200, child: ImageWidget(File.fromUri(uri)))),
                      ))
                  .toList(),
            ),
            const Text('Drag and drop images')
          ],
        ),
      );
}
