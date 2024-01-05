pub fn html_select(sel: &str) -> scraper::Selector {
    scraper::Selector::parse(sel).unwrap()
}

pub trait Provider {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<crate::api::api::BookMetaDataFromProvider>;
}

pub struct Ad {
    pub title: String,
    pub description: String,
    pub price_cent: i32,
    pub weight_grams: i32,
    pub imgs_path: Vec<String>,
}

pub fn url_to_path(url: &str) -> String {
    url.replace("/", "_slash_")
}

