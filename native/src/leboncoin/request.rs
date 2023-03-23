use std::path::Path;

use reqwest;
use serde::{Deserialize, Serialize};

use crate::{common::LbcCredential, leboncoin::personal_info};

use super::Image;

pub fn send(ad: crate::common::Ad, images: Vec<Image>, credential: &LbcCredential) -> String {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("authority", "api.leboncoin.fr".parse().unwrap());
    headers.insert("accept", "*/*".parse().unwrap());
    headers.insert(
        "accept-language",
        "en-US,en;q=0.9,fr;q=0.8".parse().unwrap(),
    );
    headers.insert(
        "authorization",
        ["Bearer ", &credential.lbc_token].concat().parse().unwrap(),
    );
    headers.insert("cache-control", "no-cache".parse().unwrap());
    headers.insert("content-type", "application/json".parse().unwrap());
    headers.insert("origin", "https://www.leboncoin.fr".parse().unwrap());
    headers.insert("pragma", "no-cache".parse().unwrap());
    headers.insert(
        "referer",
        "https://www.leboncoin.fr/deposer-une-annonce"
            .parse()
            .unwrap(),
    );
    headers.insert(
        "sec-ch-ua",
        "\"Not?A_Brand\";v=\"8\", \"Chromium\";v=\"108\""
            .parse()
            .unwrap(),
    );
    headers.insert("sec-ch-ua-mobile", "?0".parse().unwrap());
    headers.insert("sec-ch-ua-platform", "\"Linux\"".parse().unwrap());
    headers.insert("sec-fetch-dest", "empty".parse().unwrap());
    headers.insert("sec-fetch-mode", "cors".parse().unwrap());
    headers.insert(
        reqwest::header::COOKIE,
        credential.datadome_cookie.parse().unwrap(),
    );
    headers.insert("sec-fetch-site", "same-site".parse().unwrap());
    headers.insert("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36".parse().unwrap());

    let client = reqwest::blocking::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .build()
        .unwrap();
    let body = SendStruct {
        subject: ad.title,
        body: ad.description,
        category_id: "27".to_string(),
        ad_type: "sell".to_string(),
        images,
        attributes: Attributes {
            title_adparams_prediction_id: "2a242efc-e50f-4c3c-9486-9c6ee59225dd".to_string(),
            item_condition: "3".to_string(),
            donation: "0".to_string(),
            price_reco: "2|13|10|90|64ca29e6-269d-4d89-b945-a0dcd5eaf992".to_string(),
            shipping_cost: "".to_string(),
        },
        extended_attributes: ExtendedAttributes {
            shipping: Shipping {
                version: 2,
                shipping_types: [
                    "mondial_relay",
                    "colissimo",
                    "face_to_face",
                    "courrier_suivi",
                ]
                .map(|s| s.to_string())
                .to_vec(),
                estimated_parcel_weight: 600,
            },
        },
        location: Location {
            address: "".to_string(),
            city: personal_info::CITY.to_string(),
            country: personal_info::COUNTRY.to_string(),
            district: "".to_string(),
            geo_provider: "here".to_string(),
            geo_source: "city".to_string(),
            label: personal_info::LABEL.to_string(),
            lat: personal_info::LAT,
            lng: personal_info::LNG,
            zipcode: personal_info::ZIPCODE.to_string(),
        },
        email: personal_info::EMAIL.to_string(),
        phone: personal_info::PHONE.to_string(),
        escrow_firstname: personal_info::ESCROW_FIRSTNAME.to_string(),
        escrow_lastname: personal_info::ESCROW_LASTNAME.to_string(),
        price_cents: ad.price_cent.to_string(),
        price: (ad.price_cent / 100).to_string(),
        no_salesmen: true,
    };

    let res = client
        .post("https://api.leboncoin.fr/api/adsubmit/v2/classifieds?with_variation=true")
        .headers(headers)
        .body(serde_json::to_string(&body).unwrap())
        .send()
        .unwrap()
        .text()
        .unwrap();

    println!("request send : {:#?}", res);
    res
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SendStruct {
    pub subject: String,
    pub body: String,
    #[serde(rename = "category_id")]
    pub category_id: String,
    #[serde(rename = "ad_type")]
    pub ad_type: String,
    pub images: Vec<Image>,
    pub attributes: Attributes,
    #[serde(rename = "extended_attributes")]
    pub extended_attributes: ExtendedAttributes,
    pub location: Location,
    pub email: String,
    pub phone: String,
    pub escrow_firstname: String,
    pub escrow_lastname: String,
    #[serde(rename = "price_cents")]
    pub price_cents: String,
    pub price: String,
    #[serde(rename = "no_salesmen")]
    pub no_salesmen: bool,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Attributes {
    #[serde(rename = "title_adparams_prediction_id")]
    pub title_adparams_prediction_id: String,
    #[serde(rename = "item_condition")]
    pub item_condition: String,
    pub donation: String,
    #[serde(rename = "price_reco")]
    pub price_reco: String,
    #[serde(rename = "shipping_cost")]
    pub shipping_cost: String,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ExtendedAttributes {
    pub shipping: Shipping,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Shipping {
    pub version: i64,
    #[serde(rename = "shipping_types")]
    pub shipping_types: Vec<String>,
    #[serde(rename = "estimated_parcel_weight")]
    pub estimated_parcel_weight: i64,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Location {
    pub address: String,
    pub city: String,
    pub country: String,
    pub district: String,
    #[serde(rename = "geo_provider")]
    pub geo_provider: String,
    #[serde(rename = "geo_source")]
    pub geo_source: String,
    pub label: String,
    pub lat: f64,
    pub lng: f64,
    pub zipcode: String,
}

pub fn submit(ad_id: i64, credential: LbcCredential) -> Result<String, Box<dyn std::error::Error>> {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("authority", "api.leboncoin.fr".parse().unwrap());
    headers.insert("accept", "*/*".parse().unwrap());
    headers.insert(
        "accept-language",
        "en-US,en;q=0.9,fr;q=0.8".parse().unwrap(),
    );
    headers.insert(
        "authorization",
        ["Bearer ", &credential.lbc_token].concat().parse().unwrap(),
    );
    headers.insert("cache-control", "no-cache".parse().unwrap());
    headers.insert("content-type", "application/json".parse().unwrap());
    headers.insert("origin", "https://www.leboncoin.fr".parse().unwrap());
    headers.insert("pragma", "no-cache".parse().unwrap());
    headers.insert(
        "referer",
        "https://www.leboncoin.fr/deposer-une-annonce/options"
            .parse()
            .unwrap(),
    );
    headers.insert(
        "sec-ch-ua",
        "\"Not?A_Brand\";v=\"8\", \"Chromium\";v=\"108\""
            .parse()
            .unwrap(),
    );
    headers.insert("sec-ch-ua-mobile", "?0".parse().unwrap());
    headers.insert("sec-ch-ua-platform", "\"Linux\"".parse().unwrap());
    headers.insert("sec-fetch-dest", "empty".parse().unwrap());
    headers.insert("sec-fetch-mode", "cors".parse().unwrap());
    headers.insert(
        reqwest::header::COOKIE,
        credential.datadome_cookie.parse().unwrap(),
    );
    headers.insert("sec-fetch-site", "same-site".parse().unwrap());
    headers.insert("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36".parse().unwrap());

    let client = reqwest::blocking::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .build()
        .unwrap();
    let body = SubmitBody {
        ads: vec![SubmitAd {
            ad_type: "sell".to_string(),
            ad_id,
            options: vec![],
            action_id: 1,
            transaction_type: "new_ad".to_string(),
        }],
        pricing_id: "87275b3e0eae7a906b6ef915156f8295".to_string(),
        user_journey: "deposit".to_string(),
    };
    let res = client
        .post("https://api.leboncoin.fr/api/services/v1/submit")
        .headers(headers)
        .body(serde_json::to_string(&body).unwrap())
        .send()?
        .text()?;
    println!("request submit : {}", res);

    Ok(res)
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SubmitBody {
    pub ads: Vec<SubmitAd>,
    #[serde(rename = "pricing_id")]
    pub pricing_id: String,
    #[serde(rename = "user_journey")]
    pub user_journey: String,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SubmitAd {
    #[serde(rename = "ad_type")]
    pub ad_type: String,
    #[serde(rename = "ad_id")]
    pub ad_id: i64,
    pub options: Vec<String>,
    #[serde(rename = "action_id")]
    pub action_id: i64,
    #[serde(rename = "transaction_type")]
    pub transaction_type: String,
}

pub fn upload_file(img_path: &Path, credential: &LbcCredential) -> String {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert(
        "authorization",
        ["Bearer ", &credential.lbc_token].concat().parse().unwrap(),
    );
    headers.insert(
        "sec-ch-ua",
        "\"Not?A_Brand\";v=\"8\", \"Chromium\";v=\"108\""
            .parse()
            .unwrap(),
    );
    headers.insert("sec-ch-ua-mobile", "?0".parse().unwrap());
    headers.insert("sec-ch-ua-platform", "\"Linux\"".parse().unwrap());
    headers.insert("sec-fetch-dest", "empty".parse().unwrap());
    headers.insert("sec-fetch-mode", "cors".parse().unwrap());
    headers.insert(
        reqwest::header::COOKIE,
        credential.datadome_cookie.parse().unwrap(),
    );
    headers.insert("sec-fetch-site", "same-site".parse().unwrap());
    headers.insert("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36".parse().unwrap());

    let form = reqwest::blocking::multipart::Form::new()
        .file("file", img_path)
        .expect(&format!("Could not find file at path: {:?}", img_path));

    let client = reqwest::blocking::Client::new();
    let res = client
        .post("https://api.leboncoin.fr/api/pintad/v1/public/upload/image")
        .headers(headers)
        .multipart(form)
        .send()
        .unwrap()
        .text()
        .unwrap();
    println!("upload_file response = {}", res);
    res
}
