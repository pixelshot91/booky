# Booky

Booky is an application to help publish second-hand book.
It enable taking multiple picture of the book(s). Add books state (brand new, worn out), add the weight (for shipping), then extract the ISBN from the barcode in the pictures to find the books metadata.

It is then very easy to create a compelling ad to sell your book.

<p align="center">
<img alt="screenshot of Booky homescreen" src="doc/images/bunle_selection.webp" width=30%>
</p>

## Enrichment
Booky will scrape various websites to find metadata like:
- Title
- Author
- Blurb. A book blurb is a short promotional description, whereas a synopsis summarizes the twists, turns, and conclusion of the story.
- Keywords or genres

### Example using Babelio as source
#### Input

```rust
let isbn = 9782266071529;
```

#### Output
```rust
BookMetaData {
  title: "Le nom de la bête",
  author: {
    surname: "Daniel",
    name: "Easterman",
  },
  blurb: "Janvier 1999. Peu à peu, les pays arabes ont sombré dans l'intégrisme. Les attentats terroristes se multiplient en Europe attisant la haine et le racisme. Au Caire, un coup d'état fomenté par les fondamentalistes permet à leur chef Al-Kourtoubi de s'installer au pouvoir et d'instaurer la terreur. Le réseau des agents secrets britanniques en Égypte ayant été anéanti, Michael Hunt est obligé de reprendre du service pour enquêter sur place. Aidé par son frère Paul, prêtre catholique et agent du Vatican, il apprend que le Pape doit se rendre à Jérusalem pour participer à une conférence œcuménique. Au courant de ce projet, le chef des fondamentalistes a prévu d'enlever le saint père.Dans ce récit efficace et à l'action soutenue, le héros lutte presque seul contre des groupes fanatiques puissants et sans grand espoir de réussir. Comme dans tous ses autres livres, Daniel Easterman, spécialiste de l'islam, part du constat que le Mal est puissant et il dénonce l'intolérance et les nationalismes qui engendrent violence et chaos.--Claude Mesplède<br>\t\t",
  key_words: [
    "roman", "fantastique", "policier historique", "romans policiers et polars", "thriller", "terreur", "action", "démocratie", "mystique", "islam", "intégrisme religieux", "catholicisme", "religion", "terrorisme", "extrémisme", "egypte", "médias", "thriller religieux", "littérature irlandaise", "irlande"
  ],
}
```

### Sources

