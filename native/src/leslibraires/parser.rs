use itertools::Itertools;

use crate::common::{self, Author};

pub fn extract_metadata(isbn_search_result: &str) -> Option<common::BookMetaDataFromProvider> {
    let doc = scraper::Html::parse_document(isbn_search_result);

    let title_selector = scraper::Selector::parse(".main-infos [itemprop=\"name\"]").unwrap();
    let title = doc
        .select(&title_selector)
        .exactly_one()
        .ok()
        .map(|title_element| {
            title_element
                .first_child()
                .unwrap()
                .value()
                .as_text()
                .unwrap()
                .to_string()
        });

    let author_selector = scraper::Selector::parse(".main-infos [itemprop=\"author\"]").unwrap();
    let author_last_name = doc
        .select(&author_selector)
        .exactly_one()
        .ok()
        .map(|author_element| {
            author_element
                .first_child()
                .unwrap()
                .value()
                .as_text()
                .unwrap()
                .to_string()
        });

        let price_selector = scraper::Selector::parse("#product-offers .price").unwrap();
        let shipping_price: f32 = 10.0;

        let price_with_shipping = doc
            .select(&price_selector)
            .exactly_one()
            .ok()
            .map(|price_element| {
                price_element
                    .first_child()
                    .unwrap()
                    .value()
                    .as_text()
                    .unwrap()
                    .to_string().parse::<f32>().unwrap() + shipping_price
            });

    Some(common::BookMetaDataFromProvider {
        title,
        authors: author_last_name.map_or(vec![], |author| {
            vec![Author {
                first_name: "".to_owned(),
                last_name: author,
            }]
        }),
        market_price: price_with_shipping.map_or(vec![], |p| vec![p]),
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
                market_price: vec![12.00],
                ..Default::default()
            })
        );
    }
}
