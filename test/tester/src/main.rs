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

fn emulator_cmd() -> Command {
    Command::new("/home/julien/Android/Sdk/emulator/emulator")
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let mut args = env::args();
    let arg0 = args.next().unwrap();
    let avds_name = args.into_iter();
    anyhow::ensure!(avds_name.len() > 0, "Usage: {} <avd names...>", arg0);

    let _obs = init_obs().await?;
    check_emulator_webcam()?;

    for (avd_index, avd_name) in avds_name.enumerate() {
        println!("Launching test on device {avd_name}");

        // Check no emulators run
        let output = launch_simple_command(&["adb", "devices", "-l"]).unwrap();
        let devices: Vec<&str> = output.stdout.lines().collect();
        // 2 lines mean no devices
        assert_eq!(
            devices.len(),
            2,
            "Some emulator are still running. {}",
            output.stdout
        );

        let avd_process = ProcessKillOnDrop {
            process: emulator_cmd().args(["-avd", &avd_name]).spawn()?,
        };

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
                    "--browser-name=android-chrome",
                    // On the first emulator, build the drive apk. On following run, reuse the same apk
                    if avd_index == 0 {"--flavor=drive"} else {"--use-application-binary=./build/app/outputs/flutter-apk/app-drive-debug.apk"},
                    
                ])
                .env("screenshot_dir", &avd_name),
        )
        .unwrap();

        println!("Killing android emulator");
        drop(avd_process);
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
            println!("Failed to kill PID {}. Error = {:?}", self.process.id(), e);
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

    std::thread::sleep(Duration::from_secs(2));
    let client = obws::Client::connect("localhost", 4455, env::var("OBS_PASSWORD").ok()).await?;
    client.virtual_cam().start().await.unwrap();
    std::thread::sleep(Duration::from_secs(2));

    Ok(obs)
}

fn check_emulator_webcam() -> anyhow::Result<()> {
    let output = launch_command(emulator_cmd().arg("-webcam-list")).unwrap();
    assert_eq!(
        output.stdout,
        "List of web cameras connected to the computer:
 Camera 'webcam0' is connected to device '/dev/video0' on channel 0 using pixel format 'YUYV'

",
"no camera found. You can try to launch 'v4l2-ctl --list-devices' and create a symlink named /etc/video0 pointing the video device of OBS",
    );

    Ok(())
}

fn copy_files_to_devices() -> () {
    for i in 1..20 {
        println!("Try number {i} to push file to device");

        // Just to check that the emulator is fully started
        let res = launch_simple_command(&["adb", "shell", "ls /storage/emulated/0/Android/data/"]);
        if res.is_ok() {
            let booky_dir = "/storage/emulated/0/Android/data/fr.pimoid.booky.drive.debug/";
            launch_simple_command(&["adb", "shell", &format!("rm -rf {booky_dir}/files/")])
                .unwrap();
            launch_simple_command(&["adb", "shell", &format!("mkdir -p {booky_dir}")]).unwrap();

            launch_simple_command(&[
                "adb",
                "push",
                "../../extra/mock_data/basic/",
                &format!("{booky_dir}/files"),
            ])
            .unwrap();

            return ();
        }

        std::thread::sleep(Duration::from_secs(5));
    }

    panic!("Failed to copy after multiple tries")
}
