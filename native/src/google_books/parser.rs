use itertools::Itertools;

use crate::common::{self, BookMetaDataFromProvider};

pub fn extract_self_link_from_isbn_response(html: &str) -> Option<String> {
    let s: structs::Root = serde_json::from_str(html).unwrap();
    s.items.map(|items| items[0].self_link.to_string())
}
pub fn extract_metadata_from_isbn_response(html: &str) -> common::BookMetaDataFromProvider {
    let s: structs::Root = serde_json::from_str(html).unwrap();
    let a = s.items.map(|items| {
        let first_book = &items[0].volume_info;

        let authors = first_book
            .authors
            .as_ref()
            .unwrap_or(&vec![])
            .iter()
            .map(|s| common::Author {
                first_name: "".to_string(),
                last_name: s.to_string(),
            })
            .collect_vec();
        let blurb = items[0].volume_info.description.clone().map(|d| {
            html2text::from_read(d.as_bytes(), usize::MAX)
                .trim()
                .to_owned()
        });
        BookMetaDataFromProvider {
            authors,
            blurb,
            ..Default::default()
        }
    });
    a.unwrap_or(BookMetaDataFromProvider {
        ..Default::default()
    })
}

pub fn extract_metadata_from_self_link_response(html: &str) -> common::BookMetaDataFromProvider {
    let s: structs::Item = serde_json::from_str(html).unwrap();
    let first_book = &s.volume_info;
    common::BookMetaDataFromProvider {
        title: Some(first_book.title.to_string()),
        authors: first_book
            .authors
            .as_ref()
            .unwrap_or(&vec![])
            .iter()
            .map(|s| common::Author {
                first_name: "".to_string(),
                last_name: s.to_string(),
            })
            .collect_vec(),

        blurb: first_book.description.clone().map(|d| {
            html2text::from_read(d.as_bytes(), usize::MAX)
                .trim()
                .to_owned()
        }),
        ..Default::default()
    }
}

#[cfg(test)]
mod tests {
    use crate::{common::BookMetaDataFromProvider, fs_helper::my_read_to_string};

    use super::*;

    use pretty_assertions::assert_eq;

    #[test]
    fn extract_self_link_from_file() {
        let html =
            my_read_to_string("src/google_books/test/9782744170812/isbn_response.html").unwrap();
        let self_link = extract_self_link_from_isbn_response(&html);
        assert_eq!(
            self_link,
            Some("https://www.googleapis.com/books/v1/volumes/DQUFSQAACAAJ".to_string())
        )
    }

    #[test]
    fn extract_metadata_from_file() {
        let html = my_read_to_string("src/google_books/test/9782744170812/self_link_response.html")
            .unwrap();
        let metadata = extract_metadata_from_self_link_response(&html);
        assert_eq!(metadata, BookMetaDataFromProvider{
          title: Some("La cité de Dieu".to_string()),
          authors:vec![common::Author{first_name: "".to_string(), last_name: "Paulo Lins".to_string()}],
          blurb: Some("Au Brésil, l'évolution d'un bidonville entre les années 1960 et 1980, à travers l'histoire de deux garçons qui suivent des voies différentes : l'un fait des études et s'efforce de devenir photographe, l'autre crée son premier gang et devient, quelques années plus tard, le maître de la cité.".to_string()),
          ..Default::default()
    });
    }

    #[test]
    fn extract_self_link_from_file_2() {
        let html =
            my_read_to_string("src/google_books/test/9782266162777/isbn_response.html").unwrap();
        let self_link = extract_self_link_from_isbn_response(&html);
        assert_eq!(
            self_link,
            Some("https://www.googleapis.com/books/v1/volumes/HY_FNwAACAAJ".to_string())
        )
    }

    #[test]
    fn extract_metadata_from_file_2() {
        let html = my_read_to_string("src/google_books/test/9782266162777/self_link_response.html")
            .unwrap();
        let metadata = extract_metadata_from_self_link_response(&html);
        assert_eq!(
            metadata,
            BookMetaDataFromProvider {
                title: Some("L'essence du Tao".to_string()),
                authors: vec![common::Author {
                    first_name: "".to_string(),
                    last_name: "Pamela J. Ball".to_string()
                }],
                ..Default::default()
            }
        );
    }

    #[test]
    fn extract_metadata_from_isbn_response_with_escape_character() {
        let html = my_read_to_string("src/google_books/test/9782070456284/search_by_isbn_9782070456284.html")
            .unwrap();
        let metadata = extract_metadata_from_isbn_response(&html);
        assert_eq!(
            metadata,
            BookMetaDataFromProvider {
                title: None,
                authors: vec![common::Author {
                    first_name: "".to_string(),
                    last_name: "Philippe Djian".to_string()
                }],
                blurb: Some("Décembre est un mois où les hommes se saoulent - tuent, violent, se mettent en couple, reconnaissent des enfants qui ne sont pas les leurs, s'enfuient, gémissent, meurent... \"Oh...\" raconte trente jours d'une vie sans répit, où les souvenirs, le sexe et la mort se court-circuitent à tout instant.".into()),
                ..Default::default()
            }
        );
    }
}

/// The following field description compile, but the Cow is always of the Cow::Owned variant
/// ```
///   #[serde(borrow)]
///   pub my_field: Option<Cow<'a, str>>,
/// ```
///
/// See: https://github.com/serde-rs/serde/issues/2016
/// 
/// So I use:
/// ```
///   #[serde_as(as = "Option<BorrowCow>")]
///   pub subtitle: Option<Cow<'a, str>>,
/// ```
mod structs {
    use serde::{Deserialize, Serialize};
    use serde_with::{serde_as, BorrowCow};
    use std::borrow::Cow;

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Root<'a> {
        #[serde(borrow)]
        pub kind: Cow<'a, str>,
        pub total_items: i64,
        pub items: Option<Vec<Item<'a>>>,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Item<'a> {
        #[serde(borrow)]
        pub kind: Cow<'a, str>,
        #[serde(borrow)]
        pub id: Cow<'a, str>,
        #[serde(borrow)]
        pub self_link: Cow<'a, str>,
        pub volume_info: VolumeInfo<'a>,
    }

    #[serde_as]
    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct VolumeInfo<'a> {
        #[serde(borrow)]
        pub title: Cow<'a, str>,
        #[serde_as(as = "Option<BorrowCow>")]
        pub subtitle: Option<Cow<'a, str>>,

        // TODO: use a borrowing versino with cow to avoid copying when there is no escape character in the source string (most common case)
        pub authors: Option<Vec<String>>,

        #[serde_as(as = "Option<BorrowCow>")]
        pub description: Option<Cow<'a, str>>,
    }
}
