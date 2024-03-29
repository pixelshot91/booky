use anyhow::Context;

pub enum MyFileOpenRes {
    Ok(std::fs::File),
    NoFile,
}

// std::fs::File::open does not indicate the filename in case of error
// This function add the path as context
pub fn my_file_open<P: AsRef<std::path::Path> + std::fmt::Debug>(
    path: P,
) -> anyhow::Result<MyFileOpenRes> {
    match std::fs::File::open(&path) {
        Err(e) => {
            if e.kind() == std::io::ErrorKind::NotFound {
                return Ok(MyFileOpenRes::NoFile);
            }
            return Err(e).context(format!("Error when trying to open file {:#?}", path));
        }
        Ok(file) => return Ok(MyFileOpenRes::Ok(file)),
    }
}

pub fn my_read_to_string<P: AsRef<std::path::Path> + std::fmt::Debug>(
    path: P,
) -> anyhow::Result<String> {
    std::fs::read_to_string(&path).context(format!(
        "Error when trying to read_to_string file {:#?}",
        path
    ))
}
