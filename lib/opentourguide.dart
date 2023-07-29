library opentourguide;

import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'src/asset_garbage_collector.dart';
import 'src/config.dart';
import 'src/controllers/narration_playback.dart';
import 'src/download_manager.dart';

export 'src/asset_image.dart' show AssetImage;
export 'src/config.dart' show OtbGuideAppConfig, appConfig;
export 'src/location.dart' show requestGpsPermissions;
export 'src/data.dart';
export 'src/screens/tour_details.dart' show TourDetails;
export 'src/widgets/asset_image_builder.dart' show AssetImageBuilder;
export 'src/widgets/collapsible_section.dart' show CollapsibleSection;

Future<void> otbGuideInit(OtbGuideAppConfig withAppConfig) async {
  setAppConfig(withAppConfig);

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    FlutterDisplayMode.setHighRefreshRate();
  }

  DownloadManager.instance = DownloadManager(
    getApplicationSupportDirectory().then((appSuppDir) {
      var base = p.join(appSuppDir.path, "tours");
      AssetGarbageCollector.base = base;
      return base;
    }),
    Future.value(appConfig.baseUrl),
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.speech());

  await NarrationPlaybackController.init();
}
