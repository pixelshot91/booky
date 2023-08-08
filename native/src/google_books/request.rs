use crate::client::Client;

pub fn search_by_isbn(client: &Box<dyn Client>, isbn: &str) -> String {
    client
        .request(&format!("search_by_isbn_{}", isbn), &|client| {
            client
                .get(format!(
                    "https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}"
                ))
                .send()
        })
        .body_if_success()
        .expect("Google books should return an HTML response with status code 200")
}
pub fn get_volume(client: &Box<dyn Client>, url: &str) -> String {
    client
        .request(
            &format!("get_volume_{}", crate::common::url_to_path(url)),
            &|http_client| http_client.get(url).send(),
        )
        .body_if_success()
        .expect("Google books should return an HTML response with status code 200")
}
