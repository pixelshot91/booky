use pretty_assertions::assert_eq;
use std::env;
use std::process::Command;
use std::time::Duration;

struct Output {
    stdout: String,
    stderr: String,
}

fn launch_simple_command(cmd: &[&str]) -> Result<Output, std::process::ExitStatus> {
    let c = cmd.split_first().unwrap();
    launch_command(Command::new(c.0).args(c.1))
}

fn launch_command(cmd: &mut std::process::Command) -> Result<Output, std::process::ExitStatus> {
    println!("Launching command: {:?}", cmd);
    let process = cmd.output().expect("Failed to execute command");
    if process.status.success() {
        return Ok(Output {
            stdout: String::from_utf8(process.stdout).unwrap(),
            stderr: String::from_utf8(process.stderr).unwrap(),
        });
    }
    println!("cmd '{:?}' returned {}", cmd, process.status);
    println!("stdout: {}", String::from_utf8(process.stdout).unwrap());
    println!("stderr: {}", String::from_utf8(process.stderr).unwrap());
    Err(process.status)
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _obs = init_obs().await?;

    let avds_name = env::args().skip(1);
    for avd_name in avds_name {
        println!("Launching test on device {avd_name}");

        // Check no emulators run
        let output = launch_simple_command(&["adb", "devices", "-l"]).unwrap();
        let devices: Vec<&str> = output.stdout.lines().collect();
        // 2 lines mean no devices
        assert_eq!(devices.len(), 2);

        let mut command = Command::new("/home/julien/Android/Sdk/emulator/emulator");
        command.args(["-avd", &avd_name]);

        let mut avd_process = command.spawn()?;

        println!("Command is running");
        std::thread::sleep(Duration::from_secs(1));
        let devices = launch_simple_command(&["adb", "devices", "-l"])
            .unwrap()
            .stdout;
        println!("devices = {}", devices);

        copy_files_to_devices();

        launch_command(
            Command::new("flutter")
                .args([
                    "drive",
                    "--driver=test_driver/screenshot_test.dart",
                    "--target=integration_test/extended_test.dart",
                    "--browser-name",
                    "android-chrome", // "--device-id",
                                      // "emulator-5554",
                ])
                .env("screenshot_dir", &avd_name),
        )
        .unwrap();

        println!("Killing");
        avd_process.kill().expect("command wasn't running");
        std::thread::sleep(Duration::from_secs(3));
        println!("Avd {avd_name} shoud be off by now");
    }
    Ok(())
}

struct ProcessKillOnDrop {
    process: std::process::Child,
}

impl Drop for ProcessKillOnDrop {
    fn drop(&mut self) {
        let kill_result = self.process.kill();
        if let Err(e) = kill_result {
            println!("kill obs failed. Error = {:?}", e);
        }
    }
}

// Return the OBS process
async fn init_obs() -> anyhow::Result<ProcessKillOnDrop> {
    let archive_name = "/tmp/obs_archive.zip";
    launch_command(
        Command::new("zip")
            .current_dir("../../extra/obs_scenes/basic")
            .args(["-r", "-D", archive_name, "assets/", "scene-collection.json"]),
    )
    .expect("Can't zip obs scene");
    launch_command(
        Command::new("/home/julien/.venv/bin/obs-scene-transporter").args(["import", archive_name]),
    )
    .unwrap();
    let obs = ProcessKillOnDrop {
        process: Command::new("obs").spawn().unwrap(),
    };

    std::thread::sleep(Duration::from_secs(5));
    let client = obws::Client::connect("localhost", 4455, env::var("OBS_PASSWORD").ok()).await?;
    client.virtual_cam().start().await.unwrap();

    Ok(obs)
}

fn copy_files_to_devices() -> () {
    for i in 1..20 {
        println!("Try number {i} to push file to device");

        // Just to check that the emulator is fully started
        let res = launch_simple_command(&["adb", "shell", "ls /storage/emulated/0/Android/data/"]);
        if res.is_ok() {
            launch_simple_command(&[
                "adb",
                "shell",
                "rm -rf /storage/emulated/0/Android/data/fr.pimoid.booky.debug/files/",
            ])
            .unwrap();
            launch_simple_command(&[
                "adb",
                "shell",
                "mkdir -p /storage/emulated/0/Android/data/fr.pimoid.booky.debug/",
            ])
            .unwrap();

            launch_simple_command(&[
                "adb",
                "push",
                "../../extra/mock_data/basic/",
                "/storage/emulated/0/Android/data/fr.pimoid.booky.debug/files/",
            ])
            .unwrap();

            let list = launch_simple_command(&[
                "adb",
                "shell",
                "ls /storage/emulated/0/Android/data/fr.pimoid.booky.debug/files",
            ])
            .unwrap()
            .stdout;
            println!("ls returned: {list}");
            return ();
        }

        std::thread::sleep(Duration::from_secs(5));
    }

    panic!("Failed to copy after multiple tries")
}
