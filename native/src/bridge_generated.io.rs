use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_detect_barcode_in_image(port_: i64, img_path: *mut wire_uint_8_list) {
    wire_detect_barcode_in_image_impl(port_, img_path)
}

#[no_mangle]
pub extern "C" fn wire_get_metadata_from_isbns(
    port_: i64,
    isbns: *mut wire_StringList,
    path: *mut wire_uint_8_list,
) {
    wire_get_metadata_from_isbns_impl(port_, isbns, path)
}

#[no_mangle]
pub extern "C" fn wire_get_auto_metadata_from_bundle(port_: i64, path: *mut wire_uint_8_list) {
    wire_get_auto_metadata_from_bundle_impl(port_, path)
}

#[no_mangle]
pub extern "C" fn wire_get_manual_metadata_for_bundle(
    port_: i64,
    bundle_path: *mut wire_uint_8_list,
) {
    wire_get_manual_metadata_for_bundle_impl(port_, bundle_path)
}

#[no_mangle]
pub extern "C" fn wire_set_manual_metadata_for_bundle(
    port_: i64,
    bundle_path: *mut wire_uint_8_list,
    bundle_metadata: *mut wire_BundleMetaData,
) {
    wire_set_manual_metadata_for_bundle_impl(port_, bundle_path, bundle_metadata)
}

#[no_mangle]
pub extern "C" fn wire_get_merged_metadata_for_bundle(
    port_: i64,
    bundle_path: *mut wire_uint_8_list,
) {
    wire_get_merged_metadata_for_bundle_impl(port_, bundle_path)
}

#[no_mangle]
pub extern "C" fn wire_get_metadata_from_provider(
    port_: i64,
    provider: i32,
    isbn: *mut wire_uint_8_list,
) {
    wire_get_metadata_from_provider_impl(port_, provider, isbn)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_StringList_0(len: i32) -> *mut wire_StringList {
    let wrap = wire_StringList {
        ptr: support::new_leak_vec_ptr(<*mut wire_uint_8_list>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_bundle_meta_data_0() -> *mut wire_BundleMetaData {
    support::new_leak_box_ptr(wire_BundleMetaData::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_i32_0(value: i32) -> *mut i32 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_item_state_0(value: i32) -> *mut i32 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_list_author_0(len: i32) -> *mut wire_list_author {
    let wrap = wire_list_author {
        ptr: support::new_leak_vec_ptr(<wire_Author>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_list_book_meta_data_0(len: i32) -> *mut wire_list_book_meta_data {
    let wrap = wire_list_book_meta_data {
        ptr: support::new_leak_vec_ptr(<wire_BookMetaData>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<Vec<String>> for *mut wire_StringList {
    fn wire2api(self) -> Vec<String> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<Author> for wire_Author {
    fn wire2api(self) -> Author {
        Author {
            first_name: self.first_name.wire2api(),
            last_name: self.last_name.wire2api(),
        }
    }
}
impl Wire2Api<BookMetaData> for wire_BookMetaData {
    fn wire2api(self) -> BookMetaData {
        BookMetaData {
            isbn: self.isbn.wire2api(),
            title: self.title.wire2api(),
            authors: self.authors.wire2api(),
            blurb: self.blurb.wire2api(),
            keywords: self.keywords.wire2api(),
            price_cent: self.price_cent.wire2api(),
        }
    }
}
impl Wire2Api<BundleMetaData> for *mut wire_BundleMetaData {
    fn wire2api(self) -> BundleMetaData {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<BundleMetaData>::wire2api(*wrap).into()
    }
}
impl Wire2Api<i32> for *mut i32 {
    fn wire2api(self) -> i32 {
        unsafe { *support::box_from_leak_ptr(self) }
    }
}
impl Wire2Api<ItemState> for *mut i32 {
    fn wire2api(self) -> ItemState {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<ItemState>::wire2api(*wrap).into()
    }
}
impl Wire2Api<BundleMetaData> for wire_BundleMetaData {
    fn wire2api(self) -> BundleMetaData {
        BundleMetaData {
            weight_grams: self.weight_grams.wire2api(),
            item_state: self.item_state.wire2api(),
            books: self.books.wire2api(),
        }
    }
}

impl Wire2Api<Vec<Author>> for *mut wire_list_author {
    fn wire2api(self) -> Vec<Author> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<Vec<BookMetaData>> for *mut wire_list_book_meta_data {
    fn wire2api(self) -> Vec<BookMetaData> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_StringList {
    ptr: *mut *mut wire_uint_8_list,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Author {
    first_name: *mut wire_uint_8_list,
    last_name: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_BookMetaData {
    isbn: *mut wire_uint_8_list,
    title: *mut wire_uint_8_list,
    authors: *mut wire_list_author,
    blurb: *mut wire_uint_8_list,
    keywords: *mut wire_StringList,
    price_cent: *mut i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_BundleMetaData {
    weight_grams: *mut i32,
    item_state: *mut i32,
    books: *mut wire_list_book_meta_data,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_author {
    ptr: *mut wire_Author,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_book_meta_data {
    ptr: *mut wire_BookMetaData,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_Author {
    fn new_with_null_ptr() -> Self {
        Self {
            first_name: core::ptr::null_mut(),
            last_name: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_Author {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_BookMetaData {
    fn new_with_null_ptr() -> Self {
        Self {
            isbn: core::ptr::null_mut(),
            title: core::ptr::null_mut(),
            authors: core::ptr::null_mut(),
            blurb: core::ptr::null_mut(),
            keywords: core::ptr::null_mut(),
            price_cent: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_BookMetaData {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_BundleMetaData {
    fn new_with_null_ptr() -> Self {
        Self {
            weight_grams: core::ptr::null_mut(),
            item_state: core::ptr::null_mut(),
            books: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_BundleMetaData {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
