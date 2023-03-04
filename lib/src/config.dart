late OtbGuideAppConfig appConfig;

class OtbGuideAppConfig {
  const OtbGuideAppConfig({
    required this.appName,
    this.appDesc,
    required this.baseUrl,
  });

  /// The name of the application, as displayed to users.
  final String appName;

  /// A description for the application to be displayed on the About page.
  final String? appDesc;

  /// The base URL for downloading tours and tour assets.
  final String baseUrl;
}
