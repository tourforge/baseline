import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

String? _toursBasePathCurrent;
Future<String>? _toursBasePathFut;
Future<String> get _toursBasePath async {
  return _toursBasePathFut ??= getApplicationSupportDirectory()
      .then((value) => p.join(value.path, "tours"))
      .then((value) => _toursBasePathCurrent = value);
}

const _hostUri = "https://fsrv.fly.dev";

class TourSummary {
  TourSummary._({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  static final Uri _toursJsonUri = Uri.parse("$_hostUri/tours.json");

  static Future<List<TourSummary>> list() async {
    Response res = await get(_toursJsonUri);

    if (res.statusCode != 200) {
      throw Exception("Failed to get tours.json");
    }

    var json = jsonDecode(res.body);

    await _toursBasePath;
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
      await _download(id);
    }

    var tourJsonContent =
        await File(p.join(await _toursBasePath, id, "tour.json"))
            .readAsString();

    var assetsJsonContent = AssetMeta._parse(jsonDecode(
        await File(p.join(await _toursBasePath, id, "assets.json"))
            .readAsString()));

    return TourModel._parse(id, jsonDecode(tourJsonContent), assetsJsonContent);
  }

  static Future<bool> isDownloaded(String id) async {
    return await Directory(p.join(await _toursBasePath, id)).exists();
  }

  static Future<void> _download(String id) async {
    if (await isDownloaded(id)) {
      return;
    }

    var base = await _toursBasePath;

    await Directory(p.join(base, "assets")).create(recursive: true);
    await Directory(p.join(base, "$id.part")).create(recursive: true);

    try {
      var futures = <Future<void>>[];

      _printDebug("Starting tour download...");
      futures.add(_downloadToFile(Uri.parse("$_hostUri/$id/tiles.mbtiles"),
          outPath: p.join(base, "$id.part", "tiles.mbtiles")));
      futures.add(_downloadToFile(Uri.parse("$_hostUri/$id/tour.json"),
          outPath: p.join(base, "$id.part", "tour.json")));
      var assetsFile = await _downloadToFile(
          Uri.parse("$_hostUri/$id/assets.json"),
          outPath: p.join(base, "$id.part", "assets.json"));
      var assets =
          AssetMeta._parse(jsonDecode(await assetsFile.readAsString()));
      for (var entry in assets.entries) {
        futures.add(_downloadToFile(Uri.parse("$_hostUri/assets/${entry.key}"),
            outPath: p.join(base, "assets", entry.key)));
      }
      await Future.wait(futures);
      await Directory(p.join(base, "$id.part")).rename(p.join(base, id));
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

  String get tilesPath => p.join(_toursBasePathCurrent!, id, "tiles.mbtiles");
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

  String get fullPath => p.join(_toursBasePathCurrent!, "assets", name);
}

Future<File> _downloadToFile(Uri uri, {required String outPath}) async {
  var file = File(outPath);

  if (await file.exists()) {
    return file;
  }

  var outFile = File("$outPath.part");
  if (await outFile.exists()) {
    await outFile.delete();
  }

  _printDebug("Downloading $uri...");
  var outSink = outFile.openWrite();
  var client = HttpClient();
  var req = await client.getUrl(uri);
  var resp = await req.close();
  await outSink.addStream(resp);
  await outSink.flush();
  await outSink.close();

  await outFile.rename(outPath);
  _printDebug("Finished downloading $uri.");

  if (!await file.exists()) {
    throw Exception(
        "Download of $uri has completed but file wasn't saved to disk?!");
  }

  return file;
}

void _printDebug(String s) {
  if (kDebugMode) print(s);
}
