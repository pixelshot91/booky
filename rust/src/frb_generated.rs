// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.12.

#![allow(
    non_camel_case_types,
    unused,
    non_snake_case,
    clippy::needless_return,
    clippy::redundant_closure_call,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::unused_unit,
    clippy::double_parens,
    clippy::let_and_return,
    clippy::too_many_arguments
)]

// Section: imports

use flutter_rust_bridge::for_generated::byteorder::{NativeEndian, ReadBytesExt, WriteBytesExt};
use flutter_rust_bridge::for_generated::transform_result_dco;
use flutter_rust_bridge::{Handler, IntoIntoDart};

// Section: boilerplate

flutter_rust_bridge::frb_generated_boilerplate!();

// Section: executor

flutter_rust_bridge::frb_generated_default_handler!();

// Section: wire_funcs

fn wire_detect_barcode_in_image_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    img_path: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "detect_barcode_in_image",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_img_path = img_path.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::detect_barcode_in_image(api_img_path)
                })())
            }
        },
    )
}
fn wire_get_auto_metadata_from_bundle_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    path: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_auto_metadata_from_bundle",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_path = path.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::get_auto_metadata_from_bundle(api_path)
                })())
            }
        },
    )
}
fn wire_get_manual_metadata_for_bundle_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    bundle_path: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_manual_metadata_for_bundle",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::get_manual_metadata_for_bundle(api_bundle_path)
                })())
            }
        },
    )
}
fn wire_get_merged_metadata_for_all_bundles_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    bundles_dir: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_merged_metadata_for_all_bundles",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_bundles_dir = bundles_dir.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::get_merged_metadata_for_all_bundles(api_bundles_dir)
                })())
            }
        },
    )
}
fn wire_get_merged_metadata_for_bundle_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    bundle_path: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_merged_metadata_for_bundle",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::get_merged_metadata_for_bundle(api_bundle_path)
                })())
            }
        },
    )
}
fn wire_get_metadata_from_isbns_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    isbns: impl CstDecode<Vec<String>>,
    path: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_metadata_from_isbns",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_isbns = isbns.cst_decode();
            let api_path = path.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::get_metadata_from_isbns(api_isbns, api_path)
                })())
            }
        },
    )
}
fn wire_get_metadata_from_provider_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    provider: impl CstDecode<crate::api::api::ProviderEnum>,
    isbn: impl CstDecode<String>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "get_metadata_from_provider",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_provider = provider.cst_decode();
            let api_isbn = isbn.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    Result::<_, ()>::Ok(crate::api::api::get_metadata_from_provider(
                        api_provider,
                        api_isbn,
                    ))
                })())
            }
        },
    )
}
fn wire_set_manual_metadata_for_bundle_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    bundle_path: impl CstDecode<String>,
    bundle_metadata: impl CstDecode<crate::api::api::BundleMetaData>,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::DcoCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "set_manual_metadata_for_bundle",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.cst_decode();
            let api_bundle_metadata = bundle_metadata.cst_decode();
            move |context| {
                transform_result_dco((move || {
                    crate::api::api::set_manual_metadata_for_bundle(
                        api_bundle_path,
                        api_bundle_metadata,
                    )
                })())
            }
        },
    )
}

// Section: dart2rust

impl CstDecode<f32> for f32 {
    fn cst_decode(self) -> f32 {
        self
    }
}
impl CstDecode<i32> for i32 {
    fn cst_decode(self) -> i32 {
        self
    }
}
impl CstDecode<crate::api::api::ItemState> for i32 {
    fn cst_decode(self) -> crate::api::api::ItemState {
        match self {
            0 => crate::api::api::ItemState::BrandNew,
            1 => crate::api::api::ItemState::VeryGood,
            2 => crate::api::api::ItemState::Good,
            3 => crate::api::api::ItemState::Medium,
            _ => unreachable!("Invalid variant for ItemState: {}", self),
        }
    }
}
impl CstDecode<crate::api::api::ProviderEnum> for i32 {
    fn cst_decode(self) -> crate::api::api::ProviderEnum {
        match self {
            0 => crate::api::api::ProviderEnum::Babelio,
            1 => crate::api::api::ProviderEnum::GoogleBooks,
            2 => crate::api::api::ProviderEnum::BooksPrice,
            3 => crate::api::api::ProviderEnum::AbeBooks,
            4 => crate::api::api::ProviderEnum::LesLibraires,
            5 => crate::api::api::ProviderEnum::JustBooks,
            _ => unreachable!("Invalid variant for ProviderEnum: {}", self),
        }
    }
}
impl CstDecode<u16> for u16 {
    fn cst_decode(self) -> u16 {
        self
    }
}
impl CstDecode<u8> for u8 {
    fn cst_decode(self) -> u8 {
        self
    }
}
impl SseDecode for anyhow::Error {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        unimplemented!("not yet supported in serialized mode, feel free to create an issue");
    }
}

