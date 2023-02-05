late OtbGuideAppConfig appConfig;

class OtbGuideAppConfig {
  const OtbGuideAppConfig({required this.appName, this.appDesc});

  /// The name of the application, as displayed to users.
  final String appName;

  /// A description for the application to be displayed on the About page.
  final String? appDesc;
}
