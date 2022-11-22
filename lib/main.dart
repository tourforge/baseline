import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'screens/gallery.dart';
import 'theme.dart';

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterDisplayMode.setHighRefreshRate();
  }
  runApp(const OtbGuideApp());
}

class OtbGuideApp extends StatelessWidget {
  const OtbGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTourGuide',
      theme: themeData,
      home: const TourGallery(),
    );
  }
}
