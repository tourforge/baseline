import 'package:flutter/material.dart';
import 'theme.dart';

import 'screens/gallery.dart';

void main() {
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
