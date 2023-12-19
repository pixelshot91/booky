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
    adb shell 'rm -rf /storage/emulated/0/Android/data/fr.pimoid.booky.drive.debug/files/'
    adb push extra/mock_data/basic/ /storage/emulated/0/Android/data/fr.pimoid.booky.drive.debug/files/
    date=$(date +"%Y-%m-%d_%H-%M-%S") \
    screenshot_dir=real_android_device_$date flutter drive --driver=test_driver/screenshot_test.dart --target=integration_test/extended_test.dart --flavor=drive

test_screenshots +device_ids:
    echo {{device_ids}}
    cd test/tester && cargo run {{device_ids}}

test:
    /home/julien/Android/Sdk/platform-tools/adb devices -l
    just test_screenshots Pixel_6_API_29 Pixel_C_API_29_13inch

# vim:expandtab:sw=4:ts=4
