import 'package:flutter/material.dart';

TourForgeConfig get tourForgeConfig => _tourForgeConfig;

late TourForgeConfig _tourForgeConfig;

void setTourForgeConfig(TourForgeConfig config) {
  _tourForgeConfig = config;
}

class TourForgeConfig {
  const TourForgeConfig({
    required this.appName,
    this.appDesc,
    required this.baseUrl,
    this.baseUrlIsIndirect = false,
    required this.lightThemeData,
    required this.darkThemeData,
  });

  /// The name of the application, as displayed to users.
  final String appName;

  /// A description for the application to be displayed on the About page.
  final String? appDesc;

  /// The base URL for downloading tours and tour assets.
  final String baseUrl;

  /// Whether the base URL is in fact a URL that, when fetched, returns the real base URL.
  final bool baseUrlIsIndirect;

  /// The light theme for the application.
  final ThemeData lightThemeData;

  /// The dark theme for the application.
  final ThemeData darkThemeData;
}
