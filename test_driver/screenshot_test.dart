import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main(List<String> args) async {
  /* print('args : ${args}');
  print('exearg: ${Platform.executableArguments}');
  print('exe: ${Platform.executable}');
  print('env: ${Platform.environment}');
  const ss = String.fromEnvironment('target');



  print('ss = $ss');
  */
  final screenshotDir = Platform.environment['screenshot_dir'];
  try {
    final driver = await FlutterDriver.connect();
    await driver.requestData('myString');
    await integrationDriver(
      driver: driver,
      onScreenshot: (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
        print('integrationDriver.onScreenshot(screenshotName = $screenshotName, args = $args');
        final File image = await File('screenshots/$screenshotDir/$screenshotName.png').create(recursive: true);
        await image.writeAsBytes(screenshotBytes);
        return true;
      },
    );
  } catch (e) {
    print('Error occured: $e');
  }
}
