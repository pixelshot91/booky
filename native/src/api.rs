use std::collections::HashMap;
use std::fs::File;
use std::io::{Read, Write};

use crate::cached_client::CachedClient;
use crate::common;
use crate::common::Ad;
use crate::common::{LbcCredential, Provider};
use crate::publisher::Publisher;
use crate::{abebooks, babelio, booksprice, google_books, leboncoin, leslibraires};
use itertools::Itertools;
use serde::{Deserialize, Serialize};
use serde_json::json;
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

#[derive(EnumIter, PartialEq, Eq, Hash, Debug, Deserialize, Serialize, Copy, Clone)]
pub enum ProviderEnum {
    Babelio,
    GoogleBooks,
    BooksPrice,
    AbeBooks,
    LesLibraires,
}

#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct Point {
    x: u16,
    y: u16,
}
#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct BarcodeDetectResult {
    value: String,
    corners: Vec<Point>,
}

#[derive(PartialEq, Debug, Deserialize, Serialize)]
pub struct BarcodeDetectResults {
    results: Vec<BarcodeDetectResult>,
}

pub fn detect_barcode_in_image(img_path: String) -> anyhow::Result<BarcodeDetectResults> {
    let output = std::process::Command::new("./detect_barcode")
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
    println!("stdout: {:?}", &std::str::from_utf8(&output.stdout));

    let r: Vec<BarcodeDetectResult> =
        serde_json::from_str(&std::str::from_utf8(&output.stdout).unwrap()).unwrap();
    Ok(BarcodeDetectResults { results: r })
}

#[cfg(test)]
mod tests {
    use super::{BarcodeDetectResult, BarcodeDetectResults, Point};
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
}

pub fn get_metadata_from_isbns(isbns: Vec<String>, path: String) -> Result<(), anyhow::Error> {
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

    let tmp_path = "tmp.txt";
    let mut file = File::create(tmp_path)?;
    file.write_all(
        serde_json::to_string(&hashmap)
            .expect("Unable to serialize data")
            .as_bytes(),
    )?;
    // Writing to the phone does not work
    // Instead a temporary file is created and immediatly move with 'gio move'
    std::process::Command::new("gio")
        .args(["move", tmp_path, &path])
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

pub fn get_auto_metadata_from_bundle(path: String) -> Result<Vec<ISBNMetadataPair>, anyhow::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();

    let raw_map: HashMap<String, HashMap<ProviderEnum, Option<common::BookMetaDataFromProvider>>> =
        serde_json::from_str(&contents).unwrap();

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

pub fn get_metadata_from_provider(
    provider: ProviderEnum,
    isbn: String,
) -> Option<common::BookMetaDataFromProvider> {
    match provider {
        ProviderEnum::Babelio => babelio::Babelio {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::GoogleBooks => google_books::GoogleBooks {
            client: Box::new(CachedClient {
                http_client: reqwest::blocking::Client::builder().build().unwrap(),
            }),
        }
        .get_book_metadata_from_isbn(&isbn),
        ProviderEnum::BooksPrice => booksprice::BooksPrice {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::AbeBooks => abebooks::AbeBooks {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::LesLibraires => {
            leslibraires::LesLibraires {}.get_book_metadata_from_isbn(&isbn)
        }
    }
}

pub fn publish_ad(ad: Ad, credential: LbcCredential) -> bool {
    let lbc_publisher = leboncoin::Leboncoin {};
    Publisher::publish(&lbc_publisher, ad, credential)
}
