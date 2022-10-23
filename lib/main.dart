import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'screens/gallery.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDisplayMode.setHighRefreshRate();
  runApp(const EvresiApp());
}

class EvresiApp extends StatelessWidget {
  const EvresiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evresi',
      theme: themeData,
      home: const TourGallery(),
    );
  }
}
