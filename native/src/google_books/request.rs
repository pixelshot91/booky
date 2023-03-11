pub fn search_by_isbn(client: &reqwest::blocking::Client, isbn: &str) -> String {
    let resp = client
        .get(format!(
            "https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}"
        ))
        .send()
        .unwrap();
    resp.text().unwrap()
}
pub fn get_volume(client: &reqwest::blocking::Client, url: &str) -> String {
    let resp = client.get(url).send().unwrap();
    resp.text().unwrap()
}
