import 'package:flutter_test/flutter_test.dart';

extension FinderExt on Finder {
  bool hasFoundOne() {
    return evaluate().length == 1;
  }

  /// Return the first and only match
  /// panic if the finder find zero or multiple matches
  Finder single() {
    expect(this, findsOneWidget);
    return this;
  }
}
