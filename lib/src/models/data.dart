import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:path/path.dart' as p;

import '../asset_image.dart';
import '../download_manager.dart';

class TourSummary {
  TourSummary._({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  static final Uri _toursJsonUri =
      Uri.parse("${DownloadManager.instance.networkBase}/tours.json");

  static Future<List<TourSummary>> list() async {
    dynamic json;
    try {
      var res = await get(_toursJsonUri);
      if (res.statusCode != 200) {
        throw Exception("Failed to get tours.json");
      }

      try {
        await File(p.join(DownloadManager.instance.localBase, "tours.json"))
            .writeAsString(res.body);
      } on IOException {
        // Don't care if this fails. Just a caching method.
      }

      json = jsonDecode(res.body);
    } on ClientException {
      try {
        json = jsonDecode(
            await File(p.join(DownloadManager.instance.localBase, "tours.json"))
                .readAsString());
      } on IOException {
        throw Exception("Failed to load tours.json");
      }
    }

    return TourSummary._parse(json);
  }

  static List<TourSummary> _parse(dynamic json) =>
      List.unmodifiable((json! as List<dynamic>).map(
        (eJson) => TourSummary._(
          id: eJson["id"]! as String,
          name: eJson["name"]! as String,
          thumbnail: AssetModel._parse(eJson["thumbnail"], {}),
        ),
      ));

  final String id;
  final String name;
  final AssetModel? thumbnail;

  Future<TourModel> loadDetails() => TourModel.load(id);
}

class TourModel {
  TourModel._({
    required this.id,
    required this.name,
    required this.desc,
    required this.waypoints,
    required this.gallery,
    required this.pois,
    required this.path,
  });

  static Future<TourModel> load(String id) async {
    if (!await isDownloaded(id)) {
      throw Exception("Tour '$id' is not downloaded.");
    }

    var tourJsonContent =
        await File(p.join(DownloadManager.instance.localBase, id, "tour.json"))
            .readAsString();

    var assetsJsonContent = AssetMeta._parse(jsonDecode(await File(
            p.join(DownloadManager.instance.localBase, id, "assets.json"))
        .readAsString()));

    return TourModel._parse(id, jsonDecode(tourJsonContent), assetsJsonContent);
  }

  static Future<bool> isDownloaded(String id) async {
    return await File("${DownloadManager.instance.localBase}/$id/downloaded")
        .exists();
  }

  static Future<void> download(String id,
      [Sink<double>? downloadProgress]) async {
    if (await isDownloaded(id)) {
      return;
    }

    await Directory(p.join(DownloadManager.instance.localBase, "assets"))
        .create(recursive: true);
    await Directory(p.join(DownloadManager.instance.localBase, id))
        .create(recursive: true);

    try {
      var futures = <Future<Download>>[];

      _printDebug("Starting tour download...");
      futures.add(DownloadManager.instance.download("$id/tiles.mbtiles"));
      futures.add(DownloadManager.instance.download("$id/tour.json"));
      var assetsDownload =
          await DownloadManager.instance.download("$id/assets.json");
      var assets = AssetMeta._parse(
          jsonDecode(await (await assetsDownload.file).readAsString()));
      for (var entry in assets.entries) {
        futures.add(DownloadManager.instance.download("assets/${entry.key}"));
      }

      var totalDownloadSize = 0;
      var downloadedSizes = [];
      for (int i = 0; i < futures.length; i++) {
        downloadedSizes.add(0);
      }

      for (var futEntry in futures.asMap().entries) {
        var idx = futEntry.key;
        futEntry.value.then((download) {
          if (download.downloadSize != null && download.downloadSize != 0) {
            totalDownloadSize += download.downloadSize!;

            download.downloadProgress.listen((downloadedSize) {
              downloadedSizes[idx] = downloadedSize;

              downloadProgress?.add(
                  downloadedSizes.reduce((a, b) => a + b).toDouble() /
                      totalDownloadSize.toDouble());
            });
          }
        });
      }

      var downloads = await Future.wait(futures);
      await Future.wait(downloads.map((download) => download.file));
      await File(p.join(DownloadManager.instance.localBase, id, "downloaded"))
          .create();
      _printDebug("Finished tour download.");
    } catch (e) {
      _printDebug("Error occurred while downloading: $e");
      rethrow;
    }
  }

  static TourModel _parse(
          String tourId, dynamic json, Map<String, AssetMeta> assets) =>
      TourModel._(
        id: tourId,
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        waypoints: List<WaypointModel>.unmodifiable(
            (json["waypoints"]! as List<dynamic>)
                .map((e) => WaypointModel._parse(e, assets))),
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(e, assets))),
        pois: List<PoiModel>.unmodifiable((json["pois"]! as List<dynamic>)
            .map((e) => PoiModel._parse(tourId, e, assets))),
        path: List.unmodifiable(mtk.PolygonUtil.decode(json["path"]! as String)
            .map((e) => LatLng(e.latitude, e.longitude))),
      );

  final String id;
  final String name;
  final String desc;
  final List<WaypointModel> waypoints;
  final List<AssetModel> gallery;
  final List<PoiModel> pois;
  final List<LatLng> path;

  AssetModel? get thumbnail => gallery[0];

  String get tilesPath =>
      p.join(DownloadManager.instance.localBase, id, "tiles.mbtiles");
}

class AssetMeta {
  AssetMeta._({
    required this.alt,
    required this.attribution,
  });

  static Map<String, AssetMeta> _parse(Map<String, dynamic> json) =>
      (json["assets"]! as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, _parseItem(value)));
  static AssetMeta _parseItem(Map<String, dynamic> json) => AssetMeta._(
        alt: json["alt"],
        attribution: json["attribution"],
      );

  final String? alt;
  final String? attribution;
}

class WaypointModel {
  WaypointModel._({
    required this.name,
    required this.desc,
    required this.lat,
    required this.lng,
    required this.triggerRadius,
    required this.narration,
    required this.transcript,
    required this.gallery,
  });

  static WaypointModel _parse(dynamic json, Map<String, AssetMeta> assets) =>
      WaypointModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        triggerRadius: json["trigger_radius"]! as double,
        narration: AssetModel._parse(json["narration"], assets),
        transcript: json["transcript"] as String?,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(e, assets))),
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final double triggerRadius;
  final AssetModel? narration;
  final String? transcript;
  final List<AssetModel> gallery;
}

class PoiModel {
  PoiModel._({
    required this.name,
    required this.desc,
    required this.lat,
    required this.lng,
    required this.gallery,
  });

  static PoiModel _parse(
          String tourName, dynamic json, Map<String, AssetMeta> assets) =>
      PoiModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(e, assets))),
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final List<AssetModel> gallery;
}

class AssetModel {
  AssetModel._(this.name, [this.meta]);

  static AssetModel? _parse(dynamic name, Map<String, AssetMeta> assets) =>
      name != null ? AssetModel._(name as String, assets[name]) : null;

  final String name;
  final AssetMeta? meta;

  String get localPath => "assets/$name";
  String get downloadPath =>
      p.join(DownloadManager.instance.localBase, "assets", name);
  File get downloadedFile => File(downloadPath);
  Future<bool> get isDownloaded async => await File(downloadPath).exists();
  AssetImage get imageProvider => AssetImage(this);
}

void _printDebug(Object? s) {
  if (kDebugMode) print(s);
}
