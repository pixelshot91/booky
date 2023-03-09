use crate::common::Ad;

pub trait Publisher {
    fn publish(&self, ad: Ad) -> bool;
}
