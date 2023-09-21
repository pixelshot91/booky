default: gen lint

gen:
    flutter pub get
    flutter_rust_bridge_codegen

lint:
    cd native && cargo fmt
    dart format .

clean:
    flutter clean
    cd native && cargo clean
    
serve *args='':
    flutter pub run flutter_rust_bridge:serve {{args}}

take_automated_screenshot:
    # 'flutter drive' seems to delete app data at the end of the run
    # So be sure to copy some mock data before every 'flutter drive'

    # Make sur the file/ folder does not exist, otherwise adb push create files/basic/to_publish instead of files/to_publish
    adb shell 'rm -r /storage/emulated/0/Android/data/fr.pimoid.booky.debug/files/'
    adb push extra/mock_data/basic/ /storage/emulated/0/Android/data/fr.pimoid.booky.debug/files/
    screenshot_dir=real_android_device flutter drive --driver=test_driver/screenshot_test.dart --target=integration_test/extended_test.dart --dart-define="only=searchbar"
    # screenshot_dir=real_android_device flutter drive --driver=test_driver/screenshot_test.dart --target=integration_test/extended_test.dart --dart-define="only=searchbar" --use-existing-app="http://127.0.0.1:37277/R2TKD1kh9N8=/"
    # screenshot_dir=real_android_device flutter drive --driver=test_driver/screenshot_test.dart --target=integration_test/extended_test.dart --dart-define="only=searchbar" --keep-app-running

test_screenshots +device_ids:
    echo {{device_ids}}
    cd test/tester && cargo run {{device_ids}}

test:
    /home/julien/Android/Sdk/platform-tools/adb devices -l
    just test_screenshots Pixel_6_API_29 Pixel_C_API_29_13inch

# vim:expandtab:sw=4:ts=4
