import 'dart:math';

import 'package:booky/helpers.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:kt_dart/kt.dart';

import 'camera/barcode_detection.dart';

class BarcodeLabel extends StatelessWidget {
  const BarcodeLabel(this.isbn, {required this.onDeletePressed});

  final ISBN isbn;
  final void Function() onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SelectableText(isbn.str, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete))
      ],
    );
  }
}

class ISBN extends Equatable {
  final String str;

  const ISBN._(this.str);

  static ISBN? fromString(String str) {
    if (str.isEmpty) return null;
    final validateStr = validator(str);
    // Non-null validate str means there is an error
    if (validateStr != null) return null;
    return ISBN._(str);
  }

  /// A null return value means the ISBN looks valid or is the empty string
  static String? validator(String text) {
    if (text.isEmpty) return null;
    if (text.length == 10) return _isbn10Validator(text);
    if (text.length == 13) return _isbn13Validator(text);
    return 'wrong number of digit';
  }

  static String? _isbn10Validator(String text) {
    final isbnNumbers = text.characters.map((e) {
      final res = int.tryParse(e);
      if (res != null) return res;
      if (e == 'X') return 10;
      throw Exception('Impossible char $e. Should be forbidden by the regex');
    });

    final sum = isbnNumbers.mapIndexed((index, element) {
      final weight = 10 - index;
      return weight * element;
    }).sum;
    if (sum % 11 != 0) return 'Not a valid ISBN-10';
    return null;
  }

  static String? _isbn13Validator(String text) {
    try {
      final isbnNumbers = text.characters.map((e) => int.parse(e));
      final sum = isbnNumbers.mapIndexed((index, element) {
        final weight = index % 2 == 0 ? 1 : 3;
        return weight * element;
      }).sum;
      if (sum % 10 != 0) return 'Not a valid ISBN-13';
      return null;
    } on FormatException {
      return 'ISBN-13 can only contain digits';
    }
  }

  @override
  List<Object?> get props => [str];
}

/// Backend to store ISBN, either entered manually, by a still picture, or by LiveDetection
/// LiveDetection ISBN require multiple detection to be considered valid
/// This is because the ISBNDecoder may generate the wrong ISBN on some frame
class ISBNManager {
  ISBNManager(Iterable<ISBN> initialISBNs) {
    _registeredISBNs = initialISBNs.map((isbn) => MapEntry<ISBN, BarcodeDetection>(isbn, SureDetection())).toMap();
  }

  // TODO: Should be a list to preserve order
  late final Map<ISBN, BarcodeDetection> _registeredISBNs;

  void addSureISBN(ISBN isbn, {required void Function() onSureTransition}) {
    _registeredISBNs.update(
      isbn,
      (oldDetection) => oldDetection.makeSure(onSureTransition),
      ifAbsent: () {
        onSureTransition();
        return SureDetection();
      },
    );
  }

  void addUnsureISBN(ISBN isbn, {required void Function() onBarcodeConfirmed}) {
    _registeredISBNs.update(isbn, (oldDetection) => oldDetection.increaseCounter(onBarcodeConfirmed),
        ifAbsent: () => UnsureDetection());
  }

  List<ISBN> getSureISBNs() {
    return _registeredISBNs.entries.where((entry) => entry.value is SureDetection).map((e) => e.key).toList();
  }

  void remove(ISBN isbn) {
    _registeredISBNs.remove(isbn);
  }

  bool contains(ISBN isbn) {
    return _registeredISBNs[isbn] is SureDetection;
  }
}

/// Show a TextField to add new ISBN with validation
/// And show the list of ISBNs
/// show the one that are Sure, not the one that are unsure
class ISBNsEditor extends StatefulWidget {
  const ISBNsEditor({required this.isbnManager, required this.onISBNsChanged});

  final ISBNManager isbnManager;
  final void Function() onISBNsChanged;

  @override
  State<ISBNsEditor> createState() => _ISBNsEditorState();
}

final rng = Random();

class _ISBNsEditorState extends State<ISBNsEditor> {
  // Null mean the ISBN currently entered in the TextField does not constitute a valid ISBN
  ISBN? manualISBN;

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sureISBNs = widget.isbnManager.getSureISBNs();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isbnListWidget = ScrollShadow(
          color: defaultScrollShadowColor,
          size: 10,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sureISBNs
                    .map((isbn) => BarcodeLabel(
                          isbn,
                          onDeletePressed: () => setState(() {
                            widget.isbnManager.remove(isbn);
                            widget.onISBNsChanged();
                          }),
                        ))
                    .toList()),
          ),
        );
        return Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
              controller: controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9X]{0,13}')),
              ],
              autovalidateMode: AutovalidateMode.always,
              validator: (s) => ISBN.validator(s!),
              decoration: const InputDecoration(hintText: 'Type manually the ISBN here'),
              onChanged: (typedISBN) {
                setState(() {
                  manualISBN = ISBN.fromString(typedISBN);
                });
              },
              onFieldSubmitted: manualISBN?.let<void Function(String)>((manualISBN) => (_) {
                    setState(() {
                      // TODO: add confirmation sound
                      widget.isbnManager.addSureISBN(manualISBN, onSureTransition: () {});
                    });
                    controller.clear();
                    widget.onISBNsChanged();
                  })),
          () {
            if (constraints.hasBoundedHeight) {
              return Expanded(child: isbnListWidget);
            } else {
              return ConstrainedBox(constraints: const BoxConstraints(maxHeight: 170), child: isbnListWidget);
            }
          }(),
        ]);
      },
    );
  }
}
