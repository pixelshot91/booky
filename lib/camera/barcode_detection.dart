import 'package:audioplayers/audioplayers.dart';

sealed class BarcodeDetection {
  /// The minimum number of time the barcode stream decoder must see a barcode to consider it valid.
  /// Use the prevent false barcode decoding to show up (due to glare, poor image quality)
  static const minBarcodeOccurrence = 20;

  BarcodeDetection increaseCounter();
  BarcodeDetection makeSure();
}

class UnsureDetection implements BarcodeDetection {
  UnsureDetection() : occurrence = 1;
  UnsureDetection._(this.occurrence);
  int occurrence;

  @override
  BarcodeDetection increaseCounter() {
    if (occurrence < BarcodeDetection.minBarcodeOccurrence - 1) {
      return UnsureDetection._(occurrence + 1);
    } else {
      print('UnsureDetection increaseCounter -> SureDetection');
      return SureDetection();
    }
  }

  @override
  BarcodeDetection makeSure() => SureDetection();
}

class SureDetection implements BarcodeDetection {
  SureDetection() {
    print('SureDetection ctor');
    AudioPlayer().play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);
  }

  @override
  BarcodeDetection increaseCounter() {
    return this;
  }

  @override
  BarcodeDetection makeSure() {
    return this;
  }
}
