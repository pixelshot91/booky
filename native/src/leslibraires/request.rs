use crate::cached_client::{CachedClient, Client};

pub fn isbn_search(client: &CachedClient, isbn: &str) -> String {
    let redirection = client.make_request(
        format!("leslibraires/isbn_{}.html", isbn).as_str(),
        &|http_client| {
            http_client
                .get(format!("https://www.leslibraires.fr/article/{}", &isbn))
                .send()
                .unwrap()
                .url()
                .path()
                .to_owned()
        },
    );
    let result = client.make_request(
        format!(
            "leslibraires/get_book_url_{}.html",
            redirection.replace("/", "_slash_")
        )
        .as_str(),
        &|http_client| {
            http_client
                .get(format!("https://www.leslibraires.fr{}", &redirection))
                .send()
                .unwrap()
                .text()
                .unwrap()
        },
    );
    result
}

/* #[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_isbn_search() {
        let client = reqwest::blocking::Client::builder().build().unwrap();
        let cached_client = CachedClient {
            http_client: client,
        };
        isbn_search(&cached_client, "9782286056636");
    }
}
 */
