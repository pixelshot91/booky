pub fn search_by_isbn(client: &reqwest::blocking::Client, isbn: &str) -> String {
    let resp = client
        .get(format!(
            "https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}"
        ))
        .send()
        .unwrap();
    resp.text().unwrap()
}