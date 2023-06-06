use crate::cached_client::Client;

pub fn get_book_page(client: &dyn Client, isbn: &str) -> String {
     client.make_request(
        format!("justbooks/get_book_url_{}.html", isbn).as_str(),
        &|http_client| {
            http_client
                .get(format!(
                    "https://www.justbooks.fr/search/?isbn={}&st=xl&ac=qr",
                    &isbn
                ))
                .send()
                .unwrap()
                .text()
                .unwrap()
        },
    )
}
