# TODO

* [ ] Camera: check that detected barcode is a valid ISBN
* [ ] Camera: Play a sound when a picture is taken
* [ ] Camera: Play another sound when an ISBN is detected
* [ ] Camera: Add slider to change picture ratio
* [ ] Camera: Add padding in name so that lexical sorting correspond to numerical sorting
* [ ] Camera: Don't take first unused number
* [ ] Camera: Always show 'detect barcode' button. Show in disabled state the 'save' button if no picture has been taken
* [ ] Camera: Fix 'detect barcode' overlay stays visible when turned off
* [ ] Camera: Fix flashlight turning on and never off again
* [ ] MetadataCollecting: Show a visual indication that the title is too long (105 characters for LeBonCoin)
* [ ] BundleSelection: BundleList fail to refresh after autoMetadata download
* [ ] BundleSelection: BUG: BundleList show autoMetadata from other bundle when some bundle are deleted
* [ ] ISBNDecoding: Better layout for phone
* [ ] ISBNDecoding: Delete an image
* [ ] MetadataCollecting: Disable 'Validate Metadatas' button if price field is empty
* [ ] AdEditing: Disable 'Mark as published' if the title is empty
* [ ] Search with Selenium in headless mode

# DONE

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