import 'package:flutter/material.dart';

OtbGuideAppConfig get appConfig => _appConfig;

late OtbGuideAppConfig _appConfig;

void setAppConfig(OtbGuideAppConfig config) {
  _appConfig = config;
}

class OtbGuideAppConfig {
  const OtbGuideAppConfig({
    required this.appName,
    this.appDesc,
    required this.baseUrl,
    required this.lightThemeData,
    required this.darkThemeData,
  });

  /// The name of the application, as displayed to users.
  final String appName;

  /// A description for the application to be displayed on the About page.
  final String? appDesc;

  /// The base URL for downloading tours and tour assets.
  final String baseUrl;

  /// The light theme for the application.
  final ThemeData lightThemeData;

  /// The dark theme for the application.
  final ThemeData darkThemeData;
}
