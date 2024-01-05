use anyhow::{Ok, Result};
use flutter_rust_bridge::frb;
use futures::future::join_all;
use itertools::Itertools;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs::File;
use std::io::{Read, Write};
use std::vec;
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

use crate::{abebooks, babelio, booksprice, fs_helper, google_books, justbooks, leslibraires};
use crate::client::Client;
use crate::common::{self};

#[derive(EnumIter, PartialEq, Eq, Hash, Debug, Deserialize, Serialize, Copy, Clone)]
pub enum ProviderEnum {
    Babelio,
    GoogleBooks,
    BooksPrice,
    AbeBooks,
    LesLibraires,
    JustBooks,
}

#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct Point {
    pub x: u16,
    pub y: u16,
}

#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct BarcodeDetectResult {
    pub value: String,
    pub corners: Vec<Point>,
}

#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct BarcodeDetectResults {
    pub results: Vec<BarcodeDetectResult>,
}

pub fn detect_barcode_in_image(img_path: String) -> Result<BarcodeDetectResults> {
    let output = std::process::Command::new(
        "/home/julien/Perso/LeBonCoin/chain_automatisation/booky/native/detect_barcode",
    )
        .arg(format!("--in={}", img_path))
        .output()?;

    if !output.status.success() {
        println!("status: {}", output.status);
        println!("stdout: {:?}", &std::str::from_utf8(&output.stdout));
        println!("stderr: {:?}", &std::str::from_utf8(&output.stderr));
        return Err(anyhow::anyhow!(
            "detect_barcode returned non-zero exit code"
        ));
    }

    let r: Vec<BarcodeDetectResult> =
        serde_json::from_str(&std::str::from_utf8(&output.stdout).unwrap()).unwrap();
    Ok(BarcodeDetectResults { results: r })
}

#[cfg(test)]
mod tests {
    use crate::api::ProviderEnum;

    use super::{BarcodeDetectResult, BarcodeDetectResults, Point};

    #[test]
    fn test_sort_longest() {
        for _ in 1..10 {
            let mut book_title: Option<String> = None;
            crate::api::replace_with_longest_string_if_none_or_empty(
                Some(&std::collections::HashMap::from([
                    (
                        ProviderEnum::AbeBooks,
                        Some(crate::common::BookMetaDataFromProvider {
                            title: Some("title1".to_owned()),
                            ..Default::default()
                        }),
                    ),
                    (
                        ProviderEnum::Babelio,
                        Some(crate::common::BookMetaDataFromProvider {
                            title: Some("title2".to_owned()),
                            ..Default::default()
                        }),
                    ),
                ])),
                |auto| &auto.title,
                &mut book_title,
            );
            println!("longest is {:?}", book_title);
            assert_eq!(book_title, Some("title1".to_owned()));
        }
    }

    #[test]
    fn test_detect_barcode_in_image() {
        let res =
            super::detect_barcode_in_image("tests/test_images/operation_napoleon.jpg".to_owned())
                .unwrap();
        println!("res = {:?}", res);
        assert_eq!(
            res,
            BarcodeDetectResults {
                results: vec![BarcodeDetectResult {
                    value: "9782757862582".to_owned(),
                    corners: vec![
                        Point { x: 3229, y: 2749 },
                        Point { x: 3089, y: 2746 },
                        Point { x: 3106, y: 1906 },
                        Point { x: 3246, y: 1909 },
                    ],
                }]
            }
        )
    }
}

pub fn get_metadata_from_isbns(isbns: Vec<String>, path: String) -> Result<()> {
    let res = isbns.iter().map(|isbn| {
        let mds: HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>> =
            ProviderEnum::iter()
                .map(|provider| {
                    let md = get_metadata_from_provider(provider, isbn.clone());
                    (provider, md)
                })
                .collect();
        (isbn, mds)
    });
    let hashmap: HashMap<&String, HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>> =
        HashMap::from_iter(res);

    let content = &serde_json::to_string(&hashmap).expect("Unable to serialize data");
    //  Make sure the filename is unique so the function is thread-safe
    let mut file = File::create(path)?;
    file.write_all(content.as_bytes())?;
    Ok(())
}

