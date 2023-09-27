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

    let blurb_selector = scraper::Selector::parse("#informations #infos-description").unwrap();
    let blurb = doc
        .select(&blurb_selector)
        .at_most_one()
        .unwrap()
        .map(|blurb_element| {
            blurb_element
                .first_child()
                .unwrap()
                .value()
                .as_text()
                .unwrap()
                .trim()
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
                .to_string()
                .parse::<f32>()
                .unwrap()
                + shipping_price
        });

    Some(common::BookMetaDataFromProvider {
        title,
        authors: author_last_name.map_or(vec![], |author| {
            vec![Author {
                first_name: "".to_owned(),
                last_name: author,
            }]
        }),
        blurb,
        market_price: price_with_shipping.map_or(vec![], |p| vec![p]),
        ..Default::default()
    })
}

#[cfg(test)]
mod tests {
    use std::vec;

    use crate::{common::Author, fs_helper::my_read_to_string};

    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn test_extract_prices() {
        let html = my_read_to_string("src/leslibraires/test/9782286056636.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(common::BookMetaDataFromProvider {
                title: Some("Les autres et moi".to_owned()),
                authors: vec![Author {
                    first_name: "".to_owned(),
                    last_name: "Isabelle Filliozat".to_owned()
                }],
                market_price: vec![22.00],
                ..Default::default()
            })
        );
    }

    #[test]
    fn test_extract_prices_and_blurb() {
        let html = my_read_to_string("src/leslibraires/test/9786202293969.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(common::BookMetaDataFromProvider {
                title: Some("Rue des Petites Écuries".to_owned()),
                authors: vec![Author {
                    first_name: "".to_owned(),
                    last_name: "Vicky Sommet".to_owned()
                }],
                blurb: Some("Deux femmes vivent leur vie sentimentale à deux époques différentes. Eva d'abord, la jeune Autrichienne réfugiée en France, rencontrera un bel inconnu pendant la 2nde guerre mondiale, une histoire qui ne restera pas sans suite, une fois arrivée à Paris. L'autre femme est la narratrice qui vit aujourd'hui dans une quête permanente de relations amoureuses qui n'existent que dans son imagination. Amours ou illusions d'amour, la rue des Petites Écuries sert de décor à ces liens qui se font et se défont au gré du temps qui passe. Et si les histoires d'amour finissent mal en général ... celles de l'auteure n'ont peut-être jamais vraiment commencé !".to_owned()),
                market_price: vec![26.90],
                ..Default::default()
            })
        );
    }
}
