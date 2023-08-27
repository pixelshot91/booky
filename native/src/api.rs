use std::collections::HashMap;
use std::fs::File;
use std::io::{Read, Write};
use std::path::Path;

use crate::client::Client;
use crate::common;
use crate::{abebooks, babelio, booksprice, google_books, justbooks, leslibraires};
use itertools::Itertools;
use serde::{Deserialize, Serialize};
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

use anyhow::Result;

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

pub fn get_auto_metadata_from_bundle(path: String) -> Result<Vec<ISBNMetadataPair>> {
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
