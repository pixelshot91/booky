import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class UIBundleWidget {
  UIBundleWidget(this.finder, this.tester) {
    _checkFinderUniqueness();
  }

  UIBundleWidget.fromListPosition(int index, this.tester) : finder = find.byKey(ValueKey(index)) {
    _checkFinderUniqueness();
  }

  final Finder finder;
  final WidgetTester tester;

  void _checkFinderUniqueness() {
    expect(finder, findsOneWidget);
  }

  Future<void> _openPopUpMenu() async {
    final popUpMenuButtonFinder = find.descendant(of: finder, matching: find.byType(PopupMenuButton<void>));
    await tester.tap(popUpMenuButtonFinder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> goToISBNDecoding() async {
    await _openPopUpMenu();

    final isbnDecodingFinder = find.text('ISBN decoding');

    expect(isbnDecodingFinder, findsOneWidget);
    await tester.tap(isbnDecodingFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> goToEditBundle() async {
    await _openPopUpMenu();

    final editBundleFinder = find.text('Edit bundle');

    expect(editBundleFinder, findsOneWidget);
    await tester.tap(editBundleFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
}
