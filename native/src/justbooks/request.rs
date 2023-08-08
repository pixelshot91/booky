use crate::client::Client;

pub fn get_book_page(client: &dyn Client, isbn: &str) -> String {
    client
        .request(
            format!("get_book_url_{}", isbn).as_str(),
            &|http_client| {
                http_client
                    .get(format!(
                        "https://www.justbooks.fr/search/?isbn={}&st=xl&ac=qr",
                        &isbn
                    ))
                    .send()
            },
        )
        .body_if_success()
        .expect("JustBooks should return an HTML response with status code 200")
}
