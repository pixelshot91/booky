import 'package:flutter/material.dart';

class BarcodeLiveDetectionButton extends StatelessWidget {
  const BarcodeLiveDetectionButton({super.key, required this.onBarcodeDetectStart, required this.onBarcodeDetectStop});

  final void Function() onBarcodeDetectStart;
  final void Function() onBarcodeDetectStop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('_barcodeDetectionButtonGestureDetector'),
      onTapDown: (_) => onBarcodeDetectStart(),
      onTapUp: (_) => onBarcodeDetectStop(),
      onTapCancel: () => onBarcodeDetectStop(),
      child: AbsorbPointer(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.select_all_rounded),
          onPressed: () {},
          label: const Text('Live barcode detection'),
        ),
      ),
    );
  }
}
