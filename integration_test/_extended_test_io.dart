// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:booky/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verify screenshot', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    await binding.takeScreenshot('1');

    // Pump another frame before taking the screenshot.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('2');

    final Finder f = find.byIcon(Icons.send);
    expect(tester.elementList(f).length, equals(5));

    await tester.tap(f.first);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('3');

    await tester.pageBack();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('4');
  });

  testWidgets('test SearchBar', (WidgetTester tester) async {
    // Build our app.
    app.main();

    // On Android, this is required prior to taking the screenshot.
    await binding.convertFlutterSurfaceToImage();

    // Pump a frame before taking the screenshot.
    await tester.pumpAndSettle();
    await binding.takeScreenshot('1');

    final Finder f = find.byIcon(Icons.search);
    expect(tester.elementList(f).length, equals(1));
    await tester.tap(f.first);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('2');

    await tester.pageBack();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('4');
  });
}
