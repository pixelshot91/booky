use crate::common::{Ad, LbcCredential};

pub trait Publisher {
    fn publish(&self, ad: Ad, credential: LbcCredential) -> bool;
}
