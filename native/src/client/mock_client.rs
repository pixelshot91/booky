use super::{Client, Response};

pub struct MockClient {
    pub dir: &'static str,
}

impl Client for MockClient {
    fn request(
        &self,
        cache_file_path: &str,
        _make_request: &dyn Fn(
            &reqwest::blocking::Client,
        ) -> Result<reqwest::blocking::Response, reqwest::Error>,
    ) -> Response {
        println!(
            "Reading mock files: {}/{}.html/json",
            self.dir, cache_file_path
        );
        let html_cache_path = format!("{}/{}.html", self.dir, cache_file_path);
        let response_cache_path = format!("{}/{}.json", self.dir, cache_file_path);

        let mut response: Response = serde_json::from_str(
            &std::fs::read_to_string(&response_cache_path)
                .expect(&format!("Can't find mock file {response_cache_path}")),
        )
        .unwrap();
        response.body = std::fs::read_to_string(&html_cache_path)
            .expect(&format!("Can't find mock file {html_cache_path}"));
        response
    }
}
