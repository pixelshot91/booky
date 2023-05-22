use crate::{cached_client::CachedClient, common};
mod parser;
mod request;

pub struct LesLibraires;

impl common::Provider for LesLibraires {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let cached_client = CachedClient {
            http_client: client,
        };
        let isbn_search_result = request::isbn_search(&cached_client, isbn);
        parser::extract_metadata(&isbn_search_result)
    }
}
