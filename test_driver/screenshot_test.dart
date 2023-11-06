import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main(List<String> args) async {
  // Every `flutter drive` run on a freshly installed app, with no permission enabled by default
  // Grant all the necessary permission first to avoid the permission pop-up
  await Process.run(
    'adb',
    ['shell', 'pm', 'grant', 'fr.pimoid.booky.debug', 'android.permission.CAMERA'],
  );
  final screenshotDir = Platform.environment['screenshot_dir'];
  try {
    await integrationDriver(
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
