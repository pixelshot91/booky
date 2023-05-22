use itertools::Itertools;

use crate::common::{self, Author};

pub fn extract_metadata(isbn_search_result: &str) -> Option<common::BookMetaDataFromProvider> {
    let doc = scraper::Html::parse_document(isbn_search_result);

    let title_selector = scraper::Selector::parse(".main-infos [itemprop=\"name\"]").unwrap();
    let title = doc
        .select(&title_selector)
        .exactly_one()
        .unwrap()
        .first_child()
        .unwrap()
        .value()
        .as_text()
        .unwrap()
        .to_string();

    let author_selector = scraper::Selector::parse(".main-infos [itemprop=\"author\"]").unwrap();
    let author_last_name = doc
        .select(&author_selector)
        .exactly_one()
        .unwrap()
        .first_child()
        .unwrap()
        .value()
        .as_text()
        .unwrap()
        .to_string();

    Some(common::BookMetaDataFromProvider {
        title: Some(title),
        authors: vec![Author {
            first_name: "".to_owned(),
            last_name: author_last_name,
        }],
        ..Default::default()
    })
}

#[cfg(test)]
mod tests {
    use std::vec;

    use crate::common::Author;

    use super::*;

    #[test]
    fn test_extract_prices() {
        let html = std::fs::read_to_string("src/leslibraires/test/9782286056636.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(common::BookMetaDataFromProvider {
                title: Some("Les autres et moi".to_owned()),
                authors: vec![Author {
                    first_name: "".to_owned(),
                    last_name: "Isabelle Filliozat".to_owned()
                }],
                ..Default::default()
            })
        );
    }
}
