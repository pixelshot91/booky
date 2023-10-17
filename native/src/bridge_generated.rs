#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case,
    clippy::too_many_arguments
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.81.0.

use crate::api::*;
use core::panic::UnwindSafe;
use flutter_rust_bridge::rust2dart::IntoIntoDart;
use flutter_rust_bridge::*;
use std::ffi::c_void;
use std::sync::Arc;

// Section: imports

use crate::common::Author;
use crate::common::BookMetaDataFromProvider;

// Section: wire functions

fn wire_detect_barcode_in_image_impl(
    port_: MessagePort,
    img_path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, BarcodeDetectResults>(
        WrapInfo {
            debug_name: "detect_barcode_in_image",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_img_path = img_path.wire2api();
            move |task_callback| detect_barcode_in_image(api_img_path)
        },
    )
}
fn wire_get_metadata_from_isbns_impl(
    port_: MessagePort,
    isbns: impl Wire2Api<Vec<String>> + UnwindSafe,
    path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, ()>(
        WrapInfo {
            debug_name: "get_metadata_from_isbns",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_isbns = isbns.wire2api();
            let api_path = path.wire2api();
            move |task_callback| get_metadata_from_isbns(api_isbns, api_path)
        },
    )
}
fn wire_get_auto_metadata_from_bundle_impl(
    port_: MessagePort,
    path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Vec<ISBNMetadataPair>>(
        WrapInfo {
            debug_name: "get_auto_metadata_from_bundle",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_path = path.wire2api();
            move |task_callback| get_auto_metadata_from_bundle(api_path)
        },
    )
}
fn wire_get_manual_metadata_for_bundle_impl(
    port_: MessagePort,
    bundle_path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, BundleMetaData>(
        WrapInfo {
            debug_name: "get_manual_metadata_for_bundle",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.wire2api();
            move |task_callback| get_manual_metadata_for_bundle(api_bundle_path)
        },
    )
}
fn wire_set_manual_metadata_for_bundle_impl(
    port_: MessagePort,
    bundle_path: impl Wire2Api<String> + UnwindSafe,
    bundle_metadata: impl Wire2Api<BundleMetaData> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, ()>(
        WrapInfo {
            debug_name: "set_manual_metadata_for_bundle",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.wire2api();
            let api_bundle_metadata = bundle_metadata.wire2api();
            move |task_callback| {
                set_manual_metadata_for_bundle(api_bundle_path, api_bundle_metadata)
            }
        },
    )
}
fn wire_get_merged_metadata_for_all_bundles_impl(
    port_: MessagePort,
    bundles_dir: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Vec<Option<BundleMetaData>>>(
        WrapInfo {
            debug_name: "get_merged_metadata_for_all_bundles",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_bundles_dir = bundles_dir.wire2api();
            move |task_callback| get_merged_metadata_for_all_bundles(api_bundles_dir)
        },
    )
}
fn wire_get_merged_metadata_for_bundle_impl(
    port_: MessagePort,
    bundle_path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, BundleMetaData>(
        WrapInfo {
            debug_name: "get_merged_metadata_for_bundle",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_bundle_path = bundle_path.wire2api();
            move |task_callback| get_merged_metadata_for_bundle(api_bundle_path)
        },
    )
}
fn wire_get_metadata_from_provider_impl(
    port_: MessagePort,
    provider: impl Wire2Api<ProviderEnum> + UnwindSafe,
    isbn: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Option<BookMetaDataFromProvider>>(
        WrapInfo {
            debug_name: "get_metadata_from_provider",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_provider = provider.wire2api();
            let api_isbn = isbn.wire2api();
            move |task_callback| Ok(get_metadata_from_provider(api_provider, api_isbn))
        },
    )
}
// Section: wrapper structs

// Section: static checks

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null()).then(|| self.wire2api())
    }
}

