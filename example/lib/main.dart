import 'package:flutter/material.dart';
import 'package:opentourguide/opentourguide.dart';

import '/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runOpenTourGuide(
    config: OpenTourGuideConfig(
      appName: "OpenTourGuide Example",
      appDesc:
          '''OpenTourGuide Example is the example app for the OpenTourGuide library.''',
      baseUrl: "https://fsrv.fly.dev/v2",
      lightThemeData: lightThemeData,
      darkThemeData: darkThemeData,
    ),
  );
}
