# TourForge
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/tourforge/guide/android.yml?branch=main&label=Android%20build&style=for-the-badge)](https://github.com/tourforge/guide/actions/workflows/android.yml)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/tourforge/guide/ios.yml?branch=main&label=iOS%20build&style=for-the-badge)](https://github.com/tourforge/guide/actions/workflows/ios.yml)

TourForge is a rebrandable GPS-guided tour app for Android and iOS, built using Flutter. This repository holds the generic, unbranded code, packaged as a Flutter library. You'll also find a sample application, used for testing purposes, under the `example/` directory. [Florence Navigator](https://github.com/tourforge/florence-navigator) is TourForge's flagship application.

If you want to create your own tour guide app, follow [our guide](https://github.com/tourforge/documentation/blob/main/Creating%20an%20app.md).

## First-Time Development Setup

In order for the satellite imagery feature to work, you need to create a file under `example/assets/` called `tomtom.txt` and paste a TomTom API key into this file.

### iOS-Specific Setup
We've had to use a workaround on iOS due to difficulties with installing the MapLibre dependency via CocoaPods. Before you open the project for the first time in Xcode, follow these steps:

1. Download the MapLibre iOS SDK; this is a zip file.
   
   You can either download the latest version from their [Releases page](https://github.com/maplibre/maplibre-native/releases), or you can download [v5.13.0](https://github.com/maplibre/maplibre-native/releases/tag/ios-v5.13.0), which is the version that had most recently been tested as working the last time this README was updated.
2. Extract the zip somewhere convenient so that you can access its internal files.
3. Find the directory titled `Mapbox.framework` under `Mapbox.xcframework/ios-arm64/Mapbox.framework`.
4. Copy the `Mapbox.framework` directory to `example/ios/Mapbox.framework`.
- It is important to note that in order to run the app in a simulator, you need to copy `ios-arm64_x86_64-simulator` folder instead.
5. Open a terminal in `example/ios`, run `flutter pub get && pod install`.

Now you're free to open the project in Xcode. Make sure you open `example/ios/Runner.xcworkspace`, not ~~`example/ios/Runner.xcodeproj`~~.

### Android-Specific Setup

Open a terminal in the project directory and run `flutter pub get`.

## Running the App on Physical Device

### iOS

With Xcode open, follow this documentation (https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device#Connect-real-devices-to-your-Mac).

### Android

- Connect the Android device to the development machine with an appropriate USB cable.
  - If this is the first time, tap `Allow` when you see the `Allow USB debugging?` box.
- Open the Android Studio terminal and run `flutter run`.

## Running the App on Virtual Device

### iOS

With Xcode open, follow this documentation (https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device#Configure-the-list-of-simulated-devices).

### Android

- Initialize your desired system image and device here (https://developer.android.com/studio/run/managing-avds).
  - If this is the first time, tap `Allow` when you see the `Allow USB debugging?` box.
- Open the Android Studio terminal and run `flutter run`.
- You may need to get the device ID, obtainable via command `flutter emulators`.

## Building Release Distributables

### iOS Archive Instructions

To build an app archive and upload to Apple, follow these sections at (https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases#Create-an-archive-of-your-app):
- `Create an archive of your app`
    - If you are creating an archive for the first time, follow the temporary solution in the thread (https://github.com/CocoaPods/CocoaPods/issues/11808) to successfully archive the app, then restart Xcode. 
- `Select a method for distribution`
    - Select `TestFlight & App Store`; this will also upload the archive directly to Apple.

### Android Build Signed Bundle Instructions

When creating a signed release bundle for the first time, you must follow this documentation (https://docs.flutter.dev/deployment/android#create-an-upload-keystore). Take note on a couple of things:
1. You may need to install the JDK for the generating keystore command to work.
2. It is going to ask a couple of identifying questions, but it doesn't matter how you answer them.
3. Remember to save the password and the location for the keystore.
4. Insert the password and keystore location in the `key.properties` file and move the file into the `android/` directory.
5. You can now create a signed bundle by running the following command: `flutter build appbundle`.
6. The signed bundle can be found in `build/app/outputs/bundle/release/app.aab`.

You only need to do this once. After that, any time that you need to build new bundle, simply re-run the command `flutter build appbundle`. You may now upload this signed bundle to the Google Play Console.
