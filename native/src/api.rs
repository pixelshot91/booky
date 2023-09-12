use std::collections::HashMap;
use std::fs::File;
use std::io::{Read, Write};
use std::path::Path;
use std::vec;

use crate::client::Client;
use crate::common::{self, BookMetaDataFromProvider};
use crate::{abebooks, babelio, booksprice, google_books, justbooks, leslibraires};
use flutter_rust_bridge::frb;
use itertools::Itertools;
use serde::{Deserialize, Serialize};
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

use anyhow::{Ok, Result};

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
    use super::{BarcodeDetectResult, BarcodeDetectResults, Point};
    use crate::api::get_merged_metadata_for_bundle;

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
                        Point { x: 3246, y: 1909 }
                    ]
                }]
            }
        )
    }

    #[test]
    fn test_get_merged_metadata_for_bundle() {
        let merged = get_merged_metadata_for_bundle("/home/julien/Perso/LeBonCoin/chain_automatisation/saved_folder/after_migration/to_publish/2023-07-16T18_05_24.212557".to_owned());
        println!("{:?}", merged);
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

    //  Make sure the filename is unique so the function is thread-safe
    let tmp_path = Path::new(&path).file_name().unwrap();
    let mut file = File::create(tmp_path)?;
    file.write_all(
        serde_json::to_string(&hashmap)
            .expect("Unable to serialize data")
            .as_bytes(),
    )?;
    // Writing to the phone does not work
    // Instead a temporary file is created and immediately move with 'gio move'
    std::process::Command::new("gio")
        .args(["move", tmp_path.to_str().unwrap(), &path])
        .output()?;
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
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;

    let raw_map: HashMap<String, HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>> =
        serde_json::from_str(&contents)?;
    Ok(raw_map)
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
    pub authors: Vec<common::Author>,
    // A book blurb is a short promotional description.
    // A synopsis summarizes the twists, turns, and conclusion of the story.
    #[frb(non_final)]
    pub blurb: Option<String>,
    #[frb(non_final)]
    pub keywords: Vec<String>,
    #[frb(non_final)]
    pub price_cent: Option<i32>,
}

const METADATA_FILE_NAME: &str = "metadata.json";

pub fn get_manual_metadata_for_bundle(bundle_path: String) -> Result<BundleMetaData> {
    // get from metadata.json
    let mut file = File::open(format!("{bundle_path}/{METADATA_FILE_NAME}"))?;
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();

    let manual_bundle_md: BundleMetaData = serde_json::from_str(&contents).unwrap();
    return Ok(manual_bundle_md);
}

pub fn set_merged_metadata_for_bundle(
    bundle_path: String,
    bundle_metadata: BundleMetaData,
) -> Result<()> {
    let file_path = format!("{bundle_path}/{METADATA_FILE_NAME}");
    let contents = serde_json::to_string(&bundle_metadata).unwrap();
    std::fs::write(file_path, contents)?;
    Ok(())
}

