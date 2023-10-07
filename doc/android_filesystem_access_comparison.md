# Android filesystem access methods comparison

Booky on computer needs to access the bundles take by the smartphone. Instead of copy all the bundle to the computers, it is simpler to access them directly on the smartphone to have a single source of truth.  
The ideal solution would be to mount the smartphone as a USB Mass Storage device.
However,  recent version of android do not support mounting as USB Mass Storage anymore. Recent Android restrict access through MTP which is very inconvenient to work with.

Here are different different method to access the smartphone filesystem, with their pro and cons.

## Mount by MTP with pcmanfm
* You need to open pcmanfm (GUI), click on "Allow" on the android device, then the first few directory access fail
* Opening text and image files works fast
* Creating a file directly on the phone does not work. You need to create it locally then move it with 'gio move'
* `mv` do not work
* Moving a remote file with 'gio rename' or `gio move` is buggy.  
`ls` or `gio list` do not show the old file anymore but show 2 files having the new name
* `rm` leave the file visible by `ls` but is empty until you unplug/plug the phone

## Mount via go-mtpfs
* Launch `go-mtpfs <mount point>`, click on "Allow" on the android device
* We can see all file inside 'Internal Storage', but not its parent
* Creating with `touch` faild
* Creating with `echo 'xx' > dst` works but is very slow (5s)
* Copying a file is very slow (5s)
* Writing with vim is also very slow and does not work
* Moving a file works
* `rm` works

## FTP server
* :warning: FTP is not secure
* Connect phone and computer to the same local network, launch an FTP server from Android, then access it `ftp <address>`
* Files in 'Internal Storage' are visible but not the one in Android/data
* Creating, moving and removing file seems to works fast

## Mount with ADBfs-rootless
[https://github.com/spion/adbfs-rootless](https://github.com/spion/adbfs-rootless)

* launch `./adbfs <mount point>`, no need to click anything on the phone
* We can see all system file inside the phone
* Creating file works fast
* `mv` works fast
* `rm` works fast
* Seem a bit slower at reading than go-mtpfs or pcmanfm
* Is way slower for some command, for example a grep take 40s with adbfs, and only 0.4s with `adb shell`
