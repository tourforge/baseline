# OpenTourGuide
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/opentourbuilder/guide/Android%20CI?label=Android%20build&style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/opentourbuilder/guide/iOS%20CI?label=iOS%20build&style=for-the-badge)

## iOS-specific setup

We've had to use a workaround due to difficulties with installing the MapLibre dependency via CocoaPods. Before you open the project in Xcode, follow these steps:

1. Download the MapLibre iOS SDK; this is a zip file.
   
   You can either download the latest version from their [Releases page](https://github.com/maplibre/maplibre-native/releases), or you can download [v5.13.0](https://github.com/maplibre/maplibre-native/releases/tag/ios-v5.13.0), which is the version that had most recently been tested as working the last time this README was updated.
2. Extract the zip somewhere convenient so that you can access its internal files.
3. Find the directory titled `Mapbox.framework` under `Mapbox.xcframework/ios-arm64/Mapbox.framework`.
4. Copy the `Mapbox.framework` directory to `example/ios/Mapbox.framework`.
5. Now you're free to open the project in Xcode. Make sure you open `example/ios/Runner.xcworkspace`, not `example/ios/Runner.xcodeproj`.
