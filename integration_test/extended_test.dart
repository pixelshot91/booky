// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/driver_extension.dart';
import 'package:integration_test/integration_test.dart';

import '_extended_test_io.dart' if (dart.library.html) '_extended_test_web.dart' as tests;

String? maybeFromEnv(String name) {
  return bool.hasEnvironment(name) ? String.fromEnvironment(name) : null;
}

int main(List<String> arguments) {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  enableFlutterDriverExtension(handler: (message) {
    print('message receive: $message');
    return Future(() => message.toString());
    /*
    if (message.startsWith(pattern) == 'waiting_test_completion') {
      // Have Driver program wait for this future completion at tearDownAll.
      return completer.future;
    } else {
      fail('Unexpected message from Driver: $message');
    }*/
  });
  print('End of enableFlutterDriverExtension');
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  return tests.main(only: maybeFromEnv('only'));
}
