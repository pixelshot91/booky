use crate::common;
mod parser;
mod request;

pub struct GoogleBooks;

impl common::Provider for GoogleBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaData> {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let isbn_search_response = request::search_by_isbn(&client, isbn);
        let self_link = parser::extract_self_link_from_isbn_response(&isbn_search_response);
        let book_page = request::get_volume(&client, &self_link);
        Some(parser::extract_metadata_from_self_link_response(&book_page))
    }
}


