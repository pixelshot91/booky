use crate::{cached_client::CachedClient, common};
mod parser;
mod request;

pub struct JustBooks;

impl common::Provider for JustBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let cached_client = CachedClient {
            http_client: client,
        };
        let book_page = request::get_book_page(&cached_client, isbn);
        parser::extract_metadata(&book_page)
    }
}
