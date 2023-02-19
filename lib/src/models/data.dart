import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:path/path.dart' as p;

import '../asset_image.dart';
import '../download_manager.dart';

class TourIndex {
  TourIndex._({
    required this.tours,
  });

  final List<TourIndexEntry> tours;

  static Future<TourIndex> load() async {
    var download =
        DownloadManager.instance.download("index.json", reDownload: true);
    var indexJsonFile = await download.file;
    return _parse(jsonDecode(await indexJsonFile.readAsString()));
  }

  static TourIndex _parse(dynamic json) => TourIndex._(
        tours: List.unmodifiable(
          ((json as Map<String, dynamic>)["tours"] as List<dynamic>)
              .map((e) => TourIndexEntry._parse(e)),
        ),
      );
}

class TourIndexEntry {
  TourIndexEntry._({
    required this.name,
    required this.thumbnail,
    required String contentPath,
  }) : _contentPath = contentPath;

  static TourIndexEntry _parse(dynamic json) => TourIndexEntry._(
        name: json["name"]! as String,
        thumbnail: AssetModel._(json["thumbnail"]),
        contentPath: json["content"]! as String,
      );

  final String name;
  final AssetModel? thumbnail;
  final String _contentPath;

  Future<TourModel> loadDetails() async {
    var download = DownloadManager.instance.download(_contentPath);
    var tourJsonFile = await download.file;
    var tourJson = await tourJsonFile.readAsString();
    return TourModel._parse(_contentPath, jsonDecode(tourJson));
  }
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
    required this.tiles,
  });

  static TourModel _parse(String path, dynamic json) => TourModel._(
        id: path,
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        waypoints: List<WaypointModel>.unmodifiable(
            (json["waypoints"]! as List<dynamic>)
                .where((element) => element["type"] == "waypoint")
                .map(WaypointModel._parse)),
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._(e))),
        pois: List<PoiModel>.unmodifiable(
            (json["pois"]! as List<dynamic>).map(PoiModel._parse)),
        path: List.unmodifiable(mtk.PolygonUtil.decode(json["path"]! as String)
            .map((e) => LatLng(e.latitude, e.longitude))),
        tiles: AssetModel._(json["tiles"]),
      );

  final String id;
  final String name;
  final String desc;
  final List<WaypointModel> waypoints;
  final List<AssetModel> gallery;
  final List<PoiModel> pois;
  final List<LatLng> path;
  final AssetModel tiles;

  Iterable<AssetModel> get allAssets => HashSet<AssetModel>.from(_allAssets());

  Future<bool> isFullyDownloaded() async {
    for (final asset in allAssets) {
      if (!await asset.isDownloaded) return false;
    }

    return true;
  }

  Iterable<AssetModel> _allAssets() sync* {
    yield* gallery;
    yield tiles;

    for (final waypoint in waypoints) {
      yield* waypoint.gallery;

      if (waypoint.narration != null) {
        yield waypoint.narration!;
      }
    }

    for (final poi in pois) {
      yield* poi.gallery;
    }
  }
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

  static WaypointModel _parse(dynamic json) => WaypointModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        triggerRadius: json["trigger_radius"]! as double,
        narration:
            json["narration"] != null ? AssetModel._(json["narration"]) : null,
        transcript: json["transcript"] as String?,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._(e))),
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

  static PoiModel _parse(dynamic json) => PoiModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._(e))),
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final List<AssetModel> gallery;
}

class AssetModel {
  AssetModel._(this.name);

  final String name;

  Future<AssetMeta?> get meta async {}
  String get localPath => p.join(DownloadManager.instance.localBase, name);
  File get downloadedFile => File(localPath);
  Future<bool> get isDownloaded async => await File(localPath).exists();
  AssetImage get imageProvider => AssetImage(this);

  @override
  bool operator ==(Object other) => other is AssetModel && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class AssetMeta {
  AssetMeta._({
    required this.alt,
    required this.attribution,
  });

  static AssetMeta _parse(dynamic json) => AssetMeta._(
        alt: json["alt"],
        attribution: json["attrib"],
      );

  final String? alt;
  final String? attribution;
}
