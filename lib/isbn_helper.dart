import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

String? _isbn10Validator(String text) {
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

String? _isbn13Validator(String text) {
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

// A null return value means the ISBN looks valid
String? isbnValidator(String text) {
  if (text.length == 10) return _isbn10Validator(text);
  if (text.length == 13) return _isbn13Validator(text);
  return 'wrong number of digit';
}
