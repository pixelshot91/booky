import 'dart:io';

import 'package:booky/src/rust/api/api.dart' as rust;
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

import 'isbn_helper.dart';

final defaultScrollShadowColor = Colors.black.withOpacity(0.8);

void showInSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

void logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

void showCameraException(BuildContext context, CameraException e) {
  logError(e.code, e.description);
  // ignore: do_not_use_unsafe_string_interpolation
  showInSnackBar(context, 'Error: ${e.code}\n${e.description}');
}

/// Add buttons to the context menu to quickly change the text case
Widget recaseContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final items = editableTextState.contextMenuButtonItems;

  items.addAll([
    ContextMenuButtonItem(
        label: 'Sentence case',
        onPressed: () => editableTextState.userUpdateTextEditingValue(
            TextEditingValue(text: editableTextState.textEditingValue.text.sentenceCase),
            SelectionChangedCause.toolbar)),
    ContextMenuButtonItem(
        label: 'lower case',
        onPressed: () => editableTextState.userUpdateTextEditingValue(
            TextEditingValue(text: editableTextState.textEditingValue.text.toLowerCase()),
            SelectionChangedCause.toolbar)),
    ContextMenuButtonItem(
        label: 'UPPER CASE',
        onPressed: () => editableTextState.userUpdateTextEditingValue(
            TextEditingValue(text: editableTextState.textEditingValue.text.toUpperCase()),
            SelectionChangedCause.toolbar)),
  ]);

  return AdaptiveTextSelectionToolbar.buttonItems(
    buttonItems: items,
    anchors: editableTextState.contextMenuAnchors,
  );
}

class LBCRadioButton extends StatelessWidget {
  const LBCRadioButton(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Card(
        child: RadioListTile<bool>(
          value: true,
          groupValue: true,
          onChanged: (_) {},
          title: Text(text),
          activeColor: const Color(0xffff6e14),
        ),
      ),
    );
  }
}

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
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        if (snap.hasError) {
          // ignore: do_not_use_toString
          final msg = snap.error.toString() + '\n' + snap.stackTrace.toString();
          print('AsyncSnapshotWidget error: $msg');
          return Tooltip(
            message: msg,
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

void showTextInSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

extension FileExt on File {
  // Same as File.rename but check that the destination file does not exist to prevent overwriting it
  Future<File> safeRename(String newPath) async {
    if (await File(newPath).exists()) {
      throw FileSystemException("File '$newPath' already exist. Cannot rename source file '$path'");
    }
    return await rename(newPath);
  }
}

extension AuthorExt on rust.Author {
  String toText() => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
}

extension BundleMetaDataExt on rust.BundleMetaData {
  void setISBN(List<ISBN> newISBNs) {
    /// Remove ISBNs that were deleted
    books.removeWhere((book) => newISBNs.contains(ISBN.fromString(book.isbn)!) == false);

    /// Add new ISBNs
    newISBNs.whereNot((newISBN) => books.any((book) => book.isbn == newISBN.str)).forEach((newISBN) {
      books.add(rust.BookMetaData(isbn: newISBN.str, authors: [], keywords: [], priceCent: null));
    });
  }
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

extension MapExt<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map<K, V>.fromEntries(this);
}

extension IterableListExt<T> on Iterable<List<T>> {
  List<T> biggest() => fold([], (biggest, element) => element.length > biggest.length ? element : biggest);
}

extension IterableStringExt on Iterable<String> {
  String? biggest() => fold(null, (biggest, element) => element.length > (biggest?.length ?? 0) ? element : biggest);
}

extension StringExt on String {
  bool containsIgnoringCase(String needle) => toLowerCase().contains(needle.toLowerCase());
}
