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
