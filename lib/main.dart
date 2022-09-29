import 'package:flutter/material.dart';
import 'theme.dart';

import 'screens/gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: themeData,
      home: const Homepage(title: "Homepage"),
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const TourGallery(title: "Tour Gallery")),
            );
          },
          child: const Text('Go to tour gallery'),
        ),
      ),
    );
  }
}
