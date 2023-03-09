use crate::cached_client::CachedClient;
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

pub fn get_book_url(client: &CachedClient, isbn: &str) -> Option<String> {
    let raw_search_results = client.get_from_cache(
        format!("cache/babelio/get_book_url_{}.html", isbn).as_str(),
        |http_client| {
            http_client
                .post("https://www.babelio.com/aj_recherche.php")
                .body(format!("{{\"isMobile\":false,\"term\":\"{}\"}}", isbn))
                .send()
                .unwrap()
                .text()
                .unwrap()
        },
    );
    let parsed: Vec<BabelioISBNResponse> = serde_json::from_str(&raw_search_results).unwrap();
    let s = parsed.iter().exactly_one().ok()?.url.clone();
    Some(s)
}

pub fn get_book_page(client: &CachedClient, url: String) -> String {
    client.get_from_cache(
        format!(
            "cache/babelio/get_book_page_{}.html",
            url.replace("/", "_slash_")
        )
        .as_str(),
        |http_client| {
            let resp = http_client
                .get(format!("https://www.babelio.com{url}"))
                .send()
                .unwrap();
            resp.text().unwrap()
        },
    )
}

pub fn get_book_blurb_see_more(client: &CachedClient, id_obj: &str) -> String {
    client.get_from_cache(
        format!("cache/babelio/get_book_blurb_see_more_{}.html", id_obj).as_str(),
        |http_client| {
            let params = std::collections::HashMap::from([("type", "1"), ("id_obj", id_obj)]);

            let voir_plus_resp = http_client
                .post("https://www.babelio.com/aj_voir_plus_a.php")
                .form(&params)
                .send()
                .unwrap();
            voir_plus_resp.text().unwrap()
        },
    )
}
