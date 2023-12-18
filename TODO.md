# TODO

* [ ] App-wide: Use an animated splash screen
* [ ] App-wide: Preserve the splash screen to hide the creation of the main dirs
* [ ] App-wide: Better handle nonexistent or incorrect metadata file instead of throwing an exception
* [ ] Device Mounting: mount the phone from the app
* [ ] Device Mounting: Trigger a refresh when a new Android device is connected
* [ ] Device Mounting: Mount only the right folder to be sure not to mess with other app data, or even Android (look into libfuse --subdir option)
* [ ] Camera: LiveDetection: show confirmed barcode and pending barcodes in different color. Show a progressBar for the pending barcode
* [ ] Camera: Reduce latency when cropping picture
* [ ] Camera: Add sound when deleting a picture
* [ ] Camera: Fix flashlight turning on and never off again
* [ ] Camera: Camera is still in use when going back to BundleSelection, and even when going to the home screen
* [ ] BundleSelection: Add filter by auto_metadata downloaded or not
* [ ] BundleSelection: Add sort by date picture taken, date published, price
* [ ] BundleSelection: Add ability to go back into Camera mode to add/delete picture/ISBN, change the weight/state
* [ ] BundleSelection: BundleList does not refresh after autoMetadata download nor MetadataCollecting manual validation
* [ ] BundleSelection: BUG: BundleList show autoMetadata from other bundle when some bundle are deleted
* [ ] BundleSelection: Progress bar for 'Download metadata for all bundles' does not reach the end (Probably a race condition)
* [ ] BundleSelection: Suggest bundle grouping by same author, title, keyword
* [ ] ISBNDecoding: Better layout for phone
* [ ] ISBNDecoding: Delete an image
* [ ] ISBN: Add character 'X' in ISBN keyboard
* [ ] MetadataCollecting: Disable 'Validate Metadatas' button if price field is empty
* [ ] MetadataCollecting: Show a visual indication that the title is too long (105 characters for LeBonCoin)
* [ ] AdEditing: Disable 'Mark as published' if the title is empty
* [ ] AdEditing: Save the ad as it was published
* [ ] AdEditing: Fix drag-and-drop crash on Android (See <https://developer.android.com/training/secure-file-sharing)>
* [ ] Search with Selenium in headless mode
* [ ] Test: Launch github action runner without opening graphical interface (use -no-boot-anim  -no-window)
* [ ] Test: CI show false success when a step with continue-on-error fails
* [ ] Test: CI save screenshots as artifact and compare them with the one in extra/screenshots/ to check for regression
* [ ] Test: Unify real device and emulator test target. It should append the date to the directory name to avoid having multiple test image in the same directory

# DONE

* [x] BundleSelection: Make image load faster. Differentiate thumbnail and image to export
* [x] Test: Automatically kill the emulator process on exit with KillProcessOnDrop
* [x] Device Mounting: On Linux, on app start-up, the app create the directory even if the phone is not mounted
* [x] BundleSelection: Fix 'See in list' regression where the focus bundle is not the correct one
* [x] Test: CI: Prevent running the CI twice: on pull-request, then on push. See https://github.com/marketplace/actions/skip-duplicate-actions
* [x] Camera: Fix pictures flickering or being shortly replaced by a spinner each time a picture is taken
* [x] BundleSelection: Speed up search bar on Linux: getMergedMetadata seems to be slowed by the maximum Rust thread limit
* [x] BundleSelection: Speed up search bar on Linux: getMergedMetadata is called for all bundle only once
* [x] Camera: Fix display of cached deleted picture (take a picture, delete it, take another picture, the first picture is shown)
* [x] BundleSelection: Show already published bundles
* [x] App-wide: Fix ScrollShadow showing shadow in direction perpendicular to scrolling
* [x] Technical: Pin version in pubspec.yaml and Cargo.toml because some packages in both language do not respect SemVer
* [x] Fix ScrollShadow only showing after first scrolling
* [x] BundleSelection: Add search by ISBN, title, author
* [x] Add CI that check Flutter and Rust code, and launch flutter test
* [x] MetadataCollecting: Show images on the side with zoom on click
* [x] Use a scroll indicator to show that more content is available by scrolling
* [x] Camera: Add slider to change picture ratio
* [x] BundleSelection: Add an Undo button in the Snackbar when deleting a bundle
* [x] BundleSelection: Keep scroll position when deleting a bundle
* [x] Camera: Fix bug where new image does not take the last place. Rename all the picture ofter the deleted one so that there is no gap in the numbering
* [x] Camera: Add padding in name so that lexical sorting correspond to numerical sorting
* [x] Camera: Always show bottom buttons
* [x] Camera: Play another sound when an ISBN is detected
* [x] Camera: Fix 'detect barcode' overlay stays visible when turned off
* [x] Camera: Play a sound when a picture is taken
* [x] Camera: Handle taken images visual overflow
* [x] ISBNDecoding: Pan and zoom on an image
* [x] ISBNDecoding: Check the ISBN checksum
* [x] Add the ISBNs in the ad description for better indexing
* [x] Show LBC weight category instead of weight in grams
* [x] Better price suggestion. Take into account shipping cost
* [x] BundleSelection: Delete some bundle
* [x] BundleSelection: Show icons to represent how much metadata is available
* [x] ISBNDecoding: Show barcode zone, add and remove barcode 
* [x] BundleSelection: Automatically update bundle list when a bundle is removed or added by the app
* [x] BundleSelection: Allow manual refresh if the bundle list has been modified by external device
* [x] Launch the scrapping asynchronously to avoid waiting for the provider (notably BooksPrice)
* [x] Camera: Grab the ISBN in real-time with ML Kit (add a minimum repetition of about 20 to avoid false ISBN detection)
* [x] MetadataCollecting: Price auto fill
* [x] MetadataCollecting: Add back the keywords
* [x] MetadataCollecting: Create multiple textFieldController when multiple ISBN
* [x] Navigate between enrichment and camera
* [x] Compress the images to upload them quicker