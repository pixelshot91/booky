pub(crate) mod cached_http_client;
pub(crate) mod mock_client;

pub trait Client {
    fn request(
        &self,
        cache_file_path: &str,
        make_request: &dyn Fn(
            &reqwest::blocking::Client,
        ) -> Result<reqwest::blocking::Response, reqwest::Error>,
    ) -> Response;
}

// Used to represent indifferently cached response or fresh response from the network
#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct Response {
    pub url: String,
    #[serde(skip)]
    // body is stored in a separate html file to be able to preview it easily with a browser
    pub body: String,
    #[serde(with = "MyStatusCode")]
    pub status: reqwest::StatusCode,
}

// Can't derive serde trait on reqwest::StatusCode because both are from external crate
// So MyStatusCode is used to (de)serialize the u16
#[derive(Debug, Copy, Clone, serde::Deserialize, serde::Serialize)]
#[serde(remote = "reqwest::StatusCode")]
struct MyStatusCode(#[serde(getter = "reqwest::StatusCode::as_u16")] u16);

impl From<MyStatusCode> for reqwest::StatusCode {
    fn from(value: MyStatusCode) -> Self {
        reqwest::StatusCode::from_u16(value.0).unwrap()
    }
}

impl Response {
    pub fn body_if_success(self) -> Option<String> {
        if self.status.is_success() {
            Some(self.body)
        } else {
            None
        }
    }
}
