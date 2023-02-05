library opentourguide;

import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/src/config.dart';
import '/src/controllers/narration_playback.dart';
import '/src/download_manager.dart';

export '/src/config.dart' show OtbGuideAppConfig;
export 'src/screens/tour_list.dart' show TourList;

Future<void> otbGuideInit(OtbGuideAppConfig withAppConfig) async {
  appConfig = withAppConfig;

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
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
}
