use crate::{client::Client, common};
mod parser;
mod request;

pub struct AbeBooks {
    pub client: Box<dyn Client>,
}

impl common::Provider for AbeBooks {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<common::BookMetaDataFromProvider> {
        let isbn_search_result = request::isbn_search(&*self.client, isbn);
        let prices = parser::extract_prices(&isbn_search_result);
        Some(common::BookMetaDataFromProvider {
            market_price: prices,
            ..Default::default()
        })
    }
}
