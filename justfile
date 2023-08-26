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

take_autamted_screenshot:
    # 'flutter drive' seems to delete app data at the end of the run
    # So be sure to copy some mock data before every 'flutter drive'
    adb push extra/mock_data/basic/*/ /storage/emulated/0/Android/data/fr.pimoid.booky.debug/files
    flutter drive --driver=test_driver/screenshot_test.dart --target=integration_test/extended_test.dart

# vim:expandtab:sw=4:ts=4
