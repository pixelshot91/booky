use crate::{client::Client, common};
mod parser;
mod request;

pub struct LesLibraires {
    pub client: Box<dyn Client>,
}

impl common::Provider for LesLibraires {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let isbn_search_result = request::isbn_search(&*self.client, isbn)?;
        parser::extract_metadata(&isbn_search_result)
    }
}