impl SseDecode for String {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <Vec<u8>>::sse_decode(deserializer);
        return String::from_utf8(inner).unwrap();
    }
}

impl SseDecode for crate::api::api::Author {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_firstName = <String>::sse_decode(deserializer);
        let mut var_lastName = <String>::sse_decode(deserializer);
        return crate::api::api::Author {
            first_name: var_firstName,
            last_name: var_lastName,
        };
    }
}

impl SseDecode for crate::api::api::BarcodeDetectResult {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_value = <String>::sse_decode(deserializer);
        let mut var_corners = <Vec<crate::api::api::Point>>::sse_decode(deserializer);
        return crate::api::api::BarcodeDetectResult {
            value: var_value,
            corners: var_corners,
        };
    }
}

impl SseDecode for crate::api::api::BarcodeDetectResults {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_results = <Vec<crate::api::api::BarcodeDetectResult>>::sse_decode(deserializer);
        return crate::api::api::BarcodeDetectResults {
            results: var_results,
        };
    }
}

impl SseDecode for crate::api::api::BookMetaData {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_isbn = <String>::sse_decode(deserializer);
        let mut var_title = <Option<String>>::sse_decode(deserializer);
        let mut var_authors = <Vec<crate::api::api::Author>>::sse_decode(deserializer);
        let mut var_blurb = <Option<String>>::sse_decode(deserializer);
        let mut var_keywords = <Vec<String>>::sse_decode(deserializer);
        let mut var_priceCent = <Option<i32>>::sse_decode(deserializer);
        return crate::api::api::BookMetaData {
            isbn: var_isbn,
            title: var_title,
            authors: var_authors,
            blurb: var_blurb,
            keywords: var_keywords,
            price_cent: var_priceCent,
        };
    }
}

impl SseDecode for crate::api::api::BookMetaDataFromProvider {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_title = <Option<String>>::sse_decode(deserializer);
        let mut var_authors = <Vec<crate::api::api::Author>>::sse_decode(deserializer);
        let mut var_blurb = <Option<String>>::sse_decode(deserializer);
        let mut var_keywords = <Vec<String>>::sse_decode(deserializer);
        let mut var_marketPrice = <Vec<f32>>::sse_decode(deserializer);
        return crate::api::api::BookMetaDataFromProvider {
            title: var_title,
            authors: var_authors,
            blurb: var_blurb,
            keywords: var_keywords,
            market_price: var_marketPrice,
        };
    }
}

impl SseDecode for crate::api::api::BundleMetaData {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_weightGrams = <Option<i32>>::sse_decode(deserializer);
        let mut var_itemState = <Option<crate::api::api::ItemState>>::sse_decode(deserializer);
        let mut var_books = <Vec<crate::api::api::BookMetaData>>::sse_decode(deserializer);
        return crate::api::api::BundleMetaData {
            weight_grams: var_weightGrams,
            item_state: var_itemState,
            books: var_books,
        };
    }
}

impl SseDecode for f32 {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_f32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for i32 {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_i32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for crate::api::api::ISBNMetadataPair {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_isbn = <String>::sse_decode(deserializer);
        let mut var_metadatas =
            <Vec<crate::api::api::ProviderMetadataPair>>::sse_decode(deserializer);
        return crate::api::api::ISBNMetadataPair {
            isbn: var_isbn,
            metadatas: var_metadatas,
        };
    }
}

impl SseDecode for crate::api::api::ItemState {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::api::ItemState::BrandNew,
            1 => crate::api::api::ItemState::VeryGood,
            2 => crate::api::api::ItemState::Good,
            3 => crate::api::api::ItemState::Medium,
            _ => unreachable!("Invalid variant for ItemState: {}", inner),
        };
    }
}