// FlutterRustBridge does not support returning HashMap, or template type (like MyPair<K, V>)
// So a type for each pair is created
#[derive(Debug)]
pub struct ISBNMetadataPair {
    pub isbn: String,
    pub metadatas: Vec<ProviderMetadataPair>,
}

#[derive(Debug)]
pub struct ProviderMetadataPair {
    pub provider: ProviderEnum,
    pub metadata: Option<common::BookMetaDataFromProvider>,
}

fn _get_auto_metadata_from_bundle(
    path: String,
) -> Result<HashMap<String, HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>> {
    let file = fs_helper::my_file_open(path)?;
    match file {
        fs_helper::MyFileOpenRes::Ok(mut file) => {
            let mut contents = String::new();
            file.read_to_string(&mut contents).unwrap();
            let raw_map: HashMap<
                String,
                HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>,
            > = serde_json::from_str(&contents)?;
            return Ok(raw_map);
        }
        fs_helper::MyFileOpenRes::NoFile => {
            return Ok(HashMap::new());
        }
    }
}

pub fn get_auto_metadata_from_bundle(path: String) -> Result<Vec<ISBNMetadataPair>> {
    let raw_map = _get_auto_metadata_from_bundle(path)?;

    let vec_of_vec = raw_map
        .iter()
        .collect_vec()
        .iter()
        .map(|entry| {
            let v2: Vec<ProviderMetadataPair> = entry
                .1
                .iter()
                .collect::<Vec<(&ProviderEnum, &Option<common::BookMetaDataFromProvider>)>>()
                .iter()
                .map(|entry| {
                    let res = ProviderMetadataPair {
                        provider: entry.0.to_owned(),
                        metadata: entry.1.to_owned(),
                    };
                    res
                })
                .collect_vec();
            ISBNMetadataPair {
                isbn: entry.0.to_owned(),
                metadatas: v2,
            }
        })
        .collect_vec();
    Ok(vec_of_vec)
}

#[derive(Debug, Deserialize, Serialize)]
pub enum ItemState {
    BrandNew,
    VeryGood,
    Good,
    Medium,
}

#[derive(Default, Debug, Deserialize, Serialize)]
#[frb(non_final)]
pub struct BundleMetaData {
    #[frb(non_final)]
    pub weight_grams: Option<i32>,
    #[frb(non_final)]
    pub item_state: Option<ItemState>,
    pub books: Vec<BookMetaData>,
}

#[derive(Debug, Deserialize, Serialize)]
#[frb(non_final)]
pub struct BookMetaData {
    #[frb(non_final)]
    pub isbn: String,
    #[frb(non_final)]
    pub title: Option<String>,
    #[frb(non_final)]
    pub authors: Vec<Author>,
    // A book blurb is a short promotional description.
    // A synopsis summarizes the twists, turns, and conclusion of the story.
    #[frb(non_final)]
    pub blurb: Option<String>,
    #[frb(non_final)]
    pub keywords: Vec<String>,
    #[frb(non_final)]
    pub price_cent: Option<i32>,
}

#[derive(Default, Debug, PartialEq, Deserialize, Serialize, Clone)]
pub struct BookMetaDataFromProvider {
    pub title: Option<String>,
    pub authors: Vec<Author>,
    // A book blurb is a short promotional description.
    // A synopsis summarizes the twists, turns, and conclusion of the story.
    pub blurb: Option<String>,
    pub keywords: Vec<String>,

    pub market_price: Vec<f32>,
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Deserialize, Serialize)]
pub struct Author {
    pub first_name: String,
    pub last_name: String,
}
//
// #[derive(Debug, PartialEq, Eq, Hash, Clone, Deserialize, Serialize)]
// pub struct AAAuthor {
//     pub first_name: String,
//     pub last_name: String,
// }

