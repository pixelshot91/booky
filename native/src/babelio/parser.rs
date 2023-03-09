use crate::common::{html_select, BookMetaData};
use itertools::Itertools;

#[derive(PartialEq, Debug)]
pub enum BlurbRes {
    SmallBlurb(String),
    BigBlurb(String),
}

pub fn extract_blurb(html: &str) -> BlurbRes {
    let doc = scraper::Html::parse_document(html);

    let selector = scraper::Selector::parse("#d_bio").expect(
        format!(
            "Response should contain a element whose id is 'd_bio', html is {:?}",
            html
        )
        .as_str(),
    );
    let mut res = doc.select(&selector);

    let d_bio = res.next().expect(
        format!(
            "There should be exactly one element with id 'd_bio', html {:?}",
            html
        )
        .as_str(),
    );

    // Some books do not folow the general strucuture: https://www.babelio.com/livres/Pullman--la-croisee-des-mondes-tome-2--La-tour-des-anges/59278
    // It looks like a bug from Babelio because the style span do not close
    // So I must use a css-style selector instead of going down the DOM tree
    let s = scraper::Selector::parse("a[onclick^=\"javascript\"]").unwrap();
    let mut onclick_elements = d_bio.select(&s);
    let on_click_element = onclick_elements.next();
    if let Some(_) = onclick_elements.next() {
        panic!("There should be one or zero element with onclick attribute in the d_bio element");
    }
    match on_click_element {
        None => {
            let dbio_second_to_last_child = d_bio
                .children()
                .rev()
                .nth(1)
                .expect("d_bio should have a second to last children (the style span)");
            BlurbRes::SmallBlurb(
                dbio_second_to_last_child
                    .value()
                    .as_text()
                    .unwrap()
                    .to_string(),
            )
        }
        Some(on_click_element) => {
            let on_click = on_click_element
                .value()
                .attr("onclick")
                .expect("<a href ...> should have a 'onclick' attribute");
            let re = regex::Regex::new(r"javascript:voir_plus_a\('#d_bio',1,(\d+)\);").unwrap();

            let single_capture = re
                .captures_iter(on_click)
                .next()
                .expect("The onclick should match with the regex");
            let id_obj = &single_capture[1];
            BlurbRes::BigBlurb(String::from(id_obj))
        }
    }
}

pub fn extract_title_author_keywords(html: &str) -> BookMetaData {
    let doc = scraper::Html::parse_document(html);

    let book_select = html_select("div[itemscope][itemtype=\"https://schema.org/Book\"]");
    let res = doc.select(&book_select);
    let book_scope = res.exactly_one().expect(format!(
        "Response should contain a element whose with id is itemscope and itemtype=\"https://schema.org/Book\", html is {:?}",
        html
    )
    .as_str());
    let title_select = html_select("[itemprop=\"name\"]");
    let mut res2 = book_scope.select(&title_select).into_iter();
    let title = res2
        .next()
        .expect("There should be at least one element with itemprop=\"name\"")
        .first_child()
        .unwrap()
        .first_child()
        .unwrap()
        .value()
        .as_text()
        .unwrap()
        .trim()
        .to_string();

    let binding =
        html_select("[itemprop=\"author\"][itemscope][itemtype=\"https://schema.org/Person\"]");
    let r = book_scope.select(&binding);

    let authors = r
        .map(|author_scope| {
            let author_span = author_scope
                .first_child()
                .expect("author_scope shoud have a first child <a ...>")
                .first_child()
                .expect("author scope > a shoud have a first child <span ...>");
            let first_name = author_span
                .first_child()
                .expect("author scope > a > span shoud have a first child which is first name")
                .value()
                .as_text()
                .expect("should be a text")
                .trim()
                .to_string();
            let last_name = author_span
                .children()
                .nth(1)
                .expect("author scope > a > span shoud have a second child which is the last name")
                .first_child()
                .unwrap()
                .value()
                .as_text()
                .expect("should be a text")
                .trim()
                .to_string();
            crate::common::Author {
                first_name,
                last_name,
            }
        })
        .collect_vec();

    let keywords_scope = book_scope
        .select(&html_select("[class=\"tags\"]"))
        .exactly_one()
        .unwrap();
    let keywords = keywords_scope
        .children()
        .filter_map(|c| {
            Some(
                c.first_child()?
                    .value()
                    .as_text()
                    .expect("c should be a text")
                    .trim()
                    .to_string(),
            )
        })
        .collect();
    BookMetaData {
        title,
        authors,
        keywords,
        ..Default::default()
    }
}

pub fn parse_blurb(raw_blurb: &str) -> Option<String> {
    Some(raw_blurb.trim().replace("<br>", "\n"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extract_id_obj_from_file() {
        let html = std::fs::read_to_string("src/babelio/test/get_book.html").unwrap();
        let id_obj = extract_blurb(&html);
        assert_eq!(id_obj, BlurbRes::BigBlurb("827593".to_string()));
    }
    #[test]
    pub fn extract_title_author_keywords_from_file() {
        let html = std::fs::read_to_string("src/babelio/test/get_book_minimal.html").unwrap();
        let title_author_keywords = extract_title_author_keywords(&html);
        assert_eq!(
            title_author_keywords,
            BookMetaData {
                title: "Le nom de la bête".to_string(),
                authors: vec![crate::common::Author {
                    first_name: "Daniel".to_string(),
                    last_name: "Easterman".to_string()
                }],
                blurb: None,
                keywords: [
                    "roman",
                    "fantastique",
                    "policier historique",
                    "romans policiers et polars",
                    "thriller",
                    "terreur",
                    "action",
                    "démocratie",
                    "mystique",
                    "islam",
                    "intégrisme religieux",
                    "catholicisme",
                    "religion",
                    "terrorisme",
                    "extrémisme",
                    "egypte",
                    "médias",
                    "thriller religieux",
                    "littérature irlandaise",
                    "irlande"
                ]
                .map(|s| s.to_string())
                .to_vec(),
            }
        );
    }
}