| Source                                                | Metadata (in addition to title and authors) | Notes                                                                                                                                                                                                                       |
|-------------------------------------------------------|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Babelio](https://www.babelio.com/)                   | blurb, keyword                             | No API available. No plan to build one.<br/>Babelio seem to block the IP if it detect this bot is doing some scrapping                                                                                                      |
| [Decitre](https://www.decitre.fr/)                    | blurb, keywords in commentaries            |                                                                                                                                                                                                                             |
| [GoodReads](https://www.goodreads.com/)               | blurb, genres in english                   | An API was available, but GoodRead does not create new developer key. [See this](https://help.goodreads.com/s/article/Does-Goodreads-support-the-use-of-APIs)                                                               |
| [Google Books](https://www.google.fr/books/)          | blurb, genres                              | [A real API](https://developers.google.com/books/docs/overview) is available to look up a book by ISBN <br/> Some book can't be search by ISBN, even though a search by title can find them, and they display the right ISBN |
| [ISBSearcher](https://www.isbnsearcher.com/)          | blurb, main category in english            |                                                                                                                                                                                                                             |
| [Label Emmaus](https://www.label-emmaus.co/)          | blurb, genres                              |                                                                                                                                                                                                                             |
| [OpenLibrary](https://openlibrary.org/)               | blurb are not translated                   | Its is based on physical books, it is not really a book database                                                                                                                                                            |
| [Chasse Aux Livre](https://www.chasse-aux-livres.fr/) | price only                                 | it is not possible to parse with Selenium                                                                                                                                                                                   |
| [AbeBooks](https://www.abebooks.fr/)                  | Seems to have good french blurb            |                                                                                                                                                                                                                             |
| [Fnac](https://www.fnac.com/)                         | blurb, second-hand price                   |                                                                                                                                                                                                                             |
| [Librarie Kleber](https://www.librairie-kleber.com/)  | blurb, price                               |                                                                                                                                                                                                                             |
| [JustBooks](https://www.justbooks.fr/)                | blurb (seldom), prices                     |                                                                                                                                                                                                                             |

#### GoogleBooks
GoogleBooks has some inconsistencies:
https://www.googleapis.com/books/v1/volumes?q=isbn:9782744170812
says te publishedDate is 2004.
But https://www.googleapis.com/books/v1/volumes/DQUFSQAACAAJ
says the publishedDate is 2005.

In the first response, we don't have a publisher, in the second we have.
In the first response, the title use a big C for "Cité", but in the second, it use a small 'c'

## Contributing
### Build the barcode detector binary
Clone the 3 OpenCV repo:
- https://github.com/opencv/opencv.git (main repo)
- https://github.com/pixelshot91/open_cv_barcode_book_metadata_finder  
  (fork of https://github.com/opencv/opencv_contrib.git)  
  Contain the barcode contrib module
- https://github.com/opencv/opencv_extra.git (optionnal, contain the test data to test OpenCV)

```shell
$ cd <open_cv>/
$ mkdir build
$ cd build/
build/ $ cmake -DOPENCV_EXTRA_MODULES_PATH=<opencv_contrib>/modules ..
```

You can test the barcode module with:
```shell
build/ $ make opencv_test_barcode
build/ $ OPENCV_TEST_DATA_PATH=<opencv_extra>/testdata/ bin/opencv_test_barcode
```

### Install the rust/android toolchain
#### flutter_rust_bridge_template
Follow the instruction of flutter_rust_bridge_template. Here is an extract

> To begin, ensure that you have a working installation of the following items:
> - [Flutter SDK](https://docs.flutter.dev/get-started/install)
> - [Rust language](https://rustup.rs/)
> - `flutter_rust_bridge_codegen` [cargo package](https://cjycode.com/flutter_rust_bridge/integrate/deps.html#build-time-dependencies)
> - Appropriate [Rust targets](https://rust-lang.github.io/rustup/cross-compilation.html) for cross-compiling to your device
> - For Android targets:
>     - Install [cargo-ndk](https://github.com/bbqsrc/cargo-ndk#installing)
>     - Install [Android NDK 22](https://github.com/android/ndk/wiki/Unsupported-Downloads#r22b), then put its path in one of the `gradle.properties`, e.g.:
> 
> ```
> echo "ANDROID_NDK=.." >> ~/.gradle/gradle.properties
> ```

#### super_native_extension
Follow this tutorial: https://pub.dev/packages/super_clipboard

### Run the flutter application
#### On an android device
Connect your phone.  
Use
```
flutter run --flavor nodrive
```
If you don't specify a flavor, flutter will output this error:
```
Exception: Gradle build failed to produce an .apk file. It's likely that this file was generated under /Users/pattobrien/dev/fine_designs/template/src/frontend/build, but the tool couldn't find it.
```
(See <https://github.com/flutter/flutter/issues/22856> for issue about this cryptic message and the use of default flavor)

#### On Linux
First connect your phonem then mount its content on /media/phone.  
You can mount your phone with [adbfs-rootless](https://github.com/spion/adbfs-rootless)
```
$ ./adbfs /media/phone/
$ ls /media/phone
... storage/ ... 
```

Then launch Booky with:
```
$ flutter run --flavor noDrive -d linux
```

### Launching the test suite
#### OBS
##### Setup of Virtual camera
OBS home page: <https://obsproject.com/>

Some test require to simulate a camera. Booky use OBS virtual camera to mock the real camera.
OBS virtual camera need v4l2loopback module which may not be enabled.

If it is not enabled, you should see this log when launching OBS:
```
warning: v4l2loopback not installed, virtual camera disabled
```
And the button `Start virutal camera` will not appear.

To enable it, run
```shell
sudo modprobe v4l2loopback
```
and relaunch OBS.

###### Setup of android emulator

In the Android Virtual Device settings, select "webcam0" for both front and back camera

The android camera app will always rash, but Booky should work fine.

If in Booky the camera list is empty, stop OBS virtual cam, then execute:
```
echo "options v4l2loopback devices=1 video_nr=63 card_label='OBS Virtual Camera'    exclusive_caps=1" | sudo tee /etc/modprobe.d/v4l2loopback.conf
echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback devices=63 video_nr=13 card_label='OBS Virtual Camera' exclusive_caps=1
```

then restart virtual cam and cold boot the emulator.

###### Importing scene
OBS does not provide a convenient way to create portable scene, because all scene contain absolute path to the sources.
To be able to use relative path, Booky use OBS Scene Transporter.
<https://github.com/pixelshot91/obs-scene-transporter>

# License
[Icon by Freepik](https://www.freepik.com/icon/books_562132)
