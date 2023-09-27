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
}

mod structs {
    use serde::{Deserialize, Serialize};

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Root<'a> {
        pub kind: &'a str,
        pub total_items: i64,
        pub items: Option<Vec<Item<'a>>>,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Item<'a> {
        // pub kind: &'a str,
        pub id: &'a str,
        // pub etag: &'a str,
        pub self_link: &'a str,
        pub volume_info: VolumeInfo<'a>,
        // pub sale_info: SaleInfo<'a>,
        // pub access_info: AccessInfo<'a>,
        // pub search_info: Option<SearchInfo<'a>>,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct VolumeInfo<'a> {
        pub title: &'a str,
        pub subtitle: Option<&'a str>,
        pub authors: Option<Vec<&'a str>>,
        // pub publisher: Option<&'a str>,
        // pub published_date: &'a str,
        // Should be an owned String in case the description contain escape characters like (\")
        // TODO: change all &str to String
        pub description: Option<String>,
        // pub industry_identifiers: Vec<IndustryIdentifier<'a>>,
        // pub reading_modes: ReadingModes,
        // pub page_count: i64,
        // pub print_type: &'a str,
        // pub categories: Option<Vec<&'a str>>,
        // pub maturity_rating: &'a str,
        // pub image_links: Option<ImageLinks<'a>>,
        // pub language: &'a str,
        // pub preview_link: &'a str,
        // pub info_link: &'a str,
        // pub canonical_volume_link: &'a str,
    }

    /* #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct IndustryIdentifier<'a> {
        #[serde(rename = "type")]
        pub type_field: &'a str,
        pub identifier: &'a str,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct ReadingModes {
        pub text: bool,
        pub image: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct PanelizationSummary {
        pub contains_epub_bubbles: bool,
        pub contains_image_bubbles: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct ImageLinks<'a> {
        pub small_thumbnail: &'a str,
        pub thumbnail: &'a str,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct SaleInfo<'a> {
        pub country: &'a str,
        pub saleability: &'a str,
        pub is_ebook: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct AccessInfo<'a> {
        pub country: &'a str,
        pub viewability: &'a str,
        pub embeddable: bool,
        pub public_domain: bool,
        pub text_to_speech_permission: &'a str,
        pub epub: Epub,
        pub pdf: Pdf,
        pub web_reader_link: &'a str,
        pub access_view_status: &'a str,
        pub quote_sharing_allowed: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Epub {
        pub is_available: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct Pdf {
        pub is_available: bool,
    }

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct SearchInfo<'a> {
        pub text_snippet: &'a str,
    }*/
}
