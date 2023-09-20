use anyhow::Result;
use itertools::Itertools;
use native;
use serde::{Deserialize, Serialize};
use std::io::Read;
use std::{env, fs::File};

#[derive(Debug, Serialize, Deserialize)]
enum OldItemState {
    #[serde(rename = "brandNew")]
    BrandNew,

    #[serde(rename = "veryGood")]
    VeryGood,

    #[serde(rename = "good")]
    Good,
    #[serde(rename = "medium")]
    Medium,
}

#[derive(Debug, Serialize, Deserialize)]
struct OldMetadata {
    #[serde(rename = "weightGrams")]
    weight_grams: Option<i32>,
    #[serde(rename = "itemState")]
    item_state: Option<OldItemState>,
    isbns: Vec<String>,
}

fn convert_item_state(old: OldItemState) -> native::api::ItemState {
    match old {
        OldItemState::BrandNew => native::api::ItemState::BrandNew,
        OldItemState::VeryGood => native::api::ItemState::VeryGood,
        OldItemState::Good => native::api::ItemState::Good,
        OldItemState::Medium => native::api::ItemState::Medium,
    }
}

fn convert_metadata(bundle_path: &str) -> Result<()> {
    // println!("bundle_path = {}", bundle_path);
    let mut contents = String::new();
    {
        let mut file = File::open(format!("{bundle_path}/metadata.json"))?;
        file.read_to_string(&mut contents).unwrap();
    }
    let old_md: OldMetadata = serde_json::from_str(&contents)?;

    let new_md = native::api::BundleMetaData {
        weight_grams: old_md.weight_grams,
        item_state: old_md.item_state.map(convert_item_state),
        books: old_md
            .isbns
            .iter()
            .map(|isbn| native::api::BookMetaData {
                isbn: isbn.to_owned(),
                ..Default::default()
            })
            .collect_vec(),
    };
    let new_md_str = serde_json::to_string(&new_md).unwrap();
    println!("new = {}", new_md_str);
    std::fs::write(format!("{bundle_path}/metadata.json"), new_md_str)?;
    Ok(())
}

fn main() -> Result<()> {
    let bundle_dirs: Vec<String> = env::args().skip(1).collect();
    println!("begin");

    for bundle_path in bundle_dirs {
        match convert_metadata(&bundle_path) {
            Ok(()) => println!("OK {}", bundle_path),
            Err(e) => println!("ERR {}. e = {}", bundle_path, e),
        };
    }
    Ok(())

    // New
}
