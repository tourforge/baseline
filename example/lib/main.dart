import 'package:flutter/material.dart';
import 'package:tourforge/tourforge.dart';

import '/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runTourForge(
    config: TourForgeConfig(
      appName: "TourForge Example",
      appDesc:
          '''TourForge Example is the example app for the TourForge library.''',
      baseUrl: "https://fsrv.fly.dev/v2",
      lightThemeData: lightThemeData,
      darkThemeData: darkThemeData,
    ),
  );
}
