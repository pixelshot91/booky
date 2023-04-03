use crate::common::{self, BookMetaData};

mod request;
mod selenium_common;

pub struct BooksPrice;

impl common::Provider for BooksPrice {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaData> {
      let prices = request::extract_price_from_isbn(isbn);
      Some(BookMetaData{ title: None, authors: vec![], blurb: None, keywords: vec![], market_price: prices.unwrap() })
    }
}
