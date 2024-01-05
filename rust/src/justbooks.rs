use crate::{client::Client, common};
mod parser;
mod request;

pub struct JustBooks {
    pub client: Box<dyn Client>,
}

impl common::Provider for JustBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<crate::api::api::BookMetaDataFromProvider> {
        let book_page = request::get_book_page(&*self.client, isbn);
        parser::extract_metadata(&book_page)
    }
}
