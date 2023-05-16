use std::path::Path;

pub trait Client {
    fn make_request(
        &self,
        cache_file_path: &str,
        _make_request: &dyn Fn(&reqwest::blocking::Client) -> String,
    ) -> String;
}

pub struct MockClient {
    pub dir: &'static str,
}

impl Client for MockClient {
    fn make_request(
        &self,
        cache_file_path: &str,
        _make_request: &dyn Fn(&reqwest::blocking::Client) -> String,
    ) -> String {
        let cache_file_path = format!("{}/{}", self.dir, cache_file_path);
        let html = std::fs::read_to_string(&cache_file_path);

        match html {
            Ok(f) => {
                println!("Read request from cache {}", &cache_file_path);
                f
            }
            Err(e) => panic!("Cannot find mock file {}. Error is {}", cache_file_path, e),
        }
    }
}

pub struct CachedClient {
    pub http_client: reqwest::blocking::Client,
}

impl Client for CachedClient {
    fn make_request(
        &self,
        cache_file_path: &str,
        _make_request: &dyn Fn(&reqwest::blocking::Client) -> String,
    ) -> String {
        let cache_file_path = format!("{}/{}", crate::config::CACHE_PATH, cache_file_path);
        let html = std::fs::read_to_string(&cache_file_path);
        match html {
            Ok(f) => {
                println!("Read request from cache {}", &cache_file_path);
                f
            }
            Err(_) => {
                println!("No file name {} in the cache", &cache_file_path);
                let resp = _make_request(&self.http_client);
                let dir = Path::new(&cache_file_path).parent().unwrap();
                std::fs::create_dir_all(dir).unwrap();
                let write_res = std::fs::write(&cache_file_path, &resp);
                write_res.expect(format!("Can't write to file {}", cache_file_path).as_str());
                resp
            }
        }
    }
}