impl Wire2Api<i32> for i32 {
    fn wire2api(self) -> i32 {
        self
    }
}
impl Wire2Api<ItemState> for i32 {
    fn wire2api(self) -> ItemState {
        match self {
            0 => ItemState::BrandNew,
            1 => ItemState::VeryGood,
            2 => ItemState::Good,
            3 => ItemState::Medium,
            _ => unreachable!("Invalid variant for ItemState: {}", self),
        }
    }
}

impl Wire2Api<ProviderEnum> for i32 {
    fn wire2api(self) -> ProviderEnum {
        match self {
            0 => ProviderEnum::Babelio,
            1 => ProviderEnum::GoogleBooks,
            2 => ProviderEnum::BooksPrice,
            3 => ProviderEnum::AbeBooks,
            4 => ProviderEnum::LesLibraires,
            5 => ProviderEnum::JustBooks,
            _ => unreachable!("Invalid variant for ProviderEnum: {}", self),
        }
    }
}
impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

// Section: impl IntoDart

impl support::IntoDart for Author {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.first_name.into_into_dart().into_dart(),
            self.last_name.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Author {}
impl rust2dart::IntoIntoDart<Author> for Author {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for BarcodeDetectResult {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.value.into_into_dart().into_dart(),
            self.corners.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for BarcodeDetectResult {}
impl rust2dart::IntoIntoDart<BarcodeDetectResult> for BarcodeDetectResult {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for BarcodeDetectResults {
    fn into_dart(self) -> support::DartAbi {
        vec![self.results.into_into_dart().into_dart()].into_dart()
    }
}
impl support::IntoDartExceptPrimitive for BarcodeDetectResults {}
impl rust2dart::IntoIntoDart<BarcodeDetectResults> for BarcodeDetectResults {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for BookMetaData {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.isbn.into_into_dart().into_dart(),
            self.title.into_dart(),
            self.authors.into_into_dart().into_dart(),
            self.blurb.into_dart(),
            self.keywords.into_into_dart().into_dart(),
            self.price_cent.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for BookMetaData {}
impl rust2dart::IntoIntoDart<BookMetaData> for BookMetaData {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for BookMetaDataFromProvider {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.title.into_dart(),
            self.authors.into_into_dart().into_dart(),
            self.blurb.into_dart(),
            self.keywords.into_into_dart().into_dart(),
            self.market_price.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for BookMetaDataFromProvider {}
impl rust2dart::IntoIntoDart<BookMetaDataFromProvider> for BookMetaDataFromProvider {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for BundleMetaData {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.weight_grams.into_dart(),
            self.item_state.into_dart(),
            self.books.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for BundleMetaData {}
impl rust2dart::IntoIntoDart<BundleMetaData> for BundleMetaData {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for ISBNMetadataPair {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.isbn.into_into_dart().into_dart(),
            self.metadatas.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for ISBNMetadataPair {}
impl rust2dart::IntoIntoDart<ISBNMetadataPair> for ISBNMetadataPair {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for ItemState {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::BrandNew => 0,
            Self::VeryGood => 1,
            Self::Good => 2,
            Self::Medium => 3,
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for ItemState {}
impl rust2dart::IntoIntoDart<ItemState> for ItemState {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for Point {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.x.into_into_dart().into_dart(),
            self.y.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Point {}
impl rust2dart::IntoIntoDart<Point> for Point {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for ProviderEnum {
    fn into_dart(self) -> support::DartAbi {
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
impl support::IntoDartExceptPrimitive for ProviderEnum {}
impl rust2dart::IntoIntoDart<ProviderEnum> for ProviderEnum {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for ProviderMetadataPair {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.provider.into_into_dart().into_dart(),
            self.metadata.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for ProviderMetadataPair {}
impl rust2dart::IntoIntoDart<ProviderMetadataPair> for ProviderMetadataPair {
    fn into_into_dart(self) -> Self {
        self
    }
}

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

/// cbindgen:ignore
#[cfg(target_family = "wasm")]
#[path = "bridge_generated.web.rs"]
mod web;
#[cfg(target_family = "wasm")]
pub use web::*;

#[cfg(not(target_family = "wasm"))]
#[path = "bridge_generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;
