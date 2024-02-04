import 'package:booky/src/rust/api/api.dart' as rust;

extension ProviderEnumExt on rust.ProviderEnum {
  String get loc {
    switch (this) {
      case rust.ProviderEnum.babelio:
        return 'Babelio';
      case rust.ProviderEnum.googleBooks:
        return 'GoogleBooks';
      case rust.ProviderEnum.booksPrice:
        return 'BooksPrice';
      case rust.ProviderEnum.abeBooks:
        return 'AbeBooks';
      case rust.ProviderEnum.lesLibraires:
        return 'LesLibraires';
      case rust.ProviderEnum.justBooks:
        return 'JustBooks';
    }
  }
}
