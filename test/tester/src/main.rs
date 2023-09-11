use pretty_assertions::assert_eq;
use std::env;
use std::process::Command;
use std::time::Duration;
struct Output {
    stdout: String,
    stderr: String,
}

fn launch_command(cmd: &[&str], env: &[(&str, &str)]) -> Result<Output, std::process::ExitStatus> {
    println!("Launching command: {:?}", cmd);
    let c = cmd.split_first().unwrap();
    let process = Command::new(c.0)
        .envs(env.to_owned())
        .args(c.1)
        .output()
        .expect("Failed to execute command");
    if process.status.success() {
        return Ok(Output {
            stdout: String::from_utf8(process.stdout).unwrap(),
            stderr: String::from_utf8(process.stderr).unwrap(),
        });
    }
    println!("copy_mock_data_process returned {}", process.status);
    println!("stdout: {}", String::from_utf8(process.stdout).unwrap());
    println!("stderr: {}", String::from_utf8(process.stderr).unwrap());
    Err(process.status)
}

fn main() {
    let avds_name = env::args().skip(1);
    for avd_name in avds_name {
        println!("Launching test on device {avd_name}");

        // Check no emulators run
        let output = launch_command(
            &[
                "/home/julien/Android/Sdk/platform-tools/adb",
                "devices",
                "-l",
            ],
            &[],
        )
        .unwrap();
        let devices: Vec<&str> = output.stdout.lines().collect();
        // 2 lines mean no devices
        assert_eq!(devices.len(), 2);

        let mut command = Command::new("/home/julien/Android/Sdk/emulator/emulator");
        command.args(["-avd", &avd_name]);

        let avd_process = command.spawn();

        match avd_process {
            Err(e) => {
                println!("Could not launch avd. Error is {}", e);
                return;
            }
            Ok(mut child) => {
                println!("Command is running");
                std::thread::sleep(Duration::from_secs(20));
                let devices = launch_command(
                    &[
                        "/home/julien/Android/Sdk/platform-tools/adb",
                        "devices",
                        "-l",
                    ],
                    &[],
                )
                .unwrap()
                .stdout;
                println!("devices = {}", devices);

                launch_command(
                    &[
                        "adb",
                        "push",
                        "../../extra/mock_data/basic/",
                        "/storage/emulated/0/Android/data/fr.pimoid.booky.debug/files/",
                    ],
                    &[],
                )
                .unwrap();

                launch_command(
                    &[
                        "flutter",
                        "drive",
                        "--driver=test_driver/screenshot_test.dart",
                        "--target=integration_test/extended_test.dart",
                        "--browser-name",
                        "android-chrome", // "--device-id",
                                          // "emulator-5554",
                    ],
                    &[("screenshot_dir", &avd_name)],
                )
                .unwrap();

                println!("Killing");
                child.kill().expect("command wasn't running");
                std::thread::sleep(Duration::from_secs(3));
                println!("Avd {avd_name} shoud be off by now");
            }
        }
    }
}
