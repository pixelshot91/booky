sealed class BarcodeDetection {
  /// The minimum number of time the barcode stream decoder must see a barcode to consider it valid.
  /// Use the prevent false barcode decoding to show up (due to glare, poor image quality)
  static const minBarcodeOccurrence = 20;

  BarcodeDetection increaseCounter(void Function() onSureTransition);

  BarcodeDetection makeSure(void Function() onSureTransition);
}

class UnsureDetection implements BarcodeDetection {
  UnsureDetection() : occurrence = 1;

  UnsureDetection._(this.occurrence);

  int occurrence;

  @override
  BarcodeDetection increaseCounter(void Function() onSureTransition) {
    if (occurrence < BarcodeDetection.minBarcodeOccurrence - 1) {
      return UnsureDetection._(occurrence + 1);
    } else {
      print('UnsureDetection increaseCounter -> SureDetection');
      onSureTransition();
      return SureDetection();
    }
  }

  @override
  BarcodeDetection makeSure(void Function() onSureTransition) {
    onSureTransition();
    return SureDetection();
  }
}

class SureDetection implements BarcodeDetection {
  @override
  BarcodeDetection increaseCounter(void Function() onSureTransition) {
    return this;
  }

  @override
  BarcodeDetection makeSure(void Function() onSureTransition) {
    return this;
  }
}
