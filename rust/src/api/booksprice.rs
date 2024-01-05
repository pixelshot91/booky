use crate::common::{self, BookMetaDataFromProvider};

mod request;
mod selenium_common;

pub struct BooksPrice;

impl common::Provider for BooksPrice {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let prices = request::extract_price_from_isbn(isbn);
        Some(BookMetaDataFromProvider {
            title: None,
            authors: vec![],
            blurb: None,
            keywords: vec![],
            market_price: prices.unwrap(),
        })
    }
}
