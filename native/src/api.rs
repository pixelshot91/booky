use crate::cached_client::CachedClient;
use crate::common::{Ad, BookMetaDataFromProvider};
use crate::common::{LbcCredential, Provider};
use crate::publisher::Publisher;
use crate::{babelio, booksprice, google_books, leboncoin};

pub enum ProviderEnum {
    Babelio,
    GoogleBooks,
    BooksPrice,
}

pub fn get_metadata_from_provider(
    provider: ProviderEnum,
    isbn: String,
) -> Option<BookMetaDataFromProvider> {
    match provider {
        ProviderEnum::Babelio => babelio::Babelio {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::GoogleBooks => google_books::GoogleBooks {
            client: Box::new(CachedClient {
                http_client: reqwest::blocking::Client::builder().build().unwrap(),
            }),
        }
        .get_book_metadata_from_isbn(&isbn),
        ProviderEnum::BooksPrice => booksprice::BooksPrice {}.get_book_metadata_from_isbn(&isbn),
    }
}

pub fn publish_ad(ad: Ad, credential: LbcCredential) -> bool {
    let lbc_publisher = leboncoin::Leboncoin {};
    Publisher::publish(&lbc_publisher, ad, credential)
}
