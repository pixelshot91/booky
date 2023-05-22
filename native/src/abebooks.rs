use crate::{cached_client::CachedClient, common};
mod parser;
mod request;

pub struct AbeBooks;

impl common::Provider for AbeBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let cached_client = CachedClient {
            http_client: client,
        };
        let isbn_search_result = request::isbn_search(&cached_client, isbn);
        let prices = parser::extract_prices(&isbn_search_result);
        Some(common::BookMetaDataFromProvider {
            market_price: prices,
            ..Default::default()
        })
    }
}
