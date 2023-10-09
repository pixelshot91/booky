use crate::common::{html_select, BookMetaDataFromProvider};
use itertools::Itertools;

#[derive(PartialEq, Debug)]
pub enum BlurbRes {
    SmallBlurb(String),
    BigBlurb(String),
}

pub fn extract_blurb(html: &str) -> Option<BlurbRes> {
    let doc = scraper::Html::parse_document(html);

    let selector =
        scraper::Selector::parse("#d_bio").expect("#d_bio should be a valid CSS selector");
    let mut res = doc.select(&selector);

    let d_bio = match res.next() {
        None => return None,
        Some(e) => e,
    };

    // Some books do not follow the general structure: https://www.babelio.com/livres/Pullman--la-croisee-des-mondes-tome-2--La-tour-des-anges/59278
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
            let dbio_second_to_last_child = d_bio.children().filter_map(|c| c.value().as_text());
            let mut blurb = String::new();
            dbio_second_to_last_child.for_each(|e| blurb.push_str(e));

            Some(BlurbRes::SmallBlurb(blurb))
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
            Some(BlurbRes::BigBlurb(String::from(id_obj)))
        }
    }
}

fn extract_author(author_scope: scraper::ElementRef) -> crate::common::Author {
    let author_span = author_scope
        .first_child()
        .expect("author_scope shoud have a first child <a ...>")
        .first_child()
        .expect("author scope > a shoud have a first child <span ...>");
    let mut children = author_span.children();
    let first_element = children
        .next()
        .expect("author scope > a > span shoud have a first child");
    let first_name;
    let last_name_element;
    if let Some(text) = first_element.value().as_text() {
        first_name = text.trim().to_string();
        last_name_element = children
            .next()
            .expect("author scope > a > span shoud have a second child which is the last name");
    } else {
        first_name = "".to_string();
        last_name_element = first_element;
    }

    let last_name = last_name_element
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
}

pub fn extract_title_author_keywords(html: &str) -> Option<BookMetaDataFromProvider> {
    let doc = scraper::Html::parse_document(html);

    let book_select = html_select("div[itemscope][itemtype=\"https://schema.org/Book\"]");
    let res = doc.select(&book_select);
    let book_scope = match res.exactly_one() {
        Ok(book_scope) => book_scope,
        Err(_) => {
            eprintln!("Response should contain a element whose with id is itemscope and itemtype=\"https://schema.org/Book\"");
            return None;
        }
    };
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

    let authors = r.map(extract_author).collect_vec();

    let keywords_scope = book_scope
        .select(&html_select("[class=\"tags\"]"))
        .at_most_one()
        .unwrap();
    let keywords = keywords_scope
        .map(|s| {
            s.children()
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
                .collect()
        })
        .unwrap_or_default();
    Some(BookMetaDataFromProvider {
        title: Some(title),
        authors,
        keywords,
        ..Default::default()
    })
}

pub fn parse_blurb(raw_blurb: &str) -> String {
    let text = html2text::from_read(raw_blurb.as_bytes(), usize::MAX);
    text.trim().to_string()
}

#[cfg(test)]
mod tests {
    use crate::fs_helper::my_read_to_string;
    use pretty_assertions::assert_eq;

    use super::*;

    #[test]
    fn extract_id_obj_from_file() {
        let html = my_read_to_string("src/babelio/test/get_book.html").unwrap();
        let id_obj = extract_blurb(&html);
        assert_eq!(id_obj, Some(BlurbRes::BigBlurb("827593".to_string())));
    }