const METADATA_FILE_NAME: &str = "metadata.json";

pub fn get_manual_metadata_for_bundle(bundle_path: String) -> Result<BundleMetaData> {
    _get_manual_metadata_for_bundle(&bundle_path)
}

fn _get_manual_metadata_for_bundle(bundle_path: &String) -> Result<BundleMetaData> {
    let file = fs_helper::my_file_open(format!("{bundle_path}/{METADATA_FILE_NAME}"))?;
    match file {
        fs_helper::MyFileOpenRes::Ok(mut file) => {
            let mut contents = String::new();
            file.read_to_string(&mut contents).unwrap();
            let manual_bundle_md: BundleMetaData = serde_json::from_str(&contents).unwrap();
            return Ok(manual_bundle_md);
        }
        fs_helper::MyFileOpenRes::NoFile => {
            return Ok(BundleMetaData::default());
        }
    }
}

pub fn set_manual_metadata_for_bundle(
    bundle_path: String,
    bundle_metadata: BundleMetaData,
) -> Result<()> {
    let file_path = format!("{bundle_path}/{METADATA_FILE_NAME}");
    let content = serde_json::to_string(&bundle_metadata)?;
    std::fs::create_dir_all(bundle_path).unwrap();
    std::fs::write(&file_path, content)?;

    // On mtpfs new file are not accessible for opening. This is necessary to make this new file accessible
    if let fs_helper::MyFileOpenRes::Ok(file) = fs_helper::my_file_open(&file_path)? {
        file.sync_all()?;
    }

    Ok(())
}

/// Use tokio async to get all the data faster than just calling many times [`get_merged_metadata_for_bundle`]
pub fn get_merged_metadata_for_all_bundles(
    bundles_dir: String,
) -> Result<Vec<Option<BundleMetaData>>> {
    tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .unwrap()
        .block_on(async {
            let read_dir = std::fs::read_dir(bundles_dir)?;
            let mds_future = read_dir.map(|dir| async {
                let dir_entry = &dir.unwrap();
                let bundle_path = dir_entry.path().to_str().unwrap().to_owned();
                // Using spawn_blocking is fine to use with synchronous IO
                // It avoid to rewrite get_manual_metadata_for_bundle with async
                let md = tokio::task::spawn_blocking(|| {
                    let md = crate::api::get_merged_metadata_for_bundle(bundle_path);
                    md.ok()
                })
                    .await
                    .unwrap();
                (dir_entry.file_name(), md)
            });
            let mut md_with_name = join_all(mds_future).await;
            md_with_name.sort_by(|(dir_name1, _md1), (dir_name2, _md2)| dir_name1.cmp(dir_name2));
            let sorted_md = md_with_name.into_iter().map(|(_, b)| b).collect_vec();
            Ok(sorted_md)
        })
}

