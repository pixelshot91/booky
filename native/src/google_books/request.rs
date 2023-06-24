use crate::cached_client::Client;

const CACHE_DIR: &str = "google_books";

pub fn search_by_isbn(client: &Box<dyn Client>, isbn: &str) -> String {
    client.make_request_as_text(&format!("{}/search_by_isbn_{}", CACHE_DIR, isbn), &|client| {
        client
            .get(format!(
                "https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}"
            ))
            .send()
    })
}
pub fn get_volume(client: &Box<dyn Client>, url: &str) -> String {
    client.make_request_as_text(
        &format!("{}/get_volume_{}", CACHE_DIR, crate::common::url_to_path(url)),
        &|http_client| http_client.get(url).send(),
    )
}
