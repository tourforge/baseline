import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:tourforge_baseline/src/asset_garbage_collector.dart';
import 'package:path/path.dart' as p;

import 'asset_image.dart';
import 'download_manager.dart';

class Project {
  Project._({
    required this.tours,
    required this.assets,
  });

  final List<TourModel> tours;
  final Map<String, AssetInfo> assets;

  static Future<Project> load() async {
    var tourforgeJsonFile = AssetModel._fromId("tourforge.json").downloadedFile;
    var preexistingIndexExists = await tourforgeJsonFile.exists();

    var download = DownloadManager.instance.download(
      AssetModel._fromId("tourforge.json"),
      reDownload: true,
      maxRetries: preexistingIndexExists ? 3 : null,
    );

    try {
      tourforgeJsonFile = await download.file;
    } on DownloadFailedException catch (e) {
      if (preexistingIndexExists) {
        // don't care, continue executing since we have the preexisting file
        if (kDebugMode) {
          print("Ignoring exception because preexisting index exists: $e");
        }
      } else {
        // this is an unexpected error
        rethrow;
      }
    }

    AssetGarbageCollector.run();

    var idx = parse(jsonDecode(await tourforgeJsonFile.readAsString()));
    if (kDebugMode) {
      print(idx);
    }

    return idx;
  }

  static Project parse(dynamic json) {
    Map<String, AssetInfo> assetsMap = Map.unmodifiable((json["assets"] as Map<String, dynamic>).map<String, AssetInfo>((key, value) => MapEntry<String, AssetInfo>(key, AssetInfo._parse(value))));
    return Project._(
        tours: List.unmodifiable(
          ((json as Map<String, dynamic>)["tours"] as List<dynamic>)
              .map((e) => TourModel.parse(e, assetsMap)),
        ),
        assets: Map.unmodifiable((json["assets"] as Map<String, dynamic>).map((key, value) => MapEntry(key, AssetInfo._parse(value)))),
      );
  }
}

class AssetInfo {
  AssetInfo._({
    required this.alt,
    required this.attrib,
    required this.type,
    required this.hash,
  });

  final String alt;
  final String attrib;
  final String type;
  final String hash;

  static AssetInfo _parse(dynamic json) => AssetInfo._(
    alt: json["alt"],
    attrib: json["attrib"],
    type: json["type"],
    hash: json["hash"],
  );
}

class TourModel {
  TourModel._({
    required this.id,
    required this.title,
    required this.desc,
    required this.route,
    required this.gallery,
    required this.pois,
    required this.path,
    required this.tiles,
    required this.links,
    required this.type,
  });

  static TourModel parse(dynamic json, Map<String, AssetInfo> assetsMap) => TourModel._(
        id: json["id"],
        title: json["title"]! as String,
        desc: json["desc"]! as String,
        route: List<WaypointModel>.unmodifiable(
            (json["route"]! as List<dynamic>)
                .where((element) => element["type"] == "stop")
                .map((e) => WaypointModel._parse(e, assetsMap))),
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._fromName(e, assetsMap))),
        pois: List<PoiModel>.unmodifiable(
            (json["pois"]! as List<dynamic>).map((e) => PoiModel._parse(e, assetsMap))),
        path: List.unmodifiable(mtk.PolygonUtil.decode(json["path"]! as String)
            .map((e) => LatLng(e.latitude, e.longitude))),
        tiles: json["tiles"] != null ? AssetModel._fromName(json["tiles"], assetsMap) : null,
        links: json["links"] != null
            ? (json["links"] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, LinkModel._parse(value)))
            : {},
        type: json["type"]! as String,
      );

  final String id;
  final String title;
  final String desc;
  final List<WaypointModel> route;
  final List<AssetModel> gallery;
  final List<PoiModel> pois;
  final List<LatLng> path;
  final AssetModel? tiles;
  final Map<String, LinkModel> links;
  final String type;

  Iterable<AssetModel> get allAssets =>
      HashSet<AssetModel>.from(_allAssets().followedBy(_allAssets()));

  Future<bool> isFullyDownloaded() async {
    for (final asset in allAssets) {
      if (asset.required && !await asset.isDownloaded) return false;
    }

    return true;
  }

  Iterable<AssetModel> _allAssets() sync* {
    yield* gallery;
    if (tiles != null) {
      yield tiles!;
    }

    for (final waypoint in route) {
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
    required this.title,
    required this.desc,
    required this.lat,
    required this.lng,
    required this.triggerRadius,
    required this.narration,
    required this.transcript,
    required this.gallery,
    required this.links,
  });

  static WaypointModel _parse(dynamic json, Map<String, AssetInfo> assetsMap) => WaypointModel._(
        title: json["title"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        triggerRadius: json["trigger_radius"]!.toDouble(),
        narration:
            json["narration"] != null ? AssetModel._fromName(json["narration"], assetsMap) : null,
        transcript: json["transcript"] as String?,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._fromName(e, assetsMap))),
        links: json["links"] != null
            ? (json["links"] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, LinkModel._parse(value)))
            : {},
      );

  final String title;
  final String desc;
  final double lat;
  final double lng;
  final double triggerRadius;
  final AssetModel? narration;
  final String? transcript;
  final List<AssetModel> gallery;
  final Map<String, LinkModel> links;
}

class PoiModel {
  PoiModel._({
    required this.name,
    required this.desc,
    required this.lat,
    required this.lng,
    required this.gallery,
    required this.links,
  });

  static PoiModel _parse(dynamic json, Map<String, AssetInfo> assetsMap) => PoiModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._fromName(e, assetsMap))),
        links: json["links"] != null
            ? (json["links"] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, LinkModel._parse(value)))
            : {},
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final List<AssetModel> gallery;
  final Map<String, LinkModel> links;
}

class LinkModel {
  LinkModel._({
    required this.href,
  });

  static LinkModel _parse(dynamic json) => LinkModel._(
        href: json["href"]! as String,
      );

  final String href;
}

class AssetModel {
  AssetModel._fromName(this.name, Map<String, AssetInfo> assetsMap, {this.required = true}) : id = assetsMap[name]!.hash, alt = assetsMap[name]!.alt, attrib = assetsMap[name]!.attrib;
  AssetModel._fromId(this.id, {this.required = true}) : name = "", alt = "", attrib = "";

  final String name;
  final String id;
  final String alt;
  final String attrib;
  final bool required;

  String get localPath => p.join(DownloadManager.instance.localBase, id);
  File get downloadedFile => File(localPath);
  Future<bool> get isDownloaded async => await File(localPath).exists();
  AssetImage get imageProvider => AssetImage(this);

  @override
  bool operator ==(Object other) => other is AssetModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
