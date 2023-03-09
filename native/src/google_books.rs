use crate::common;
mod parser;
mod request;

pub struct GoogleBooks;

impl common::Provider for GoogleBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaData> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let isbn_search_response = request::search_by_isbn(&client, isbn);
        Some(parser::extract_metadata_from_isbn_response(&isbn_search_response))
    }
}