// Retrieve a summary of all the information of a bundle
// If a book metadata is not available, try to use a metadata from a Provider
pub fn get_merged_metadata_for_bundle(bundle_path: String) -> Result<BundleMetaData> {
    // get from metadata.json
    let mut file = File::open(format!("{bundle_path}/{METADATA_FILE_NAME}"))?;
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();

    let mut manual_bundle_md: BundleMetaData = serde_json::from_str(&contents).unwrap();

    // Get MD from Provider
    let bundle_auto_md =
        _get_auto_metadata_from_bundle(format!("{bundle_path}/automatic_metadata.json"))?;
    manual_bundle_md.books.iter_mut().for_each(|book| {
        let auto_mds = bundle_auto_md.get(&book.isbn);
        /* auto_mds.map(|auto_mds| {
            let r = auto_mds
                .values()
                .into_iter()
                .filter_map(|s| s.as_ref())
                .reduce(|a, b| {
                    let t1 = a.title;
                    let t2 = b.title;
                    BookMetaDataFromProvider{

                    }
                });
            /* .reduce(|best, auto_md| {

            }); */
        }); */

        replace_with_longest_string_if_none_or_empty(auto_mds, |auto| &auto.title, &mut book.title);
        replace_with_longest_string_if_none_or_empty(auto_mds, |auto| &auto.blurb, &mut book.blurb);
        // replace_with_longest_vec_if_none_or_empty(auto_mds, |auto| &auto.authors,&mut book.authors);

        if book.authors.is_empty() {
            /* fn longest_vec(
                auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
            ) -> &Option<&Vec<common::Author>> {
                &auto_mds.and_then(|auto_mds| {
                    auto_mds
                    .values()
                    .filter_map(|auto_md| {

                        let vec = &auto_md.as_ref()?.authors;
                        Some(vec)
                    })
                    .max_by(|authors1, authors2| authors1.len().cmp(&authors2.len())) 
                }) //.unwrap_or(&vec![])
                /* match auto_mds {
                    None => vec![],
                    Some(auto_mds) => {
                        let a = auto_mds
                            .values()
                            .filter_map(|auto_md| Some(auto_md.as_ref()?.authors))
                            .max_by(|authors1, authors2| authors1.len().cmp(&authors2.len()));
                        vec![]
                    }
                } */
            }
            book.authors = longest_vec(auto_mds).unwrap_or(&vec![]).to_vec();
            */
            let longest_authors = &auto_mds.and_then(|auto_mds| {
                auto_mds
                .values()
                .filter_map(|auto_md| {

                    let vec = &auto_md.as_ref()?.authors;
                    Some(vec)
                })
                .max_by(|authors1, authors2| authors1.len().cmp(&authors2.len())) 
            });
            book.authors = longest_authors.unwrap_or(&vec![]).to_vec();
        }

        if book.keywords.is_empty() {
            book.keywords = auto_mds.map_or(vec![], |auto_md| {
                let a = auto_md
                    .values()
                    .filter_map(|auto_md| auto_md.as_ref())
                    .map(|md| &md.keywords);
                let res: Vec<String> = a.fold(vec![], |mut kwa, kwb| {
                    kwa.extend(kwb.clone());
                    kwa
                });
                res
            });
        }
    });

    // TODO: For each missing MD of metadata.json use the best estimate from the providers

    return Ok(manual_bundle_md);
}

fn replace_with_longest_string_if_none_or_empty<F1>(
    auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
    auto_string_getter: F1,
    book_md_string: &mut Option<String>,
) where
    F1: Fn(&common::BookMetaDataFromProvider) -> &Option<String>,
{
    replace_with_longest_x_if_none_or_empty(auto_mds, auto_string_getter, book_md_string, |s| {
        s.len()
    })
}

/* fn replace_with_longest_vec_if_none_or_empty<F1, T>(
    auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
    auto_string_getter: F1,
    book_md_string: &mut Vec<T>,
) where
    F1: Fn(&common::BookMetaDataFromProvider) -> &Vec<T>,
{
    replace_with_longest_x_if_none_or_empty(auto_mds, auto_string_getter, book_md_string, |s| {
        s.len()
    });
} */

fn replace_with_longest_x_if_none_or_empty<F1, F3, T: Clone>(
    auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
    auto_string_getter: F1,
    book_md_string: &mut Option<T>,
    to_len: F3,
) where
    F1: Fn(&common::BookMetaDataFromProvider) -> &Option<T>,
    F3: Fn(&T) -> usize,
{
    fn is_none_or_empty<F, T>(s: &Option<T>, to_len: F) -> bool
    where
        F: Fn(&T) -> usize,
    {
        match s {
            None => true,
            Some(s) => to_len(s) == 0,
        }
    }
    fn get_longest_x<F1, F2, T: Clone>(
        auto_mds: Option<&HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>>,
        string_getter: F1,
        to_len: F2,
    ) -> Option<T>
    where
        F1: Fn(&common::BookMetaDataFromProvider) -> &Option<T>,
        F2: Fn(&T) -> usize,
    {
        auto_mds?
            .values()
            .filter_map(|auto| string_getter(auto.as_ref()?).as_ref())
            .max_by(|a, b| to_len(a).cmp(&to_len(b)))
            .map(|s| (*s).to_owned())
    }

    if is_none_or_empty(book_md_string, &to_len) {
        *book_md_string = get_longest_x(auto_mds, auto_string_getter, to_len);
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
