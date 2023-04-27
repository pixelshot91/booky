import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  const DraggableWidget({required super.key, required this.child, required this.onVerticalDrag});

  final Widget child;
  final void Function() onVerticalDrag;

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  bool showDismiss = false;
  Offset? startPosition;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: showDismiss
          ? Stack(
              fit: StackFit.expand,
              children: [widget.child, ColoredBox(color: Colors.white.withOpacity(0.8))],
            )
          : widget.child,
      onVerticalDragStart: (details) {
        startPosition = details.globalPosition;
      },
      onVerticalDragUpdate: (details) {
        final dy = (startPosition! - details.globalPosition).dy;
        const maxDy = 50;
        if (dy > maxDy && !showDismiss) {
          setState(() => showDismiss = true);
        } else if (dy < maxDy && showDismiss) {
          setState(() => showDismiss = false);
        }
      },
      onVerticalDragEnd: (details) {
        if (showDismiss) {
          widget.onVerticalDrag();
        }
      },
    );
  }
}
