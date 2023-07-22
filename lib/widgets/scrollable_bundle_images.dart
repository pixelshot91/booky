import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:intersperse/intersperse.dart';

import '../bundle.dart';
import '../helpers.dart';

extension _AxisExt on Axis {
  Axis get opposite {
    switch (this) {
      case Axis.vertical:
        return Axis.horizontal;
      case Axis.horizontal:
        return Axis.vertical;
    }
  }
}

class _Gap extends StatelessWidget {
  const _Gap(this.size, this.axis);
  final double size;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: axis.opposite,
      children: [SizedBox(width: size, height: size)],
    );
  }
}

class ScrollableBundleImages extends StatefulWidget {
  const ScrollableBundleImages(this.bundle, this.axis);

  final Bundle bundle;
  final Axis axis;

  @override
  State<ScrollableBundleImages> createState() => _ScrollableBundleImagesState();
}

class _ScrollableBundleImagesState extends State<ScrollableBundleImages> {
  final imageScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ScrollShadow(
      scrollDirection: widget.axis,
      controller: imageScrollController,
      color: defaultScrollShadowColor,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        ),
        child: Scrollbar(
          controller: imageScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: widget.axis,
            controller: imageScrollController,
            child: FutureWidget(
                future: widget.bundle.compressedImages,
                builder: (images) => Flex(
                      direction: widget.axis.opposite,
                      children: [
                        Expanded(
                          child: Flex(
                              direction: widget.axis,
                              children: images
                                  .map<Widget>((f) => GestureDetector(
                                      onTap: () {
                                        showDialog<void>(
                                            context: context, builder: (context) => Center(child: ImageWidget(f)));
                                      },
                                      child: ImageWidget(f)))
                                  .intersperse(_Gap(8.0, widget.axis))
                                  .toList()),
                        ),
                        _Gap(12, widget.axis.opposite)
                      ],
                    )),
          ),
        ),
      ),
    );
  }
}
