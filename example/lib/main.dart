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
      baseUrl: "http://192.168.4.248:8000/download/6a70129d-4560-498c-8f50-d25a8aa4623e",
      lightThemeData: lightThemeData,
      darkThemeData: darkThemeData,
    ),
  );
}
