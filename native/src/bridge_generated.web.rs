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
pub fn wire_get_manual_metadata_for_bundle(port_: MessagePort, bundle_path: String) {
    wire_get_manual_metadata_for_bundle_impl(port_, bundle_path)
}

#[wasm_bindgen]
pub fn wire_set_merged_metadata_for_bundle(
    port_: MessagePort,
    bundle_path: String,
    bundle_metadata: JsValue,
) {
    wire_set_merged_metadata_for_bundle_impl(port_, bundle_path, bundle_metadata)
}

#[wasm_bindgen]
pub fn wire_get_merged_metadata_for_bundle(port_: MessagePort, bundle_path: String) {
    wire_get_merged_metadata_for_bundle_impl(port_, bundle_path)
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
impl Wire2Api<Author> for JsValue {
    fn wire2api(self) -> Author {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            2,
            "Expected 2 elements, got {}",
            self_.length()
        );
        Author {
            first_name: self_.get(0).wire2api(),
            last_name: self_.get(1).wire2api(),
        }
    }
}
impl Wire2Api<BookMetaData> for JsValue {
    fn wire2api(self) -> BookMetaData {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            6,
            "Expected 6 elements, got {}",
            self_.length()
        );
        BookMetaData {
            isbn: self_.get(0).wire2api(),
            title: self_.get(1).wire2api(),
            authors: self_.get(2).wire2api(),
            blurb: self_.get(3).wire2api(),
            keywords: self_.get(4).wire2api(),
            price_cent: self_.get(5).wire2api(),
        }
    }
}

impl Wire2Api<BundleMetaData> for JsValue {
    fn wire2api(self) -> BundleMetaData {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            3,
            "Expected 3 elements, got {}",
            self_.length()
        );
        BundleMetaData {
            weight_grams: self_.get(0).wire2api(),
            item_state: self_.get(1).wire2api(),
            books: self_.get(2).wire2api(),
        }
    }
}

impl Wire2Api<Vec<Author>> for JsValue {
    fn wire2api(self) -> Vec<Author> {
        self.dyn_into::<JsArray>()
            .unwrap()
            .iter()
            .map(Wire2Api::wire2api)
            .collect()
    }
}
impl Wire2Api<Vec<BookMetaData>> for JsValue {
    fn wire2api(self) -> Vec<BookMetaData> {
        self.dyn_into::<JsArray>()
            .unwrap()
            .iter()
            .map(Wire2Api::wire2api)
            .collect()
    }
}
impl Wire2Api<Option<String>> for Option<String> {
    fn wire2api(self) -> Option<String> {
        self.map(Wire2Api::wire2api)
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
impl Wire2Api<ItemState> for JsValue {
    fn wire2api(self) -> ItemState {
        (self.unchecked_into_f64() as i32).wire2api()
    }
}
impl Wire2Api<Option<String>> for JsValue {
    fn wire2api(self) -> Option<String> {
        (!self.is_undefined() && !self.is_null()).then(|| self.wire2api())
    }
}
impl Wire2Api<Option<i32>> for JsValue {
    fn wire2api(self) -> Option<i32> {
        (!self.is_undefined() && !self.is_null()).then(|| self.wire2api())
    }
}
impl Wire2Api<Option<ItemState>> for JsValue {
    fn wire2api(self) -> Option<ItemState> {
        (!self.is_undefined() && !self.is_null()).then(|| self.wire2api())
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
