import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/controllers/narration_playback.dart';
import '/download_manager.dart';
import 'screens/tour_list.dart';
import 'theme.dart';

Future<void> main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterDisplayMode.setHighRefreshRate();
  }

  DownloadManager.instance = DownloadManager(
    getApplicationSupportDirectory()
        .then((appSuppDir) => p.join(appSuppDir.path, "tours")),
    Future.value("https://fsrv.fly.dev"),
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.speech());

  await NarrationPlaybackController.init();

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
