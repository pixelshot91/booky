import 'dart:io';

import 'package:flutter/material.dart';

import 'bridge_definitions.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(this.imgPath);
  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(imgPath),
      height: 200,
      isAntiAlias: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

class FutureWidget<T> extends StatelessWidget {
  const FutureWidget({required this.future, required this.builder});
  final Future<T> future;
  final Widget Function(T) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: future, builder: (context, snap) => AsyncSnapshotWidget(snap: snap, builder: builder));
  }
}

class AsyncSnapshotWidget<T> extends StatelessWidget {
  const AsyncSnapshotWidget({required this.snap, required this.builder});
  final AsyncSnapshot<T> snap;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    switch (snap.connectionState) {
      case ConnectionState.waiting:
        return const CircularProgressIndicator();
      case ConnectionState.done:
        return builder(snap.data as T);
      default:
        return const Text('???');
    }
  }
}

extension AuthorsExt on List<Author> {
  String toText() => map((a) => '${a.firstName} ${a.lastName}').join('\n');
}

extension IntExt on int {
  int divide(int other) => this ~/ other;
}

extension DoubleExt on double {
  double multiply(double other) => this * other;
}
