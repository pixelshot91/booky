// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a Flutter widget test can take a screenshot.
//
// For Web, this needs to be executed with the `test_driver/integration_test_extended_driver.dart`.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:integration_test/integration_test.dart';

import '_extended_test_io.dart' if (dart.library.html) '_extended_test_web.dart' as tests;

String? maybeFromEnv(String name) {
  return bool.hasEnvironment(name) ? String.fromEnvironment(name) : null;
}

// TODO: I would like to give the name of the test to run as parameter to run only some test
//  But it's difficult to pass argument to this main
//  The argument list of main is always empty
//  The environment variable does not contain the variable given in --dart-define
//  The only way to give some message to this main is through the driver.requestData
//  https://stackoverflow.com/questions/46475450/how-to-pass-an-environment-variable-to-a-flutter-driver-test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tests.main();
}
