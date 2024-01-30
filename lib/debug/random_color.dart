import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Used to identify when the widget is rebuild from scratch, and initState is called again
/// 'Flutter DevTools' has a similar feature called "Highlight repaints" but a widget maybe repainted even if its state has not changed
/// 'Flutter performance' also has a 'Widget rebuild stats', but when a lot of widgets get rebuilt, it may be difficult to find the one we are interested in
class RandomColor extends StatefulWidget {
  const RandomColor(this.title);

  final String title;

  @override
  State<RandomColor> createState() => _RandomColorState();
}

class _RandomColorState extends State<RandomColor> {
  late Color color;

  @override
  void initState() {
    super.initState();
    print('XXX RandomColor(title=${widget.title}) initState');
    color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: color,
      child: Center(child: Text(widget.title)),
    );
  }
}
