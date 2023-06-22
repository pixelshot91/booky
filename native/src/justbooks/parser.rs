use crate::common::{html_select, BookMetaDataFromProvider};
use itertools::Itertools;
use regex::Regex;

fn extract_authors(author_scope: scraper::ElementRef) -> Vec<crate::common::Author> {
    let authors_span = author_scope
        .first_child()
        .expect("author scope > span shoud have a first child");

    let authors_string = authors_span
        .value()
        .as_text()
        .expect("Should be a text")
        .to_string();

    authors_string
        .split(';')
        .map(|author_string| {
            if let Some((last_name, first_name)) = author_string.split_once(',') {
                crate::common::Author {
                    first_name: first_name.trim().to_owned(),
                    last_name: last_name.trim().to_owned(),
                }
            } else {
                crate::common::Author {
                    first_name: author_string.trim().to_owned(),
                    last_name: "".to_owned(),
                }
            }
        })
        .collect_vec()
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
        .map(|c| parse_title(c.value().as_text().unwrap()));

    let authors_select = html_select("[itemprop=\"author\"]");
    let authors = book_scope
        .select(&authors_select)
        .at_most_one()
        .unwrap()
        .map_or(vec![], extract_authors);

    let blurb = book_scope
        .select(&html_select("[itemprop=\"description\"]"))
        .at_most_one()
        .unwrap()
        .map(|d| parse_blurb(&d.inner_html()));

    Some(BookMetaDataFromProvider {
        title,
        authors,
        blurb,
        ..Default::default()
    })
}

// JustBooks often add some description to the title, wrap in parenthesis
// For instance "(French Edition)"
fn parse_title(raw_title: &str) -> String {
    let re = Regex::new(r"\(.*?\)").unwrap();
    let res = re.replace_all(raw_title, "");
    res.trim().to_string()
}

fn parse_blurb(raw_blurb: &str) -> String {
    let text = html2text::from_read(raw_blurb.as_bytes(), usize::MAX);
    text.trim().to_string()
}

#[cfg(test)]
mod tests {
    use crate::common::Author;

    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn extract_metadata_with_blurb() {
        let html = std::fs::read_to_string("src/justbooks/test/9782953189018.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(md, Some(BookMetaDataFromProvider {
            title: Some("La prière en sept chapitres par PADMASAMBHAVA".to_string()),
            authors: vec![crate::common::Author {
                first_name: "Tchimé Rigdzin Rinpotché".to_string(),
                last_name: "".to_string()
            },
            crate::common::Author {
                first_name: "James Low".to_string(),
                last_name: "".to_string()
            },
            ],
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

    #[test]
    fn extract_metadata_with_html_blurb() {
        let html = std::fs::read_to_string("src/justbooks/test/9782253051206.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(BookMetaDataFromProvider {
                title: Some("Samarcande".to_string()),
                authors: vec![Author{first_name:"Amin".to_owned(), last_name:"Maalouf".to_owned()}],
                blurb: Some(r#"Samarcande, c'est la Perse d'Omar Khayyam, poète du vin, libre penseur, astronome de génie, mais aussi celle de Hussan Sabbah, fondateur de l'ordre des Assassins, la secte la plus redoutable de l'histoire. Samarcande, c'est l'Orient du XIXè siècle et du début du XXe, le voyage dans un univers où les rêves de liberté ont toujours su défier les fanatismes. Samarcande, c'est l'aventure d'un manuscrit né au XIe siècle, égaré lors des invasions mongoles et retrouvé six siècles plus tard.

Une fois encore, nous conduisant sur la route de la soie à travers les plus envoûtantes cités d'Asie, Amin Maalouf nous ravit par son extraordinaire talent de conteur. A la suite d'Edgar Allan Poe, il nous dit : "Et maintenant, promène ton regard sur Samarcande ! N'est-elle pas reine de la Terre ? Fière, au- dessus de toutes les villes, et dans ses mains leurs destinées ?"

Amin Maalouf est l'auteur de Léon l'Africain, ouvrage traduit aujourd'hui dans le monde entier. Son premier livre, Les Croisades vues par les Arabes, est devenu lui aussi un classique."#.to_string()),
                keywords: vec![],
                market_price: vec![],
            })
        );
    }

    #[test]
    fn extract_metadata_with_two_authors() {
        let html = std::fs::read_to_string("src/justbooks/test/9782290042359.html").unwrap();
        let md = extract_metadata(&html);
        assert_eq!(
            md,
            Some(BookMetaDataFromProvider {
                title: Some("Fièvre mutante: Une enquête de l'inspecteur Pendergast".to_string()),
                authors: vec![
                    Author {
                        first_name: "Lincoln".to_owned(),
                        last_name: "Child".to_owned()
                    },
                    Author {
                        first_name: "Douglas".to_owned(),
                        last_name: "Preston".to_owned()
                    },
                ],
                blurb: Some(r#"511pages. poche. Broché."#.to_string()),
                keywords: vec![],
                market_price: vec![],
            })
        );
    }
}
