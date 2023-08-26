use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_detect_barcode_in_image(port_: MessagePort, img_path: String) {
    wire_detect_barcode_in_image_impl(port_, img_path)
}

#[wasm_bindgen]
pub fn wire_get_metadata_from_isbns(port_: MessagePort, isbns: JsValue, path: String) {
    wire_get_metadata_from_isbns_impl(port_, isbns, path)
}

#[wasm_bindgen]
pub fn wire_get_auto_metadata_from_bundle(port_: MessagePort, path: String) {
    wire_get_auto_metadata_from_bundle_impl(port_, path)
}

#[wasm_bindgen]
pub fn wire_get_metadata_from_provider(port_: MessagePort, provider: i32, isbn: String) {
    wire_get_metadata_from_provider_impl(port_, provider, isbn)
}

#[wasm_bindgen]
pub fn wire_publish_ad(port_: MessagePort, ad: JsValue, credential: JsValue) {
    wire_publish_ad_impl(port_, ad, credential)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for String {
    fn wire2api(self) -> String {
        self
    }
}
impl Wire2Api<Vec<String>> for JsValue {
    fn wire2api(self) -> Vec<String> {
        self.dyn_into::<JsArray>()
            .unwrap()
            .iter()
            .map(Wire2Api::wire2api)
            .collect()
    }
}
impl Wire2Api<Ad> for JsValue {
    fn wire2api(self) -> Ad {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            5,
            "Expected 5 elements, got {}",
            self_.length()
        );
        Ad {
            title: self_.get(0).wire2api(),
            description: self_.get(1).wire2api(),
            price_cent: self_.get(2).wire2api(),
            weight_grams: self_.get(3).wire2api(),
            imgs_path: self_.get(4).wire2api(),
        }
    }
}

impl Wire2Api<LbcCredential> for JsValue {
    fn wire2api(self) -> LbcCredential {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            2,
            "Expected 2 elements, got {}",
            self_.length()
        );
        LbcCredential {
            lbc_token: self_.get(0).wire2api(),
            datadome_cookie: self_.get(1).wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}
// Section: impl Wire2Api for JsValue

impl Wire2Api<String> for JsValue {
    fn wire2api(self) -> String {
        self.as_string().expect("non-UTF-8 string, or not a string")
    }
}
impl Wire2Api<i32> for JsValue {
    fn wire2api(self) -> i32 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<ProviderEnum> for JsValue {
    fn wire2api(self) -> ProviderEnum {
        (self.unchecked_into_f64() as i32).wire2api()
    }
}
impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
