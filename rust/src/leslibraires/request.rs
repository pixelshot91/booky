use crate::client::Client;

pub fn isbn_search(client: &dyn Client, isbn: &str) -> Option<String> {
    let isbn_search_response = client.request(
        format!("isbn_{}", isbn).as_str(),
        &|http_client| {
            http_client
                .get(format!("https://www.leslibraires.fr/article/{}", &isbn))
                .send()
        },
    );
    if isbn_search_response.status == 404 {
        return None;
    }
    assert_eq!(isbn_search_response.status, 200);
    let redirection_url = isbn_search_response.url;
    client
        .request(
            format!(
                "get_book_url_{}",
                redirection_url.replace("/", "_slash_")
            )
            .as_str(),
            &|http_client| http_client.get(redirection_url.to_owned()).send(),
        )
        .body_if_success()
}

#[cfg(test)]
mod tests {
    use crate::client::mock_client::MockClient;

    use super::*;

    #[test]
    fn test_unknown_book() {
        let client = MockClient {
            dir: "mock/leslibraires/unknown_book",
        };
        let res = isbn_search(&client, "9780956010902");
        assert_eq!(res, None);
    }
}
