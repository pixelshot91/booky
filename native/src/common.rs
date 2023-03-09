#[derive(Default, Debug, PartialEq)]
pub struct BookMetaData {
    pub title: String,
    pub authors: Vec<Author>,
    // A book blurb is a short promotional description.
    // A synopsis summarizes the twists, turns, and conclusion of the story.
    pub blurb: Option<String>,
    pub keywords: Vec<String>,
}

#[derive(Debug, PartialEq)]
pub struct Author {
    pub first_name: String,
    pub last_name: String,
}

pub fn html_select(sel: &str) -> scraper::Selector {
    scraper::Selector::parse(sel).unwrap()
}

pub trait Provider {
    fn get_book_metadata_from_isbn(&self, isbn: &str) -> Option<BookMetaData>;
}

pub struct Ad {
    pub title: String,
    pub description: String,
    pub price_cent: i32,
    pub imgs_path: Vec<String>,
}
