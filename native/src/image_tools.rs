use std::{path::Path, process::Command};

pub fn downsize_image(widht: u32, height: u32, input_filepath: &Path, output_filepath: &Path) {
    Command::new("convert")
        .arg(input_filepath.to_str().unwrap())
        .arg("-resize")
        .arg(format!("{}x{}^>", widht, height))
        .arg(output_filepath.to_str().unwrap())
        .output()
        .unwrap();
}
