pub struct CachedClient {
    pub http_client: reqwest::blocking::Client,
}

impl CachedClient {
    pub fn get_from_cache<F: Fn(&reqwest::blocking::Client) -> String>(
        &self,
        cache_file_path: &str,
        make_request: F,
    ) -> String {
        let cache_file_path = format!("{}/{}", crate::config::CACHE_PATH ,  cache_file_path);
        let html = std::fs::read_to_string(&cache_file_path);
        match html {
            Ok(f) => {
                println!("Read request from cache {}", &cache_file_path);
                f
            },
            Err(_) => {
                println!("No file name {} in the cache", &cache_file_path);
                let resp = make_request(&self.http_client);
                let write_res = std::fs::write(&cache_file_path, &resp);
                write_res.expect(format!("Can't write to file {}", cache_file_path).as_str());
                resp
            }
        }
    }
}
