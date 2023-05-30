import 'dart:io';

import 'package:flutter/material.dart';

import 'bridge_definitions.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(this.image);
  final File image;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      image,
      fit: BoxFit.fitHeight,
      isAntiAlias: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

class TextWithTooltip extends StatelessWidget {
  const TextWithTooltip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      child: Text(text,
          softWrap: false,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, overflow: TextOverflow.fade)),
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
        if (snap.hasError) {
          return Tooltip(
            message: snap.error.toString(),
            child: const Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        }
        return builder(snap.data as T);
      default:
        return const Text('???');
    }
  }
}

extension AuthorExt on Author {
  String toText() => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
}

extension IntExt on int {
  int divide(int other) => this ~/ other;
}

extension DoubleExt on double {
  double multiply(double other) => this * other;
}

extension IfNullExt<T> on T? {
  R ifIs<R>({required R Function(T) notnull, required R Function() nul}) {
    final t = this;
    if (t == null) {
      return nul();
    } else {
      return notnull(t);
    }
  }
}

extension ListExt<T> on List<T> {
  List<T>? nullIfEmpty() => isEmpty ? null : this;
}

extension IterableListExt<T> on Iterable<List<T>> {
  List<T> biggest() => fold([], (biggest, element) => element.length > biggest.length ? element : biggest);
}

extension IterableStringExt on Iterable<String> {
  String? biggest() => fold(null, (biggest, element) => element.length > (biggest?.length ?? 0) ? element : biggest);
}

class BookMetaDataManual {
  String? title;
  List<Author> authors;
  String? blurb;
  List<String> keywords;
  int? priceCent;

  BookMetaDataManual({
    this.title,
    required this.authors,
    this.blurb,
    required this.keywords,
    required this.priceCent,
  });
}

/*
extension BookMetadataExt on BookMetaData {
  BookMetaData deepCopy() => BookMetaData(
      title: '$title',
      authors: List.from(authors),
      blurb: '$blurb',
      keywords: List.from(keywords),
      marketPrice: Float32List.fromList(marketPrice));
}*/
