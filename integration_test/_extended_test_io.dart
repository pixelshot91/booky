// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:booky/enrichment/bundle_selection.dart';
import 'package:booky/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final tests = {
    'basic_screenshot': basicScreenshot,
    'searchbar': searchBar,
    'add_isbn': addIsbn,
  };
  for (final test in tests.values) {
    test(binding);
  }
}

class Screenshotter {
  Screenshotter(this.binding, this.folderName);

  final IntegrationTestWidgetsFlutterBinding binding;
  final String folderName;

  int index = 0;

  Future<void> capture(String name) async {
    final paddedIndex = index.toString().padLeft(2, '0');
    index += 1;
    await binding.takeScreenshot(folderName + '/' + paddedIndex + '_' + name);
  }
}

void addIsbn(final IntegrationTestWidgetsFlutterBinding binding) {
  final ss = Screenshotter(binding, 'add_isbn');

  testWidgets('Add ISBN in ISBNDecoding', (WidgetTester tester) async {
    // Build our app.
    app.main();

    Future<void> tapPopMenu_ISBNDecoding() async {
      final find7thBundle = find.byKey(const ValueKey(7));
      expect(find7thBundle, findsOneWidget);

      final popUpMenuButtonFinder = find.descendant(of: find7thBundle, matching: find.byType(PopupMenuButton<void>));
      await tester.tap(popUpMenuButtonFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final isbnDecodingFinder = find.text('ISBN decoding');

      expect(isbnDecodingFinder, findsOneWidget);
      await tester.tap(isbnDecodingFinder);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    await ss.capture('home');

    final Finder bundlesFinder = find.byWidgetPredicate((widget) => widget is BundleWidget);
    final bundles = tester.widgetList<BundleWidget>(bundlesFinder);
    print('bundles.length = ${bundles.length}');
    // expect(bundles.length, equals(8));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(GridView), findsOneWidget);

    await tester.dragUntilVisible(find.byKey(const ValueKey(7)), find.byType(GridView), const Offset(0, -500));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await ss.capture('drag_Until_Bundle_Visible');

    final find7thBundle = find.byKey(const ValueKey(7));
    expect(find7thBundle, findsOneWidget);

    final popUpMenuButtonFinder = find.descendant(of: find7thBundle, matching: find.byType(PopupMenuButton<void>));
    await tester.tap(popUpMenuButtonFinder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await ss.capture('open_PopUpMenu');

    final isbnDecodingFinder = find.text('ISBN decoding');

    expect(isbnDecodingFinder, findsOneWidget);
    await tester.tap(isbnDecodingFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('ISBN_decoding');

    const isbnToAdd = '2853130282';

    expect(find.text(isbnToAdd), findsNothing);

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(textFieldFinder, isbnToAdd);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await ss.capture('isbn_field_is_filled');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await ss.capture('isbn_is_submitted');
    // controller is null
    // expect(tester.widget<TextFormField>(textFieldFinder).controller?.text.isEmpty, isTrue);
    expect(find.byWidgetPredicate((widget) => widget is SelectableText && widget.data == isbnToAdd), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('back_to_home');

    await tapPopMenu_ISBNDecoding();

    await ss.capture('open_isbn_decoding_again');
    expect(find.byWidgetPredicate((widget) => widget is SelectableText && widget.data == isbnToAdd), findsOneWidget);

    final deleteIconFinder = find.byIcon(Icons.delete);
    expect(deleteIconFinder, findsOneWidget);
    await tester.tap(deleteIconFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('isbn_deleted');
    expect(find.text(isbnToAdd), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('back_to_home');
    await tapPopMenu_ISBNDecoding();
    expect(find.text(isbnToAdd), findsNothing);
    await ss.capture('no_isbn_as_initial');
  });
}

void searchBar(final IntegrationTestWidgetsFlutterBinding binding) {
  final ss = Screenshotter(binding, 'searchbar');

  testWidgets('test SearchBar', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    await ss.capture('home');

    final searchIconFinder = find.byIcon(Icons.search);
    expect(searchIconFinder, findsOneWidget);
    await tester.tap(searchIconFinder);

    await tester.pumpAndSettle(const Duration(seconds: 3));
    await ss.capture('open_seach_bar');

    final findSearchBarTextField = find
        .byWidgetPredicate((widget) => widget is TextField && widget.decoration?.hintText == 'Search all the bundles');
    expect(findSearchBarTextField, findsOneWidget);
    await tester.enterText(findSearchBarTextField, 'nord');

    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('type_nord');
    expect(
        find.byWidgetPredicate((widget) => widget is Text && widget.data!.startsWith('Harricana: Le Royaume du Nord')),
        findsOneWidget);

    await tester.pageBack();
  });
}

void basicScreenshot(IntegrationTestWidgetsFlutterBinding binding) {
  final ss = Screenshotter(binding, 'basic_screenshot');

  testWidgets('verify screenshot', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    await ss.capture('home');

    // Pump another frame before taking the screenshot.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await ss.capture('2');

    final sendIconFinder = find.byIcon(Icons.send);
    // Not all bundle might be visible, but we can expect to at least see the first 4 of them
    expect(tester
        .elementList(sendIconFinder)
        .length, greaterThan(4));

    await tester.tap(sendIconFinder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('MetadataCollecting');

    await tester.pageBack();

    await tester.pumpAndSettle(const Duration(seconds: 1));

    await ss.capture('back_to_home');
  });
}
