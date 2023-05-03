# TODO

* [ ] MetadataCollecting: Disable 'Validate Metadatas' button if price field is empty
* [ ] AdEditing: Disable 'Mark as published' if the title is empty
* [ ] MetadataCollecting: Price auto fill
* [ ] BundleSelection: Automatically update bundle list when a bundle is removed or added by the app
* [ ] BundleSelection: Allow manual refresh if the bundle list has been modified by external device
* [ ] Launch the scrapping asynchronously to avoid waiting for the provider (notably BooksPrice)
* [ ] Camera: Grab the ISBN in real-time with ML Kit (add a minimum repetition of about 20 to avoid false ISBN detection)
* [ ] Search with Selenium in headless mode

# DONE

* [x] MetadataCollecting: Add back the keywords
* [x] MetadataCollecting: Create multiple textFieldController when multiple ISBN
* [x] Navigate between enrichment and camera
* [x] Compress the images to upload them quicker