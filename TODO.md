# TODO

* [ ] ISBNDecoding: Check the ISBN checksum
* [ ] Add the ISBNs in the ad description for better indexing
* [ ] Show LBC weight category instead of weight in grams
* [ ] BUG: BundleList fail to refresh after: autoMetadata download
* [ ] BUG: BundleList show autoMetadata from other bundle when some bundle are deleted
* [ ] MetadataCollecting: Disable 'Validate Metadatas' button if price field is empty
* [ ] AdEditing: Disable 'Mark as published' if the title is empty
* [ ] Search with Selenium in headless mode

# DONE

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