// Retrieve a summary of all the information of a bundle
// If a book metadata is not available, try to use a metadata from a Provider
pub fn get_merged_metadata_for_bundle(bundle_path: String) -> Result<BundleMetaData> {
    let mut manual_bundle_md = _get_manual_metadata_for_bundle(&bundle_path)?;

    // Get MD from Provider
    let bundle_auto_md =
        _get_auto_metadata_from_bundle(format!("{bundle_path}/automatic_metadata.json"));

    if let std::result::Result::Ok(bundle_auto_md) = bundle_auto_md {
        // For each missing MD of metadata.json use the best estimate from the providers
        manual_bundle_md.books.iter_mut().for_each(|book| {
            let auto_mds = bundle_auto_md.get(&book.isbn);

            replace_with_longest_string_if_none_or_empty(
                auto_mds,
                |auto| &auto.title,
                &mut book.title,
            );
            replace_with_longest_string_if_none_or_empty(
                auto_mds,
                |auto| &auto.blurb,
                &mut book.blurb,
            );

            // Take the authors from the provider which has the most authors
            if book.authors.is_empty() {
                let longest_authors = &auto_mds.and_then(|auto_mds| {
                    auto_mds
                        .values()
                        .filter_map(|auto_md| Some(&auto_md.as_ref()?.authors))
                        .max_by(|authors1, authors2| authors1.len().cmp(&authors2.len()))
                });
                book.authors = longest_authors.unwrap_or(&vec![]).to_vec();
            }

            // Merge the keyword from all providers
            if book.keywords.is_empty() {
                book.keywords = auto_mds.map_or(vec![], |auto_md| {
                    let res: Vec<String> = auto_md
                        .values()
                        .filter_map(|auto_md| auto_md.as_ref())
                        .map(|md| &md.keywords)
                        .fold(vec![], |mut kwa, kwb| {
                            kwa.extend(kwb.clone());
                            kwa
                        });
                    res
                });
            }

            if book.price_cent.is_none() {
                book.price_cent = auto_mds.and_then(|auto_md| {
                    auto_md
                        .values()
                        .filter_map(|auto_md| auto_md.as_ref())
                        // get minimum price of each provider in cents
                        .filter_map(|md| {
                            md.market_price
                                .iter()
                                .map(|price_euro| (price_euro * 100.0).round() as i32)
                                .min()
                        })
                        .min()
                });
            }
        });
    }

    return Ok(manual_bundle_md);
}

fn replace_with_longest_string_if_none_or_empty<F1>(
    auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
    auto_string_getter: F1,
    book_md_string: &mut Option<String>,
) where
    F1: Fn(&common::BookMetaDataFromProvider) -> &Option<String>,
{
    fn is_none_or_empty(s: &Option<String>) -> bool {
        match s {
            None => true,
            Some(s) => s.is_empty(),
        }
    }
    fn get_longest_str<F1>(
        auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
        string_getter: F1,
    ) -> Option<String>
        where
            F1: Fn(&common::BookMetaDataFromProvider) -> &Option<String>,
    {
        auto_mds?
            .values()
            .filter_map(|auto| string_getter(auto.as_ref()?).as_ref())
            // Find the longest string. In case of tie, use the smallest by lexicographical order
            .max_by(|a, b| a.len().cmp(&b.len()).then_with(|| b.cmp(&a)))
            .map(|s| (*s).to_owned())
    }

    if is_none_or_empty(book_md_string) {
        *book_md_string = get_longest_str(auto_mds, auto_string_getter);
    }
}

fn gen_client(cache_dir: &str) -> Box<dyn Client> {
    Box::new(crate::client::cached_http_client::CachedHttpClient {
        http_client: reqwest::blocking::Client::builder().build().unwrap(),
        cache_dir: cache_dir.to_owned(),
    })
}

fn gen_provider(provider: ProviderEnum) -> Box<dyn common::Provider> {
    match provider {
        ProviderEnum::Babelio => Box::new(babelio::Babelio {
            client: gen_client("babelio"),
        }),
        ProviderEnum::AbeBooks => Box::new(abebooks::AbeBooks {
            client: gen_client("abebooks"),
        }),
        ProviderEnum::GoogleBooks => Box::new(google_books::GoogleBooks {
            client: gen_client("google_books"),
        }),
        ProviderEnum::BooksPrice => Box::new(booksprice::BooksPrice {}),
        ProviderEnum::LesLibraires => Box::new(leslibraires::LesLibraires {
            client: gen_client("leslibraires"),
        }),
        ProviderEnum::JustBooks => Box::new(justbooks::JustBooks {
            client: gen_client("justbooks"),
        }),
    }
}

pub fn get_metadata_from_provider(
    provider: ProviderEnum,
    isbn: String,
) -> Option<common::BookMetaDataFromProvider> {
    gen_provider(provider).get_book_metadata_from_isbn(&isbn)
}
