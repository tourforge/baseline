# OpenTourGuide
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/opentourbuilder/guide/android.yml?branch=main&label=Android%20build&style=for-the-badge)](https://github.com/opentourbuilder/guide/actions/workflows/android.yml)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/opentourbuilder/guide/ios.yml?branch=main&label=iOS%20build&style=for-the-badge)](https://github.com/opentourbuilder/guide/actions/workflows/ios.yml)

OpenTourGuide is a rebrandable GPS-guided tour app for Android and iOS, built using Flutter. This repository holds the generic, unbranded code, packaged as a Flutter library. You'll also find a very simple example application, used for testing purposes, under the `example/` directory that uses the API of this library in the simplest manner possible. [Florence Navigator](https://github.com/opentourbuilder/florence-navigator) is a more complete application that uses OpenTourGuide.

If you want to create your own tour guide app, follow [our guide](https://github.com/opentourbuilder/documentation/blob/main/Creating%20an%20app.md).

## Development setup

In order for the satellite imagery feature to work, you need to create a file under `example/assets/` called `tomtom.txt` and paste a TomTom API key into this file. Make sure you don't put a newline at the end of this file; otherwise, the API key won't be read properly.

### iOS-specific instructions
We've had to use a workaround on iOS due to difficulties with installing the MapLibre dependency via CocoaPods. Before you open the project in Xcode, follow these steps:

1. Download the MapLibre iOS SDK; this is a zip file.
   
   You can either download the latest version from their [Releases page](https://github.com/maplibre/maplibre-native/releases), or you can download [v5.13.0](https://github.com/maplibre/maplibre-native/releases/tag/ios-v5.13.0), which is the version that had most recently been tested as working the last time this README was updated.
2. Extract the zip somewhere convenient so that you can access its internal files.
3. Find the directory titled `Mapbox.framework` under `Mapbox.xcframework/ios-arm64/Mapbox.framework`.
4. Copy the `Mapbox.framework` directory to `example/ios/Mapbox.framework`.
5. Now you're free to open the project in Xcode. Make sure you open `example/ios/Runner.xcworkspace`, not ~~`example/ios/Runner.xcodeproj`~~.
6. When it's time to archive the app to submit it to the app store, and until https://github.com/CocoaPods/CocoaPods/issues/11808 is fixed, follow the temporary solution in the thread to successfully archive the app.

It is important to note that our current workaround does not allow running the app in a simulator. You will need a physical device in order to run the application.