impl SseDecode for Vec<String> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<String>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::Author> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::Author>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::BarcodeDetectResult> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::BarcodeDetectResult>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::BookMetaData> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::BookMetaData>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::ISBNMetadataPair> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::ISBNMetadataPair>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<Option<crate::api::api::BundleMetaData>> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<Option<crate::api::api::BundleMetaData>>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::Point> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::Point>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<f32> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<f32>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<u8> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<u8>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::api::ProviderMetadataPair> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = vec![];
        for idx_ in 0..len_ {
            ans_.push(<crate::api::api::ProviderMetadataPair>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Option<String> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<String>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::api::BookMetaDataFromProvider> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::api::BookMetaDataFromProvider>::sse_decode(
                deserializer,
            ));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::api::BundleMetaData> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::api::BundleMetaData>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<i32> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<i32>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::api::ItemState> {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::api::ItemState>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for crate::api::api::Point {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_x = <u16>::sse_decode(deserializer);
        let mut var_y = <u16>::sse_decode(deserializer);
        return crate::api::api::Point { x: var_x, y: var_y };
    }
}

impl SseDecode for crate::api::api::ProviderEnum {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::api::ProviderEnum::Babelio,
            1 => crate::api::api::ProviderEnum::GoogleBooks,
            2 => crate::api::api::ProviderEnum::BooksPrice,
            3 => crate::api::api::ProviderEnum::AbeBooks,
            4 => crate::api::api::ProviderEnum::LesLibraires,
            5 => crate::api::api::ProviderEnum::JustBooks,
            _ => unreachable!("Invalid variant for ProviderEnum: {}", inner),
        };
    }
}

impl SseDecode for crate::api::api::ProviderMetadataPair {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_provider = <crate::api::api::ProviderEnum>::sse_decode(deserializer);
        let mut var_metadata =
            <Option<crate::api::api::BookMetaDataFromProvider>>::sse_decode(deserializer);
        return crate::api::api::ProviderMetadataPair {
            provider: var_provider,
            metadata: var_metadata,
        };
    }
}

impl SseDecode for u16 {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u16::<NativeEndian>().unwrap()
    }
}

impl SseDecode for u8 {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap()
    }
}

impl SseDecode for () {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {}
}

impl SseDecode for bool {
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap() != 0
    }
}

// Section: rust2dart

