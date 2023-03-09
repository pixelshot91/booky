use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_get_metadata_from_images(port_: i64, imgs_path: *mut wire_StringList) {
    wire_get_metadata_from_images_impl(port_, imgs_path)
}

#[no_mangle]
pub extern "C" fn wire_publish_ad(port_: i64, ad: *mut wire_Ad) {
    wire_publish_ad_impl(port_, ad)
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
pub extern "C" fn new_box_autoadd_ad_0() -> *mut wire_Ad {
    support::new_leak_box_ptr(wire_Ad::new_with_null_ptr())
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
impl Wire2Api<Ad> for wire_Ad {
    fn wire2api(self) -> Ad {
        Ad {
            title: self.title.wire2api(),
            description: self.description.wire2api(),
            price_cent: self.price_cent.wire2api(),
            imgs_path: self.imgs_path.wire2api(),
        }
    }
}
impl Wire2Api<Ad> for *mut wire_Ad {
    fn wire2api(self) -> Ad {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<Ad>::wire2api(*wrap).into()
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
pub struct wire_Ad {
    title: *mut wire_uint_8_list,
    description: *mut wire_uint_8_list,
    price_cent: i32,
    imgs_path: *mut wire_StringList,
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

impl NewWithNullPtr for wire_Ad {
    fn new_with_null_ptr() -> Self {
        Self {
            title: core::ptr::null_mut(),
            description: core::ptr::null_mut(),
            price_cent: Default::default(),
            imgs_path: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_Ad {
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
