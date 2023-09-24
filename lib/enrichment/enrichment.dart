import '../bundle.dart';

sealed class BookyStep {}

class BundleSelectionStep implements BookyStep {}

class ISBNDecodingStep implements BookyStep {
  Bundle bundle;

  ISBNDecodingStep({required this.bundle});
}

class MetadataCollectingStep implements BookyStep {
  Bundle bundle;

  MetadataCollectingStep({required this.bundle});
}

class AdEditingStep implements BookyStep {
  Bundle bundle;

  AdEditingStep({required this.bundle});
}
