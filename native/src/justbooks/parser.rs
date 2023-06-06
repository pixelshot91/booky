use crate::common::{html_select, BookMetaDataFromProvider};
use itertools::Itertools;

fn extract_author(author_scope: scraper::ElementRef) -> crate::common::Author {
    let author_span = author_scope
        .first_child()
        .expect("author scope > span shoud have a first child");

    crate::common::Author {
        first_name: author_span
            .value()
            .as_text()
            .expect("Should be a text")
            .trim()
            .to_string(),
        last_name: "".to_string(),
    }
}

pub fn extract_metadata(html: &str) -> Option<BookMetaDataFromProvider> {
    let doc = scraper::Html::parse_document(html);

    let book_select = html_select("div[itemscope][itemtype=\"http://schema.org/Book\"]");
    let res = doc.select(&book_select);
    let book_scope = match res.exactly_one() {
        Ok(book_scope) => book_scope,
        Err(_) => {
            eprintln!("Response should contain a element whose with id is itemscope and itemtype=\"https://schema.org/Book\"");
            return None;
        }
    };
    let title_select = html_select("[itemprop=\"name\"]");
    let title = book_scope
        .select(&title_select)
        .exactly_one()
        .expect("There should be exactly one element with itemprop=\"name\"")
        .first_child()
        .unwrap()
        .value()
        .as_text()
        .unwrap()
        .trim()
        .to_string();

    let authors_select = html_select("[itemprop=\"author\"]");
    let authors = book_scope
        .select(&authors_select)
        .map(extract_author)
        .collect_vec();

    let blurb = book_scope
        .select(&html_select("[itemprop=\"description\"]"))
        .at_most_one()
        .unwrap()
        .map(|d| {
            d.first_child()
                .unwrap()
                .value()
                .as_text()
                .unwrap()
                .trim()
                .to_string()
        });

    Some(BookMetaDataFromProvider {
        title: Some(title),
        authors,
        blurb,
        ..Default::default()
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extract_metadata_with_blurb() {
        let html = std::fs::read_to_string("src/justbooks/test/9782953189018.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(md, Some(BookMetaDataFromProvider {
            title: Some("La prière en sept chapitres par PADMASAMBHAVA".to_string()),
            authors: vec![crate::common::Author {
                first_name: "Tchimé Rigdzin Rinpotché; James Low".to_string(),
                last_name: "".to_string()
            }],
            blurb: Some("Traduction : Chhimed Rigdzin Rinpoche et James Low Tirées du Terma du Nord (Tchang Ter), ces prières furent écrites par Padmasambhava à la requête de ses cinq principaux disciples (Yéshé Tsogyel, Trisong Deutsen, etc.). On y retrouve le célèbre Sampa Lhundroup (prière qui exauce tous les souhaits) et le Bartché Namsel (prière qui élimine tous les obstacles). Avec texte en tibétain, phonétique, traduction mot à mot et traduction du vers. Introduction de James Low sur la foi et la dévotion dans le bouddhisme tibétain. Relié, 322 pages".to_owned()),
            keywords: vec![],
            market_price: vec![],
        }));
    }
    #[test]

    fn extract_metadata_without_blurb() {
        let html = std::fs::read_to_string("src/justbooks/test/9782298086294.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(BookMetaDataFromProvider {
                title: Some("1918 la terrible victoire".to_string()),
                authors: vec![],
                blurb: None,
                keywords: vec![],
                market_price: vec![],
            })
        );
    }
}