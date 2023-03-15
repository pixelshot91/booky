use crate::babelio::Babelio;
use crate::common::Provider;
use crate::common::{Ad, BookMetaData};
use crate::google_books::GoogleBooks;
use crate::publisher::Publisher;
use crate::{babelio, common, google_books, leboncoin};
use itertools::Itertools;
use std::process::Command;

pub enum ProviderEnum {
    Babelio,
    GoogleBooks,
}

pub fn get_metadata_from_provider(provider: ProviderEnum, isbn: String) -> Option<BookMetaData> {
    match provider {
        ProviderEnum::Babelio => babelio::Babelio {}.get_book_metadata_from_isbn(&isbn),
        ProviderEnum::GoogleBooks => {
            google_books::GoogleBooks {}.get_book_metadata_from_isbn(&isbn)
        }
    }
}

/*
pub fn get_metadata_from_images(imgs_path: Vec<String>) -> Ad {
    let isbns: Vec<String> = imgs_path
        .clone()
        .into_iter()
        .map(|picture_path| {
            println!("{picture_path}");
            let output = Command::new(
                "/home/julien/Perso/LeBonCoin/chain_automatisation/book_metadata_finder/detect_barcode",
            )
                .arg("-in=".to_string() + &picture_path)
                .output()
                .expect("failed to execute process");
            if !output.status.success() {
                println!("stdout is {:?}", std::str::from_utf8(&output.stdout).unwrap());
                println!("stderr is {:?}", std::str::from_utf8(&output.stderr).unwrap());
                panic!("output.status is {}", output.status)
            }
            let output = std::str::from_utf8(&output.stdout).unwrap();
            println!("output is {:?}", output);
            output
                .split_ascii_whitespace()
                .map(|x| x.to_string())
                .collect_vec()
        })
        .flatten()
        .unique()
        .collect();

    println!("isbns {:?}", isbns);

    let book_metadata_providers: Vec<Box<dyn common::Provider>> = vec![
        Box::new(babelio::Babelio {}),
        Box::new(google_books::GoogleBooks {}),
    ];

    let books: Vec<Option<common::BookMetaData>> = isbns
        .iter()
        .map(|isbn| {
            for provider in &book_metadata_providers {
                let res = provider.get_book_metadata_from_isbn(&isbn);
                if let Some(r) = res {
                    return Some(r);
                }
            }
            None
        })
        .collect();
    let books_titles = books.iter().map(book_format_title_and_author).join("\n");
    let blurbs = books
        .iter().filter(|b| b.blurb.is_some())
        .map(|b| {
            format!(
                "{}:\n{}\n",
                book_format_title_and_author(b),
                b.blurb.as_ref().unwrap()
            )
        })
        .join("\n");
    let keywords = books.iter().flat_map(|b| &b.keywords).unique().join(", ");

    let custom_message = leboncoin::personal_info::CUSTOM_MESSAGE;

    let mut ad_description = books_titles;
    if !blurbs.is_empty() {
        ad_description += &("\n\nRésumé:\n".to_owned() + &blurbs);
    }
    ad_description += &("\n\n".to_owned() + &custom_message);
    if !keywords.is_empty() {
        ad_description = ad_description + "\n\nMots-clés:\n" + &keywords;
    }

    println!("ad_description: {:#?}", ad_description);
    println!("ad_description: {}", ad_description);

    common::Ad {
        title: if books.len() == 1 {
            books.first().unwrap().title.clone()
        } else {
            "".to_string()
        },
        description: ad_description,
        price_cent: 1000,
        imgs_path,
    }
}*/

pub fn publish_ad(ad: Ad) -> () {
    let lbc_publisher = leboncoin::Leboncoin {};
    Publisher::publish(&lbc_publisher, ad);
}
/*
fn book_format_title_and_author(book: &BookMetaData) -> String {
    format!(
        "\"{}\" {}",
        book.title,
        vec_fmt(
            book.authors
                .iter()
                .map(|a| format!("{} {}", a.first_name, a.last_name))
                .collect_vec()
        )
    )
}

fn vec_fmt(vec: Vec<String>) -> String {
    match vec.len() {
        0 => "".to_string(),
        1 => format!("de {}", vec[0]),
        2 => format!("de {} et {}", vec[0], vec[1]),
        _ => panic!("More than 2 authors"),
    }
}
*/
