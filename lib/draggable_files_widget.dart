import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:super_native_extensions/raw_drag_drop.dart' as raw;
import 'package:super_native_extensions/widgets.dart';

class DraggableFilesWidget extends StatelessWidget {
  const DraggableFilesWidget({required this.uris, required this.child});

  final Iterable<Uri> uris;
  final Widget child;

  @override
  Widget build(BuildContext context) => FallbackSnapshotWidget(
        child: Builder(
            builder: (context) => BaseDraggableWidget(
                  hitTestBehavior: HitTestBehavior.deferToChild,
                  child: child,
                  dragConfiguration: (location, session) async {
                    Future<DragImage?> getSnapshot(Offset location) async {
                      final snapshotter = Snapshotter.of(context)!;
                      final dragSnapshot = await snapshotter.getSnapshot(location, SnapshotType.drag);

                      raw.TargetedImage? liftSnapshot;
                      if (defaultTargetPlatform == TargetPlatform.iOS) {
                        liftSnapshot = await snapshotter.getSnapshot(location, SnapshotType.lift);
                      }

                      final snapshot = dragSnapshot ?? liftSnapshot ?? await snapshotter.getSnapshot(location, null);

                      if (snapshot == null) {
                        return null;
                      }

                      return DragImage(image: snapshot, liftImage: liftSnapshot);
                    }

                    final dragImage = (await getSnapshot(const Offset(0, 0)))!;
                    // final r = dragImage!.image.rect;
                    // print('r = $r');

                    return DragConfiguration(
                      items: uris
                          .map((uri) => DragConfigurationItem(
                              item: DragItem()..add(Formats.uri(NamedUri(uri))), image: dragImage))
                          .toList(),
                      allowedOperations: [DropOperation.copy],
                    );
                  },
                )),
      );
}
