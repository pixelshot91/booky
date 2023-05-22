use crate::cached_client::{CachedClient, Client};

pub fn isbn_search(client: &CachedClient, isbn: &str) -> String {
    let redirection = client.make_request(
        format!("leslibraires/isbn_{}.html", isbn).as_str(),
        &|http_client| {
            http_client
                .get(format!(
                    "https://www.leslibraires.fr/recherche/?q={}",
                    &isbn
                ))
                .send()
                .unwrap()
                .headers()
                .get("location")
                .map(|header_value| header_value.to_str().unwrap())
                .unwrap()
                .to_owned()
        },
    );
    let result = client.make_request(
        format!("leslibraires/get_book_url_{}.html", redirection).as_str(),
        &|http_client| {
            http_client
                .get(format!(
                    "https://www.leslibraires.fr/{}",
                    &redirection
                ))
                .send()
                .unwrap()
                .text()
                .unwrap()
        },
    );
    result
}

