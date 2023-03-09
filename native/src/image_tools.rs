use std::{path::Path, process::Command};

pub fn downsize_image(widht: u32, height: u32, input_filepath: &Path, output_filepath: &Path) {
    let output = Command::new("convert")
        .arg(input_filepath.to_str().unwrap())
        .arg("-resize")
        .arg(format!("{}x{}^>", widht, height))
        .arg(output_filepath.to_str().unwrap())
        .output()
        .unwrap();
    if output.status.success() {
        return;
    }
    println!("status: {}", output.status);
    println!("stdout: {:?}", &std::str::from_utf8(&output.stdout));
    println!("stderr: {:?}", &std::str::from_utf8(&output.stderr));

    assert!(output.status.success());
}