    #[test]
    fn test_parse_blurb_with_special_charset() {
        let html =
            my_read_to_string("src/babelio/test/get_book_blurb_see_more_179245.html").unwrap();
        let text = parse_blurb(&html);
        assert_eq!(text, "La ville entière est sous le choc. Adam, un jeune autiste de neuf ans, a été retrouvé dans les bois à côté du corps sans vie d'une camarade d'école sauvagement poignardée. Quelques heures auparavant, les deux enfants avaient échappé à la vigilance des adultes pendant la récréation et s'étaient évanouis dans la nature. Tous les espoirs d'identifier le coupable reposent désormais sur le témoignage d'Adam. Mais, replié sur lui-même, il ne réagit pas et refuse de communiquer. Commence alors pour Cara, sa mère, un subtil exercice d'interprétation : saura-t-elle déchiffrer les silences de son fils et aider les enquêteurs à débusquer le meurtrier ? Thriller psychologique, Au fond des yeux raconte avec pudeur et justesse le courageux combat d'une mère contre les préjugés et l'isolement.");
    }

    #[test]
    pub fn extract_title_author_keywords_from_file() {
        let html = my_read_to_string("src/babelio/test/get_book_minimal.html").unwrap();
        let title_author_keywords = extract_title_author_keywords(&html);
        assert_eq!(
            title_author_keywords,
            Some(BookMetaDataFromProvider {
                title: Some("Le nom de la bête".to_string()),
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
                market_price: vec![],
            })
        );
    }

    #[test]
    pub fn extract_title_author_keywords_from_file_9782253143321() {
        let html =
            my_read_to_string("src/babelio/test/9782253143321_le_livre_tibetain_des_morts.html")
                .unwrap();
        let title_author_keywords = extract_title_author_keywords(&html);
        assert_eq!(
            title_author_keywords,
            Some(BookMetaDataFromProvider {
                title: Some("Bardo-Thödol : Le livre tibétain des morts".to_string()),
                authors: vec![crate::common::Author {
                    first_name: "".to_string(),
                    last_name: "Padmasambhava".to_string()
                }],
                blurb: None,
                keywords: [
                    "document",
                    "classique",
                    "histoire",
                    "mystique",
                    "zen",
                    "mort",
                    "croyances",
                    "pensées philosophiques",
                    "libération",
                    "réincarnation",
                    "Médiumnité",
                    "religion",
                    "spiritualité",
                    "Bouddhistes",
                    "bouddhisme tibétain",
                    "vie après la mort",
                    "bouddhisme",
                    "voyage initiatique",
                    "ésotérisme",
                    "philosophie"
                ]
                .map(|s| s.to_string())
                .to_vec(),
                market_price: vec![],
            })
        );
    }

    #[test]
    pub fn parse_small_blurb() {
        let html = my_read_to_string("src/babelio/test/get_book_small_blurb.html").unwrap();
        let id_obj = extract_blurb(&html);
        assert_eq!(id_obj, Some(BlurbRes::SmallBlurb("\n\t\t\t\t\t\t\t\t\t\tAu cœur de la nuit, un wagon se détache d'un train-couchettes et s'arrête soudain. D'abord persuadés qu'il s'agit d'une panne, les occupants découvrent qu'ils sont perdus au milieu de nulle part. Abandonnés, oubliés par les secours, certains partent en éclaireurs et disparaissent. Leurs cadavres sont retrouvés, dans une ville déserte et en ruine. La terreur s'empare alors des survivants...".to_string())));
    }

    #[test]
    pub fn parse_small_blurb_multipart() {
        let html = my_read_to_string("src/babelio/test/get_small_blurb_multipart.html").unwrap();
        let id_obj = extract_blurb(&html);
        assert_eq!(id_obj, Some(BlurbRes::SmallBlurb("\n\t\t\t\t\t\t\t\t\t\tCinq destins, un seul choix.\nTris vit dans un monde post-apocalyptique où la société est divisée en cinq factions : les Audacieux, les Altruistes, les Sincères, les Érudits, les Fraternels.\nÀ 16 ans, elle doit choisir son appartenance pour le reste de sa vie. Cas rarissime, son test d'aptitudes n'est pas concluant.\nElle est divergente.\nCe secret peut la sauver...\nOu la tuer.\n\n\t\t\t\t\t\t\t\t\t".to_string())));
    }
}
