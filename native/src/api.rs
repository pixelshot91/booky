use crate::common::Provider;
use crate::common::{Ad, BookMetaData};
use crate::publisher::Publisher;
use crate::{babelio, google_books, leboncoin};

pub enum ProviderEnum {
    Babelio,
    GoogleBooks,
}

pub fn get_metadata_from_provider(provider: ProviderEnum, isbn: String) -> Option<BookMetaData> {
    match provider {
        ProviderEnum::Babelio => babelio::Babelio {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::GoogleBooks => {
            google_books::GoogleBooks {}.get_book_metadata_from_isbn(&isbn)
        }
    }
}

pub fn publish_ad(ad: Ad) -> () {
    let lbc_publisher = leboncoin::Leboncoin {};
    Publisher::publish(&lbc_publisher, ad);
}
