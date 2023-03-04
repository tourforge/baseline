import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:opentourguide/opentourguide.dart';
import 'package:opentourguide/theme.dart';

import 'tour_list.dart';

Future<void> main() async {
  await otbGuideInit(const OtbGuideAppConfig(
    appName: "OpenTourGuide",
    appDesc:
        '''OpenTourGuide is the example app for the OpenTourBuilder Guide library.''',
    baseUrl: "https://fsrv.fly.dev/v2",
  ));
  runApp(const OtbGuideApp());
}

class OtbGuideApp extends StatelessWidget {
  const OtbGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTourGuide',
      theme: SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? darkThemeData
          : lightThemeData,
      builder: (context, child) {
        if (child != null) {
          return ScrollConfiguration(
            behavior: const BouncingScrollBehavior(),
            child: child,
          );
        } else {
          return const SizedBox();
        }
      },
      home: const TourList(),
    );
  }
}

class BouncingScrollBehavior extends ScrollBehavior {
  const BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
