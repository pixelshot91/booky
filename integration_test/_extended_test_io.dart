// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:booky/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /*testWidgets('verify text', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // Pump a frame.
    await tester.pumpAndSettle();

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data!.startsWith('Platform: ${Platform.operatingSystem}'),
      ),
      findsOneWidget,
    );
  });*/

  testWidgets('verify screenshot', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    final List<int> firstPng = await binding.takeScreenshot('1');
    expect(firstPng.isNotEmpty, isTrue);

    // Pump another frame before taking the screenshot.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final List<int> secondPng = await binding.takeScreenshot('2');
    expect(secondPng.isNotEmpty, isTrue);

    final Finder f = find.byIcon(Icons.send);
    expect(tester.elementList(f).length, equals(5));

    await tester.tap(f.first);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('3');

    await tester.pageBack();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('4');
  });
}