impl flutter_rust_bridge::IntoDart for crate::api::api::Author {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.first_name.into_into_dart().into_dart(),
            self.last_name.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::api::Author {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::Author> for crate::api::api::Author {
    fn into_into_dart(self) -> crate::api::api::Author {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::BarcodeDetectResult {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.value.into_into_dart().into_dart(),
            self.corners.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::BarcodeDetectResult
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::BarcodeDetectResult>
    for crate::api::api::BarcodeDetectResult
{
    fn into_into_dart(self) -> crate::api::api::BarcodeDetectResult {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::BarcodeDetectResults {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![self.results.into_into_dart().into_dart()].into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::BarcodeDetectResults
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::BarcodeDetectResults>
    for crate::api::api::BarcodeDetectResults
{
    fn into_into_dart(self) -> crate::api::api::BarcodeDetectResults {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::BookMetaData {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.isbn.into_into_dart().into_dart(),
            self.title.into_into_dart().into_dart(),
            self.authors.into_into_dart().into_dart(),
            self.blurb.into_into_dart().into_dart(),
            self.keywords.into_into_dart().into_dart(),
            self.price_cent.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::api::BookMetaData {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::BookMetaData>
    for crate::api::api::BookMetaData
{
    fn into_into_dart(self) -> crate::api::api::BookMetaData {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::BookMetaDataFromProvider {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.title.into_into_dart().into_dart(),
            self.authors.into_into_dart().into_dart(),
            self.blurb.into_into_dart().into_dart(),
            self.keywords.into_into_dart().into_dart(),
            self.market_price.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::BookMetaDataFromProvider
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::BookMetaDataFromProvider>
    for crate::api::api::BookMetaDataFromProvider
{
    fn into_into_dart(self) -> crate::api::api::BookMetaDataFromProvider {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::BundleMetaData {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.weight_grams.into_into_dart().into_dart(),
            self.item_state.into_into_dart().into_dart(),
            self.books.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::BundleMetaData
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::BundleMetaData>
    for crate::api::api::BundleMetaData
{
    fn into_into_dart(self) -> crate::api::api::BundleMetaData {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::ISBNMetadataPair {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.isbn.into_into_dart().into_dart(),
            self.metadatas.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::ISBNMetadataPair
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::ISBNMetadataPair>
    for crate::api::api::ISBNMetadataPair
{
    fn into_into_dart(self) -> crate::api::api::ISBNMetadataPair {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::ItemState {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::BrandNew => 0,
            Self::VeryGood => 1,
            Self::Good => 2,
            Self::Medium => 3,
        }
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::api::ItemState {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::ItemState> for crate::api::api::ItemState {
    fn into_into_dart(self) -> crate::api::api::ItemState {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::Point {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.x.into_into_dart().into_dart(),
            self.y.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::api::Point {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::Point> for crate::api::api::Point {
    fn into_into_dart(self) -> crate::api::api::Point {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::ProviderEnum {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Babelio => 0,
            Self::GoogleBooks => 1,
            Self::BooksPrice => 2,
            Self::AbeBooks => 3,
            Self::LesLibraires => 4,
            Self::JustBooks => 5,
        }
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::api::ProviderEnum {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::ProviderEnum>
    for crate::api::api::ProviderEnum
{
    fn into_into_dart(self) -> crate::api::api::ProviderEnum {
        self
    }
}
impl flutter_rust_bridge::IntoDart for crate::api::api::ProviderMetadataPair {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        vec![
            self.provider.into_into_dart().into_dart(),
            self.metadata.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::api::ProviderMetadataPair
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::api::ProviderMetadataPair>
    for crate::api::api::ProviderMetadataPair
{
    fn into_into_dart(self) -> crate::api::api::ProviderMetadataPair {
        self
    }
}

impl SseEncode for anyhow::Error {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(format!("{:?}", self), serializer);
    }
}

impl SseEncode for String {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<u8>>::sse_encode(self.into_bytes(), serializer);
    }
}

impl SseEncode for crate::api::api::Author {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.first_name, serializer);
        <String>::sse_encode(self.last_name, serializer);
    }
}

impl SseEncode for crate::api::api::BarcodeDetectResult {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.value, serializer);
        <Vec<crate::api::api::Point>>::sse_encode(self.corners, serializer);
    }
}

impl SseEncode for crate::api::api::BarcodeDetectResults {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<crate::api::api::BarcodeDetectResult>>::sse_encode(self.results, serializer);
    }
}

impl SseEncode for crate::api::api::BookMetaData {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.isbn, serializer);
        <Option<String>>::sse_encode(self.title, serializer);
        <Vec<crate::api::api::Author>>::sse_encode(self.authors, serializer);
        <Option<String>>::sse_encode(self.blurb, serializer);
        <Vec<String>>::sse_encode(self.keywords, serializer);
        <Option<i32>>::sse_encode(self.price_cent, serializer);
    }
}

impl SseEncode for crate::api::api::BookMetaDataFromProvider {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<String>>::sse_encode(self.title, serializer);
        <Vec<crate::api::api::Author>>::sse_encode(self.authors, serializer);
        <Option<String>>::sse_encode(self.blurb, serializer);
        <Vec<String>>::sse_encode(self.keywords, serializer);
        <Vec<f32>>::sse_encode(self.market_price, serializer);
    }
}

impl SseEncode for crate::api::api::BundleMetaData {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<i32>>::sse_encode(self.weight_grams, serializer);
        <Option<crate::api::api::ItemState>>::sse_encode(self.item_state, serializer);
        <Vec<crate::api::api::BookMetaData>>::sse_encode(self.books, serializer);
    }
}

impl SseEncode for f32 {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_f32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for i32 {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_i32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for crate::api::api::ISBNMetadataPair {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.isbn, serializer);
        <Vec<crate::api::api::ProviderMetadataPair>>::sse_encode(self.metadatas, serializer);
    }
}

impl SseEncode for crate::api::api::ItemState {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self as _, serializer);
    }
}

impl SseEncode for Vec<String> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <String>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::Author> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::Author>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::BarcodeDetectResult> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::BarcodeDetectResult>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::BookMetaData> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::BookMetaData>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::ISBNMetadataPair> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::ISBNMetadataPair>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<Option<crate::api::api::BundleMetaData>> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <Option<crate::api::api::BundleMetaData>>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::Point> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::Point>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<f32> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <f32>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<u8> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <u8>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::api::ProviderMetadataPair> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::api::ProviderMetadataPair>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Option<String> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <String>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::api::BookMetaDataFromProvider> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::api::BookMetaDataFromProvider>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::api::BundleMetaData> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::api::BundleMetaData>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<i32> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <i32>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::api::ItemState> {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::api::ItemState>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for crate::api::api::Point {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u16>::sse_encode(self.x, serializer);
        <u16>::sse_encode(self.y, serializer);
    }
}

impl SseEncode for crate::api::api::ProviderEnum {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self as _, serializer);
    }
}

impl SseEncode for crate::api::api::ProviderMetadataPair {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::api::ProviderEnum>::sse_encode(self.provider, serializer);
        <Option<crate::api::api::BookMetaDataFromProvider>>::sse_encode(self.metadata, serializer);
    }
}

impl SseEncode for u16 {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u16::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for u8 {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self).unwrap();
    }
}

impl SseEncode for () {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {}
}

impl SseEncode for bool {
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self as _).unwrap();
    }
}

#[cfg(not(target_family = "wasm"))]
#[path = "frb_generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;

/// cbindgen:ignore
#[cfg(target_family = "wasm")]
#[path = "frb_generated.web.rs"]
mod web;
#[cfg(target_family = "wasm")]
pub use web::*;
