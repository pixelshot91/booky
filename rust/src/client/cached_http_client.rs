use std::path::Path;

use crate::fs_helper;

use super::{Client, Response};

pub struct CachedHttpClient {
    pub http_client: reqwest::blocking::Client,
    pub cache_dir: String,
}

impl Client for CachedHttpClient {
    // Try first to read the response from the cache
    // If the cache file does not exist, do the real request
    fn request(
        &self,
        cache_file_path: &str,
        make_request: &dyn Fn(
            &reqwest::blocking::Client,
        ) -> Result<reqwest::blocking::Response, reqwest::Error>,
    ) -> Response {
        let html_cache_path = format!(
            "{}/{}/{}.html",
            crate::config::CACHE_PATH,
            self.cache_dir,
            cache_file_path
        );
        let response_cache_path = format!(
            "{}/{}/{}.json",
            crate::config::CACHE_PATH,
            self.cache_dir,
            cache_file_path
        );

        let html = fs_helper::my_read_to_string(&html_cache_path);
        match html {
            Ok(f) => {
                println!("Read request from cache {}", &response_cache_path);
                let mut response: Response = serde_json::from_str(
                    &fs_helper::my_read_to_string(&response_cache_path).expect(&format!(
                        "Body file exist but not response file. Body file is '{html_cache_path}'"
                    )),
                )
                .unwrap();
                response.body = f;
                response
            }
            Err(_) => {
                println!("No file name {} in the cache", &response_cache_path);
                let resp = make_request(&self.http_client).unwrap();

                let status = resp.status();
                let url = resp.url().to_string();
                let r = Response {
                    body: resp.text().unwrap(),
                    status,
                    url,
                };
                if status.as_u16() == 200 || status.as_u16() == 404 {
                    let dir = Path::new(&response_cache_path).parent().unwrap();
                    std::fs::create_dir_all(dir).unwrap();
                    std::fs::write(&html_cache_path, &r.body).unwrap();
                    std::fs::write(&response_cache_path, serde_json::to_string(&r).unwrap())
                        .unwrap();
                } else { // Do not cache response if the error is temporary: E.g. the server is unavailable or we reached query limit
                    println!("CachedHttpClient: error. StatusCode = {status}");
                }
                r
            }
        }
    }
}
