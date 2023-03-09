use itertools::Itertools;
use serde::{Deserialize, Serialize};
#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
struct JWT {
    exp: u64,
}
use std::time::SystemTime;

pub fn check_jwt_expiration(jwt: &str) -> () {
    let parts = jwt.split('.').collect_vec();
    let p = parts[1];
    println!("p = {}", p);
    let decoded =
        base64::Engine::decode(&base64::engine::general_purpose::URL_SAFE_NO_PAD, p).unwrap();
    let jj: JWT = serde_json::from_slice(&decoded).unwrap();
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_secs();
    if jj.exp < now {
        panic!("TOKEN is expired");
    }
}
