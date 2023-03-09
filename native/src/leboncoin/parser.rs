use serde::{Deserialize, Serialize};

////////////

pub fn parse_file_upload(imgs_upload_response: &str) -> ImageSubmitResponse {
    let r: ImageSubmitResponse = serde_json::from_str(imgs_upload_response).unwrap();
    r
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ImageSubmitResponse {
    pub filename: String,
    pub url: String,
}

////////////

pub fn parse_send(send_response: &str) -> i64 {
    let s: structs::SendResponse = serde_json::from_str(send_response).unwrap();
    s.ad_id
}

mod structs {
    use serde::{Deserialize, Serialize};

    #[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
    #[serde(rename_all = "camelCase")]
    pub struct SendResponse {
        pub status: String,
        #[serde(rename = "ad_id")]
        pub ad_id: i64,
        #[serde(rename = "action_id")]
        pub action_id: i64,
        pub step: String,
        #[serde(rename = "transaction_step")]
        pub transaction_step: String,
    }
}

//////////////

#[derive(Debug)]
pub enum SubmitResult {
    Submitted,
    Captcha(String),
}

pub fn parse_submit(submit_response: &str) -> SubmitResult {
    if submit_response == "{}" {
        return SubmitResult::Submitted;
    }
    let s: SubmitResponse = serde_json::from_str(submit_response).unwrap();
    SubmitResult::Captcha(s.url)
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SubmitResponse {
    pub url: String,
}
