# OpenTourGuide
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/opentourbuilder/guide/android.yml?branch=main&label=Android%20build&style=for-the-badge)](https://github.com/opentourbuilder/guide/actions/workflows/android.yml)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/opentourbuilder/guide/ios.yml?branch=main&label=iOS%20build&style=for-the-badge)](https://github.com/opentourbuilder/guide/actions/workflows/ios.yml)

OpenTourGuide is a rebrandable GPS-guided tour app for Android and iOS, built using Flutter. This repository holds the generic, unbranded code, packaged as a Flutter library. You'll also find a very simple example application, used for testing purposes, under the `example/` directory that uses the API of this library in the simplest manner possible. [Florence Navigator](https://github.com/opentourbuilder/florence-navigator) is a more complete application that uses OpenTourGuide.

If you want to create your own tour guide app, follow [our guide](https://github.com/opentourbuilder/documentation/blob/main/Creating%20an%20app.md).

## First-time Development Setup

In order for the satellite imagery feature to work, you need to create a file under `example/assets/` called `tomtom.txt` and paste a TomTom API key into this file.

### iOS-specific Setup
We've had to use a workaround on iOS due to difficulties with installing the MapLibre dependency via CocoaPods. Before you open the project for the first time in Xcode, follow these steps:

1. Download the MapLibre iOS SDK; this is a zip file.
   
   You can either download the latest version from their [Releases page](https://github.com/maplibre/maplibre-native/releases), or you can download [v5.13.0](https://github.com/maplibre/maplibre-native/releases/tag/ios-v5.13.0), which is the version that had most recently been tested as working the last time this README was updated.
2. Extract the zip somewhere convenient so that you can access its internal files.
3. Find the directory titled `Mapbox.framework` under `Mapbox.xcframework/ios-arm64/Mapbox.framework`.
4. Copy the `Mapbox.framework` directory to `example/ios/Mapbox.framework`.
5. Open a terminal in `example/ios`, run `pod install && flutter pub get`.

Now you're free to open the project in Xcode. Make sure you open `example/ios/Runner.xcworkspace`, not ~~`example/ios/Runner.xcodeproj`~~. It is important to note that our current workaround does not allow running the app in a simulator. You will need a physical device in order to run the application.

### Android-specific Setup

Open a terminal in project directory and run `flutter pub get`.

## Building Release Distributables

### iOS Archive Instruction

To build an app archive and upload to Apple, follow these sections at (https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases#Create-an-archive-of-your-app):
- `Create an archive of your app`
    - If you are creating an archive for the first time, follow the temporary solution in the thread (https://github.com/CocoaPods/CocoaPods/issues/11808) to successfully archive the app, then restart Xcode IDE. 
- `Select a method for distribution`
    - Select `TestFlight & App Store`, this will also upload the archive directly to Apple.

### Android Build Signed Bundle Instruction

When creating a signed release bundle for the first time, you must follow this documentation (https://docs.flutter.dev/deployment/android#create-an-upload-keystore). Take note on a couple of things:
1. You may need to install JDK for the generating keystore command to work.
2. It is going to ask a couple of identifying questions, doesn't matter how you answer it.
3. Remember and save the password and the location for the keystore.
4. Insert passwords and keystore location in the `key.properties` file and move it into `android/` directory.
5. You can now create signed bundle by running the following command `flutter build appbundle`.
6. Locate this signed bundle in `build/app/outputs/bundle/release/app.aab`.

You only need to do this once. After that, anytime that you need to build new bundle, simply rerun the command `flutter build appbundle`. You may now upload this signed bundle to Google Play Console.
