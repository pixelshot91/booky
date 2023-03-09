use std::path::Path;

use reqwest;
use serde::{Deserialize, Serialize};

use crate::leboncoin::personal_info;

use super::Image;

pub fn send(ad: crate::common::Ad, images: Vec<Image>) -> String {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("authority", "api.leboncoin.fr".parse().unwrap());
    headers.insert("accept", "*/*".parse().unwrap());
    headers.insert(
        "accept-language",
        "en-US,en;q=0.9,fr;q=0.8".parse().unwrap(),
    );
    headers.insert(
        "authorization",
        ["Bearer ", personal_info::LBC_TOKEN]
            .concat()
            .parse()
            .unwrap(),
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
        personal_info::DATA_DOME_COOKIE.parse().unwrap(),
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

pub fn submit(ad_id: i64) -> Result<String, Box<dyn std::error::Error>> {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("authority", "api.leboncoin.fr".parse().unwrap());
    headers.insert("accept", "*/*".parse().unwrap());
    headers.insert(
        "accept-language",
        "en-US,en;q=0.9,fr;q=0.8".parse().unwrap(),
    );
    headers.insert(
        "authorization",
        ["Bearer ", personal_info::LBC_TOKEN]
            .concat()
            .parse()
            .unwrap(),
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
        personal_info::DATA_DOME_COOKIE.parse().unwrap(),
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

pub fn upload_file(img_path: &Path) -> String {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert(
        "authorization",
        ["Bearer ", personal_info::LBC_TOKEN]
            .concat()
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
        personal_info::DATA_DOME_COOKIE.parse().unwrap(),
    );
    headers.insert("sec-fetch-site", "same-site".parse().unwrap());
    headers.insert("user-agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36".parse().unwrap());

    let form = reqwest::blocking::multipart::Form::new()
        .file("file", img_path)
        .unwrap();

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

//curl 'https://api.leboncoin.fr/api/pintad/v1/public/upload/image' -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0' -H 'Accept: */*' -H 'Accept-Language: fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: https://www.leboncoin.fr/annonce/2305203826/editer' -H 'api_key: ba0c2dad52b3ec' -H 'authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyYjFjNmYwLWRiM2EtNTQ2Ny1hYmI2LTJlMzAxNDViZjc3MiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRfaWQiOiJsYmMtZnJvbnQtd2ViIiwiZGVwcmVjYXRlZF9zdG9yZV9pZCI6NTU3OTE3NDQsImV4cCI6MTY3NzYxNTYxMiwiaWF0IjoxNjc3NjA4NDExLCJpZCI6IjliYzg5OWM1LTMxN2UtNDE1Ny1iMzEyLTAyMWQ1ZTQ3YTlkYSIsImluc3RhbGxfaWQiOiI3MDQ1YjhmMy0xMzYyLTRiN2UtYjhmZC1lY2Y0OWU4ODRjOGQiLCJqdGkiOiIyY2FhMzU5OS1jZDk3LTQxYTEtYmIzMC1hNmI2YjlmMDA1MzciLCJyZWZ1c2VkX3Njb3BlcyI6bnVsbCwicmVxdWVzdF9pZCI6ImVjMDZjZTM0LThhMzItNDkyNC05NDc1LTc4MzU4MmY3ZGI3YiIsInNjb3BlcyI6WyJsYmMucHJpdmF0ZSIsImxiY2dycC5hdXRoLnR3b2ZhY3Rvci5zbXMubWUuYWN0aXZhdGUiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRpc3BsYXkiLCJvZmZsaW5lIiwibGJjLmF1dGguZW1haWwucGFydC5jaGFuZ2UiLCJsYmMuZXNjcm93YWNjb3VudC5tYWludGVuYW5jZS5yZWFkIiwibGJjZ3JwLmF1dGgudHdvZmFjdG9yLm1lLioiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRlbGV0ZSIsImxiY2dycC5hdXRoLnNlc3Npb24ubWUucmVhZCIsImxiYy4qLm1lLioiLCJsYmMuKi4qLm1lLioiLCJiZXRhLmxiYy5hdXRoLnR3b2ZhY3Rvci5tZS4qIl0sInNlc3Npb25faWQiOiIyNGUyNDA2Mi0xNmE2LTQ4NWQtYjg0Yi1iNWY4MGViNjkzYTUiLCJzdWIiOiJsYmM7MTgzMGE2NGEtZjJjYy00Y2Q4LTg3ZjAtYzVkYjdmOTU2N2Q4OzU1NzkxNzQ0In0.GRqf3gDdFiq1ukFhN_2i8HhWycirauVUM7rDoZZHsSgD-wv5VOwuKDWc6axDoPK3Wsbg_oFXfrSHX-bcDkE2SRaOqNB734eqD-fbceCG1ntf-afgeLWf-MPnas0n_ylOB2ZSK1LAG2aCXZSDm3ZEkXs_-KZhwQtsmqLgIte0PJUUk_qP4tYYDqLe3FvUeGIkrPAFHKxfnAXmKXf-kh9RvbykGiek9lqFT-Hg95X21eS3Z8HH2li-OMP4B2I-PQysOLuaAZ47wkjkt8PKgC6qG3rlitr28MRbkBYrsuo5ic9JMEKTlmbYa5WsyzZJL5F5Y3CdKTXxiQ4ae2kY2hRLgubk2Dihy8vdqLhitX-Fm_sGQSFnP7vy7iHhQCK5m4jLnD-p-sD_DAehNkGYF8lQqG44myb7XdmTtY9uoR_1Tv2LXYSncKQzEpCn-G6Pf0DJg4xb02CCxXWqB7oysooBgFzgPGdixJeBnFSX_8H0zbmoszUUW7Wqw_aSKv7aAQ3p2Foha3U7B4B-3lHPetec6wEo1eLvq5XXRbDAZuvIqbG6cvQHS5HDNkiBQIHfED3VwVOnextu0BADL7hYl4bOM50yNquNIoecPbEOC0Tij3JdYdGjHJ_ywDhsGwD08awZLIpPsJ1ppcaxMv3thoMsiInKqX5wLHNmTec13Lyn978' -H 'Content-Type: multipart/form-data; boundary=---------------------------153785532732722146451504606153' -H 'Origin: https://www.leboncoin.fr' -H 'Connection: keep-alive' -H 'Cookie: datadome=Ysu9fziXa098YNozRd6iS4oq62CcYXd0SZUP9cw4Rl5NMfVROqQrM7eT96i618vhu3M4l~JZWv80IUWEBCzBJdRnqF2Z-W6M0oyZXXOyLvLbDiGsWPQcoQw_UU7qXS-; __Secure-Install=7045b8f3-1362-4b7e-b8fd-ecf49e884c8d; __Secure-InstanceId=7045b8f3-1362-4b7e-b8fd-ecf49e884c8d; utag_main=v_id:0186993fcaf6000e3c437fda305405046001900900bd0$_sn:1$_ss:0$_pn:5%3Bexp-session$_st:1677610707192$ses_id:1677608340214%3Bexp-session; didomi_token=eyJ1c2VyX2lkIjoiMTg2OTkzZmMtYjVmNi02ZTFiLWI2YWQtZDFmMjhmOTJiODk4IiwiY3JlYXRlZCI6IjIwMjMtMDItMjhUMTg6MTk6MDIuMzQyWiIsInVwZGF0ZWQiOiIyMDIzLTAyLTI4VDE4OjE5OjAyLjM0MloiLCJ2ZW5kb3JzIjp7ImVuYWJsZWQiOlsiZ29vZ2xlIiwiYzpsYmNmcmFuY2UiLCJjOnJldmxpZnRlci1jUnBNbnA1eCIsImM6ZGlkb21pIl19LCJwdXJwb3NlcyI6eyJlbmFibGVkIjpbImV4cGVyaWVuY2V1dGlsaXNhdGV1ciIsIm1lc3VyZWF1ZGllbmNlIiwicGVyc29ubmFsaXNhdGlvbm1hcmtldGluZyIsInByaXgiXX0sInZlbmRvcnNfbGkiOnsiZW5hYmxlZCI6WyJnb29nbGUiXX0sInZlcnNpb24iOjIsImFjIjoiRExXQkFBRUlBSXdBV1FCLWdHRkFQeUFra0JKWUVBd0lrZ1NrQXR5QnhBRHB3SFZnUU1BaW9CSE9DU2NFdFlLREFVSWdvdEJYT0N3VUZ0NExqQVhMQXdHQmhFREUwR1dvLkRMV0JBQUVJQUl3QVdRQi1nR0ZBUHlBa2tCSllFQXdJa2dTa0F0eUJ4QURwd0hWZ1FNQWlvQkhPQ1NjRXRZS0RBVUlnb3RCWE9Dd1VGdDRMakFYTEF3R0JoRURFMEdXbyJ9; euconsent-v2=CPn5KgAPn5KgAAHABBENC5CgAPLAAH7AAAAAIsNB_G_dTyPi-f59YvtwYQ1P4VQnoyACjgaNgwwJiRLBMI0EhmAIKAHqAAACIBAkICJAAQBlCAHAAAAA4IEAASMMAAAAIRAIIgCAAEAAAmJICABZCxAAAQAQgkwAABQAgAICABMgSDAAAAAAFAAAAAgAAAAAAAAAAAAAQAAAAAAAAgAAAAAAAAAAAAAEEAQATDVuIAGxLHAmkDCIAACMIAgCgBABRQBCwQAEBIgAEEYACjAAAAAFAAAAAAAAEAMAAAAAgAQgAAAAcEAgAIAEAAAAEAgEAAAAACAAADAAAAAAAMAAAAAAgAIAAAKAQAABAAgAJAgACAAAAgAAAAAAAAAgEAAAAAAAAAAAAAAAAQAxQAGAAIJQjAAMAAQShIAAYAAglCAA.flgAD9gAAAAA; include_in_experiment=true; _hjSessionUser_2783207=eyJpZCI6IjBlOTAwNGIzLWVmNmUtNWM5ZC1iNzQ4LTU4NjFlMWVmMmUyMSIsImNyZWF0ZWQiOjE2Nzc2MDgzNDM2NzksImV4aXN0aW5nIjp0cnVlfQ==; _hjFirstSeen=1; _hjIncludedInSessionSample_2783207=1; _hjSession_2783207=eyJpZCI6ImE1MjQxMjgxLWY5YzQtNDU5YS05NzNkLWFiODc4YjM4MzU2MyIsImNyZWF0ZWQiOjE2Nzc2MDgzNDM2ODEsImluU2FtcGxlIjp0cnVlfQ==; _hjAbsoluteSessionInProgress=0; ry_ry-l3b0nco_realytics=eyJpZCI6InJ5XzI5RjFCQTE5LUQ3ODYtNEUxQy05NUNDLTYwMjE4QUVEOUI3NyIsImNpZCI6bnVsbCwiZXhwIjoxNzA5MTQ0MzQ0Nzc3LCJjcyI6bnVsbH0%3D; ry_ry-l3b0nco_so_realytics=eyJpZCI6InJ5XzI5RjFCQTE5LUQ3ODYtNEUxQy05NUNDLTYwMjE4QUVEOUI3NyIsImNpZCI6bnVsbCwib3JpZ2luIjp0cnVlLCJyZWYiOm51bGwsImNvbnQiOm51bGwsIm5zIjpmYWxzZX0%3D; _gcl_au=1.1.701707994.1677608345; cto_bundle=CNZ-SV9JaWtsRlAyVjVqODhGWWhVYldZN3BzOFl6eG5hJTJCMTZibnQ2R2RNakRCS3N5WDdWWFVleHpzRCUyQmNtQUQwUmt0bW5CdldxZUFLem02b1clMkZTMDdTdXQ3emtxYUtISDJqUzZEazclMkZZMFlFTzQzS2dRaU5NZnVMc3JtR2NMTFBBcGNBZ2hINGczcm44TFpQSSUyRmF1YiUyQnJ3OXclM0QlM0Q; __gads=ID=f3fe3612fb4470d8:T=1677608347:S=ALNI_MbMwkuo3rfJtYKI9L6tyyLC8sIwbg; __gpi=UID=00000be0047e7d68:T=1677608347:RT=1677608347:S=ALNI_Mav2FKNNTDv7opgvCIg2Kld9HMpbw; luat=eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyYjFjNmYwLWRiM2EtNTQ2Ny1hYmI2LTJlMzAxNDViZjc3MiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRfaWQiOiJsYmMtZnJvbnQtd2ViIiwiZGVwcmVjYXRlZF9zdG9yZV9pZCI6NTU3OTE3NDQsImV4cCI6MTY3NzYxNTYxMiwiaWF0IjoxNjc3NjA4NDExLCJpZCI6IjliYzg5OWM1LTMxN2UtNDE1Ny1iMzEyLTAyMWQ1ZTQ3YTlkYSIsImluc3RhbGxfaWQiOiI3MDQ1YjhmMy0xMzYyLTRiN2UtYjhmZC1lY2Y0OWU4ODRjOGQiLCJqdGkiOiIyY2FhMzU5OS1jZDk3LTQxYTEtYmIzMC1hNmI2YjlmMDA1MzciLCJyZWZ1c2VkX3Njb3BlcyI6bnVsbCwicmVxdWVzdF9pZCI6ImVjMDZjZTM0LThhMzItNDkyNC05NDc1LTc4MzU4MmY3ZGI3YiIsInNjb3BlcyI6WyJsYmMucHJpdmF0ZSIsImxiY2dycC5hdXRoLnR3b2ZhY3Rvci5zbXMubWUuYWN0aXZhdGUiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRpc3BsYXkiLCJvZmZsaW5lIiwibGJjLmF1dGguZW1haWwucGFydC5jaGFuZ2UiLCJsYmMuZXNjcm93YWNjb3VudC5tYWludGVuYW5jZS5yZWFkIiwibGJjZ3JwLmF1dGgudHdvZmFjdG9yLm1lLioiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRlbGV0ZSIsImxiY2dycC5hdXRoLnNlc3Npb24ubWUucmVhZCIsImxiYy4qLm1lLioiLCJsYmMuKi4qLm1lLioiLCJiZXRhLmxiYy5hdXRoLnR3b2ZhY3Rvci5tZS4qIl0sInNlc3Npb25faWQiOiIyNGUyNDA2Mi0xNmE2LTQ4NWQtYjg0Yi1iNWY4MGViNjkzYTUiLCJzdWIiOiJsYmM7MTgzMGE2NGEtZjJjYy00Y2Q4LTg3ZjAtYzVkYjdmOTU2N2Q4OzU1NzkxNzQ0In0.GRqf3gDdFiq1ukFhN_2i8HhWycirauVUM7rDoZZHsSgD-wv5VOwuKDWc6axDoPK3Wsbg_oFXfrSHX-bcDkE2SRaOqNB734eqD-fbceCG1ntf-afgeLWf-MPnas0n_ylOB2ZSK1LAG2aCXZSDm3ZEkXs_-KZhwQtsmqLgIte0PJUUk_qP4tYYDqLe3FvUeGIkrPAFHKxfnAXmKXf-kh9RvbykGiek9lqFT-Hg95X21eS3Z8HH2li-OMP4B2I-PQysOLuaAZ47wkjkt8PKgC6qG3rlitr28MRbkBYrsuo5ic9JMEKTlmbYa5WsyzZJL5F5Y3CdKTXxiQ4ae2kY2hRLgubk2Dihy8vdqLhitX-Fm_sGQSFnP7vy7iHhQCK5m4jLnD-p-sD_DAehNkGYF8lQqG44myb7XdmTtY9uoR_1Tv2LXYSncKQzEpCn-G6Pf0DJg4xb02CCxXWqB7oysooBgFzgPGdixJeBnFSX_8H0zbmoszUUW7Wqw_aSKv7aAQ3p2Foha3U7B4B-3lHPetec6wEo1eLvq5XXRbDAZuvIqbG6cvQHS5HDNkiBQIHfED3VwVOnextu0BADL7hYl4bOM50yNquNIoecPbEOC0Tij3JdYdGjHJ_ywDhsGwD08awZLIpPsJ1ppcaxMv3thoMsiInKqX5wLHNmTec13Lyn978; _schn=_27faqp; _scid=d6571009-7472-41bb-9cb9-8510b51a6a95; _fbp=fb.1.1677608908547.2034999500' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'TE: trailers' --data-binary $'-----------------------------153785532732722146451504606153\r\nContent-Disposition: form-data; name="file"; filename="20230228_192237.jpg"\r\nContent-Type: image/jpeg\r\n\r\n-----------------------------153785532732722146451504606153--\r\n'

// curl 'https://api.leboncoin.fr/api/pintad/v1/public/upload/image' \
//  -H 'authority: api.leboncoin.fr' \

//  -H 'accept: */*' \
/*
-H 'accept-language: en-US,en;q=0.9,fr;q=0.8' \
-H 'api_key: ba0c2dad52b3ec' \
-H 'authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyYjFjNmYwLWRiM2EtNTQ2Ny1hYmI2LTJlMzAxNDViZjc3MiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRfaWQiOiJsYmMtZnJvbnQtd2ViIiwiZGVwcmVjYXRlZF9zdG9yZV9pZCI6NTU3OTE3NDQsImV4cCI6MTY3NzYxMTY1NywiaWF0IjoxNjc3NjA0NDU2LCJpZCI6IjQ1MTM1OTUxLTY0ZjQtNDFjZS05NGVjLWJkMzkzZDRjY2U2ZiIsImluc3RhbGxfaWQiOiIwNTA1NzA2YS05NDJhLTQzNjktYTdlYy02MGYxZDYxYWZiNjUiLCJqdGkiOiJlYmQzZDI2My1mMTMzLTQ3MjktYjVjOS1kNTA3ZmYwZjUxNDEiLCJyZWZ1c2VkX3Njb3BlcyI6bnVsbCwicmVxdWVzdF9pZCI6IjcwN2M3M2ZiLTk2NzQtNDZlNC05N2NmLTRkZTk2MzQ3NTYwZiIsInNjb3BlcyI6WyJsYmMucHJpdmF0ZSIsImxiY2dycC5hdXRoLnR3b2ZhY3Rvci5zbXMubWUuYWN0aXZhdGUiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRpc3BsYXkiLCJvZmZsaW5lIiwibGJjLmF1dGguZW1haWwucGFydC5jaGFuZ2UiLCJsYmMuZXNjcm93YWNjb3VudC5tYWludGVuYW5jZS5yZWFkIiwibGJjZ3JwLmF1dGgudHdvZmFjdG9yLm1lLioiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRlbGV0ZSIsImxiY2dycC5hdXRoLnNlc3Npb24ubWUucmVhZCIsImxiYy4qLm1lLioiLCJsYmMuKi4qLm1lLioiLCJiZXRhLmxiYy5hdXRoLnR3b2ZhY3Rvci5tZS4qIl0sInNlc3Npb25faWQiOiI3NGM1ZGY4Yy05MzQ3LTQ0MWQtYWViYi0zZWIzYjYyZTk1MjMiLCJzdWIiOiJsYmM7MTgzMGE2NGEtZjJjYy00Y2Q4LTg3ZjAtYzVkYjdmOTU2N2Q4OzU1NzkxNzQ0In0.dZMGwYAei7ovgsB6REy1XjtTjqbgVj4oXQomz7teIj-z0KEajW1pyLyBp4EweGpyb1McgSu8BOS74da9GEeNZ60x9pOAn9KiS8VNfqMBYiwknURnwI8NJdf9KiB6k__SzXb05uTyDeazLK76MoUIAImT8LwzMrFvdZewmmkqyYqT4o4Bcn0tynDkRLv5dSZ87n4ca0AsOsHt6zgWipwpqsGBom0ysYnOzq-hCkyM1-3SsjR4ohVT--qqR2EIijO2-SGk90kmwDzR9aYwCZzzRAlUTFhpE6-zHO7TquAV9oIQAU2Wmq5HgzhEREjUhJOI0fqXy9xk1dPRzb1A__rDbAm8Nkfxq-mF1JcaRM-nB2Pb1VgDV8j6P2MtPC8TlKyr9dMQFzuTWpvFa8sMYg92f3i1oLwvbgsHu5nweMqrWItDAwja7v35T3IReejBwKGOXXEmsTlJEcq589b2AdtZwH82mcFfwn6QkTPbJVGv7YiSLbyGNCQLbUJ-FhLptq2fLZwJUTEye72u-WzY5yeCxs8ZaIfaQHTduJrVviMlEfam9rnUUU-cUdA7NJx8bg63FqOYhEH-hFHYeo5gSF5EqA97jBwC2KoApADf4t1q5EhUPw7gGR9U7qQuhoRiTLVFV4kEjIWeX1QRntOHkVXfuoWTaTE-X1A6XsBvkcINJho' \
-H 'content-type: multipart/form-data; boundary=----WebKitFormBoundaryZ9zBRAquVv1qb78o' \
-H 'cookie: s=red1xa04ffeea4ed8b07c235277adc932a3e4d092859d; log_from=http%3A%2F%2Fwww2.leboncoin.fr%2Fdc%2Frules%3Fca%3D12_s; xtvrn=$266818$; ry_ry-l3b0nco_realytics=eyJpZCI6InJ5Xzg1M0VCQzVGLURCNjgtNDk1NC1COEE0LTM1OTY0RjhDN0U1RSIsImNpZCI6bnVsbCwiZXhwIjoxNjg0MzI0MDMzMDQ1LCJjcyI6bnVsbH0%3D; _pin_unauth=dWlkPU1HVXhPREF4TnpZdE1qTXhZUzAwTXpBd0xXSmpZVFF0TXpoallqRTNNamczTldVeg; _hjSessionUser_2783207=eyJpZCI6ImZjZTk5MmM1LTY0NmItNTViOS05OWY4LWRkYzc2YmE3ODc1YyIsImNyZWF0ZWQiOjE2NTI3ODgwMzQ1MjcsImV4aXN0aW5nIjp0cnVlfQ==; _scid=e7942114-373a-4d77-b41c-1717c1b77529; __Secure-Install=0505706a-942a-4369-a7ec-60f1d61afb65; __Secure-InstanceId=0505706a-942a-4369-a7ec-60f1d61afb65; didomi_token=eyJ1c2VyX2lkIjoiMTcyNmY1NWMtMjgwYS02Njc3LWFmMDAtZjk2YzM1MDM1NDQ3IiwiY3JlYXRlZCI6IjIwMjItMTItMDFUMTk6NTA6MDAuNzMwWiIsInVwZGF0ZWQiOiIyMDIyLTEyLTAxVDE5OjUwOjAwLjczMFoiLCJ2ZW5kb3JzIjp7ImVuYWJsZWQiOlsiZ29vZ2xlIiwiYzpsYmNmcmFuY2UiLCJjOnJldmxpZnRlci1jUnBNbnA1eCIsImM6ZGlkb21pIl19LCJwdXJwb3NlcyI6eyJlbmFibGVkIjpbInBlcnNvbm5hbGlzYXRpb25tYXJrZXRpbmciLCJwcml4IiwibWVzdXJlYXVkaWVuY2UiLCJleHBlcmllbmNldXRpbGlzYXRldXIiXX0sInZlbmRvcnNfbGkiOnsiZW5hYmxlZCI6WyJnb29nbGUiXX0sInZlcnNpb24iOjIsImFjIjoiRExXQkFBRUlBSXdBV1FCLWdHRkFQeUFra0JKWUVBd0lrZ1NrQXR5QnhBRHB3SFZnUU1BaW9CSE9DU2NFdFlLREFVSWdvdEJYT0N3VUZ0NExqQVhMQXdHQmhFREUwR1dvLkRMV0EtQUVJQUl3QV9RRENnSDVBU1NBa3NDQVlFU1FKU0FXNUE0Z0IwNERxd0lHQVJVQWpuQkpPQ1dzRkJnS0VRVVdncm5CWUtDMjhGeGdMbGdZREF3aUJpYURMVUFBQSJ9; euconsent-v2=CPjT1EAPjT1EAAHABBENCsCgAPLAAHLAAAAAIAtB_G_dTyPi-f59YvtwYQ1P4VQnoyACjgaNgwwJiRLBMI0EhmAIKAHqAAACIBAkICJAAQBlCAHAAAAA4IEAASMMAAAAIRAIIgCAAEAAAiJICABZCxAAAQAQgkwAABQAgAICABMgSDAAAAAAFAAAAAgAAAAAAAAAAAAAQAAAAAAAAggCACYatxAA2JY4E0gYRAAARhAEAUAIAKKAIWCAAgJEAAgjAAUYAAAAAoAAAAAAAAgBgAAAAEACEAAAADggEABAAgAAAAgEAgAAAAAQAAAYAAAAAABgAAAAAEABAAABQCAAAIAEABIEAAQAAAEAAAAAAAAAEAgAAAAAAAAAAAAAAACAGKAAwABBJYYABgACCSxAADAAEElg.flgADlgAAAAA; include_in_experiment=true; _gcl_au=1.1.396577628.1672180056; _fbp=fb.1.1674497618789.664585017; __gads=ID=3756ef2df471787f:T=1674498902:S=ALNI_MZYJfxMcpbJdw6KbbvraZ_khGHZnA; __gpi=UID=00000bc9e3cb6789:T=1674498902:RT=1674566983:S=ALNI_MbBn6iqQ8F-8Zpmb1WCKLM9NSFmxg; __gsas=ID=8ce0a4b086087df5:T=1674567077:S=ALNI_Mby9K0wXjz1NzkAZsVzbLFcccNtNw; adview_clickmeter=search__listing__4__8c78a2b2-4b20-497b-ae05-cf1e963b741d; luat=eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyYjFjNmYwLWRiM2EtNTQ2Ny1hYmI2LTJlMzAxNDViZjc3MiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRfaWQiOiJsYmMtZnJvbnQtd2ViIiwiZGVwcmVjYXRlZF9zdG9yZV9pZCI6NTU3OTE3NDQsImV4cCI6MTY3NzYxMTY1NywiaWF0IjoxNjc3NjA0NDU2LCJpZCI6IjQ1MTM1OTUxLTY0ZjQtNDFjZS05NGVjLWJkMzkzZDRjY2U2ZiIsImluc3RhbGxfaWQiOiIwNTA1NzA2YS05NDJhLTQzNjktYTdlYy02MGYxZDYxYWZiNjUiLCJqdGkiOiJlYmQzZDI2My1mMTMzLTQ3MjktYjVjOS1kNTA3ZmYwZjUxNDEiLCJyZWZ1c2VkX3Njb3BlcyI6bnVsbCwicmVxdWVzdF9pZCI6IjcwN2M3M2ZiLTk2NzQtNDZlNC05N2NmLTRkZTk2MzQ3NTYwZiIsInNjb3BlcyI6WyJsYmMucHJpdmF0ZSIsImxiY2dycC5hdXRoLnR3b2ZhY3Rvci5zbXMubWUuYWN0aXZhdGUiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRpc3BsYXkiLCJvZmZsaW5lIiwibGJjLmF1dGguZW1haWwucGFydC5jaGFuZ2UiLCJsYmMuZXNjcm93YWNjb3VudC5tYWludGVuYW5jZS5yZWFkIiwibGJjZ3JwLmF1dGgudHdvZmFjdG9yLm1lLioiLCJsYmNncnAuYXV0aC5zZXNzaW9uLm1lLmRlbGV0ZSIsImxiY2dycC5hdXRoLnNlc3Npb24ubWUucmVhZCIsImxiYy4qLm1lLioiLCJsYmMuKi4qLm1lLioiLCJiZXRhLmxiYy5hdXRoLnR3b2ZhY3Rvci5tZS4qIl0sInNlc3Npb25faWQiOiI3NGM1ZGY4Yy05MzQ3LTQ0MWQtYWViYi0zZWIzYjYyZTk1MjMiLCJzdWIiOiJsYmM7MTgzMGE2NGEtZjJjYy00Y2Q4LTg3ZjAtYzVkYjdmOTU2N2Q4OzU1NzkxNzQ0In0.dZMGwYAei7ovgsB6REy1XjtTjqbgVj4oXQomz7teIj-z0KEajW1pyLyBp4EweGpyb1McgSu8BOS74da9GEeNZ60x9pOAn9KiS8VNfqMBYiwknURnwI8NJdf9KiB6k__SzXb05uTyDeazLK76MoUIAImT8LwzMrFvdZewmmkqyYqT4o4Bcn0tynDkRLv5dSZ87n4ca0AsOsHt6zgWipwpqsGBom0ysYnOzq-hCkyM1-3SsjR4ohVT--qqR2EIijO2-SGk90kmwDzR9aYwCZzzRAlUTFhpE6-zHO7TquAV9oIQAU2Wmq5HgzhEREjUhJOI0fqXy9xk1dPRzb1A__rDbAm8Nkfxq-mF1JcaRM-nB2Pb1VgDV8j6P2MtPC8TlKyr9dMQFzuTWpvFa8sMYg92f3i1oLwvbgsHu5nweMqrWItDAwja7v35T3IReejBwKGOXXEmsTlJEcq589b2AdtZwH82mcFfwn6QkTPbJVGv7YiSLbyGNCQLbUJ-FhLptq2fLZwJUTEye72u-WzY5yeCxs8ZaIfaQHTduJrVviMlEfam9rnUUU-cUdA7NJx8bg63FqOYhEH-hFHYeo5gSF5EqA97jBwC2KoApADf4t1q5EhUPw7gGR9U7qQuhoRiTLVFV4kEjIWeX1QRntOHkVXfuoWTaTE-X1A6XsBvkcINJho; _hjSession_2783207=eyJpZCI6IjlmOWFiNjllLTk0MTctNDIwOS1iMTU0LWQwODM1OGU2MDVlZSIsImNyZWF0ZWQiOjE2Nzc2MDQ0NTc4NTgsImluU2FtcGxlIjp0cnVlfQ==; _hjAbsoluteSessionInProgress=0; ry_ry-l3b0nco_so_realytics=eyJpZCI6InJ5Xzg1M0VCQzVGLURCNjgtNDk1NC1COEE0LTM1OTY0RjhDN0U1RSIsImNpZCI6bnVsbCwib3JpZ2luIjpmYWxzZSwicmVmIjpudWxsLCJjb250IjpudWxsLCJucyI6ZmFsc2V9; _hjIncludedInSessionSample_2783207=1; cto_bundle=XggTMV9lYzVPa0lSRm5hMGZrMzB1ciUyRkhyamtZUmRmUHFhYkVVVDlMRWZMSUxRQW1PMGdOYyUyQkNwOE5QbFp3Y0U5NmV1aWtyZjg3b2xMZ09tOFVTdWFMenBPR2Y1anNhb0tteFZqUng5NDVBVmdzakRjdVh1cyUyRkdiYWxGVnZXTyUyRkl4dk9Q; datadome=4cwibCI1RYexaCD1wjZqJZ-6hUi16_fPyqPGEtsMSG-r3~8EoWMghXY6ZUZ3L~1GpA3vzRzDw__LqSlDp~FlYdAu_jP3M0N9vV8ZWBSbzQ0~ijJp6tNET4wW0fjfuKGn; utag_main=v_id:01792c6c39a9001726449a99708002069002106100bd0$_sn:149$_ss:0$_st:1677607622614$_pn:3%3Bexp-session$ses_id:1677604455561%3Bexp-session' \
-H 'origin: https://www.leboncoin.fr' \
-H 'referer: https://www.leboncoin.fr/deposer-une-annonce' \
-H 'sec-ch-ua: "Not A(Brand";v="24", "Chromium";v="110"' \
-H 'sec-ch-ua-mobile: ?0' \
-H 'sec-ch-ua-platform: "Linux"' \
-H 'sec-fetch-dest: empty' \
-H 'sec-fetch-mode: cors' \
-H 'sec-fetch-site: same-site' \
-H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36' \
--data-raw $'------WebKitFormBoundaryZ9zBRAquVv1qb78o\r\nContent-Disposition: form-data; name="file"; filename="20230204_194811.jpg"\r\nContent-Type: image/jpeg\r\n\r\n\r\n------WebKitFormBoundaryZ9zBRAquVv1qb78o--\r\n' \
--compressed
*/
