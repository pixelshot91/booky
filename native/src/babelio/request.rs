use crate::client::Client;
use itertools::Itertools;

#[derive(serde::Serialize, serde::Deserialize, Debug)]
struct BabelioISBNResponse {
    id_oeuvre: String,
    titre: String,
    couverture: String,
    id: String,
    id_auteur: String,
    prenoms: String,
    nom: String,
    ca_copies: String,
    ca_note: String,
    id_edition: String,
    r#type: String,
    url: String,
}

pub fn get_book_url(client: &dyn Client, isbn: &str) -> Option<String> {
    let raw_search_results = client
        .request(format!("get_book_url_{isbn}").as_str(), &|http_client| {
            http_client
                .post("https://www.babelio.com/aj_recherche.php")
                .body(format!("{{\"isMobile\":false,\"term\":\"{isbn}\"}}"))
                .send()
        })
        .body_if_success()
        .expect("Babelio should always return status 200");
    let parsed: Vec<BabelioISBNResponse> = serde_json::from_str(&raw_search_results).unwrap();
    let s = parsed.iter().exactly_one().ok()?.url.clone();
    Some(s)
}

pub fn get_book_page(client: &dyn Client, url_fragment: String) -> String {
    let url = format!("https://www.babelio.com{url_fragment}");
    client
        .request(
            format!("get_book_page_{}", url_fragment.replace("/", "_slash_")).as_str(),
            &|http_client| http_client.get(&url).send(),
        )
        .body_if_success()
        .expect(&format!(
            "Babelio url provided from 'get_book_url' does not return valid content. URL is {url}"
        ))
}

pub fn get_book_blurb_see_more(client: &dyn Client, id_obj: &str) -> String {
    client
        .request(
            format!("get_book_blurb_see_more_{id_obj}").as_str(),
            &|http_client| {
                let params = std::collections::HashMap::from([("type", "1"), ("id_obj", id_obj)]);

                http_client
                    .post("https://www.babelio.com/aj_voir_plus_a.php")
                    .form(&params)
                    .send()
            },
        )
        .body_if_success()
        .unwrap()
}
