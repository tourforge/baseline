import 'package:flutter/material.dart';
import 'package:opentourguide/opentourguide.dart';
import 'package:opentourguide/theme.dart';

Future<void> main() async {
  await otbGuideInit(const OtbGuideAppConfig(
    appName: "OpenTourGuide",
    appDesc:
        '''OpenTourGuide is the example app for the OpenTourBuilder Guide library.''',
  ));
  runApp(const OtbGuideApp());
}

class OtbGuideApp extends StatelessWidget {
  const OtbGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTourGuide',
      theme: themeData,
      home: const TourList(),
    );
  }
}
