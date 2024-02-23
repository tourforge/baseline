import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:tourforge/src/asset_garbage_collector.dart';
import 'package:path/path.dart' as p;

import 'asset_image.dart';
import 'download_manager.dart';

class TourIndex {
  TourIndex._({
    required this.tours,
  });

  final List<TourIndexEntry> tours;

  static Future<TourIndex> load() async {
    var indexJsonFile = AssetModel._("index.json").downloadedFile;
    var preexistingIndexExists = await indexJsonFile.exists();

    var download = DownloadManager.instance.download(
      AssetModel._("index.json"),
      reDownload: true,
      maxRetries: preexistingIndexExists ? 3 : null,
    );

    try {
      indexJsonFile = await download.file;
    } on DownloadFailedException {
      if (preexistingIndexExists) {
        // don't care, continue executing since we have the preexisting file
      } else {
        // this is an unexpected error
        rethrow;
      }
    }

    AssetGarbageCollector.run();

    return parse(jsonDecode(await indexJsonFile.readAsString()));
  }

  static TourIndex parse(dynamic json) => TourIndex._(
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
    required this.content,
  });

  static TourIndexEntry _parse(dynamic json) => TourIndexEntry._(
        name: json["name"]! as String,
        thumbnail: AssetModel._(json["thumbnail"]),
        content: AssetModel._(json["content"]),
      );

  final String name;
  final AssetModel? thumbnail;
  final AssetModel content;

  Future<TourModel> loadDetails() async {
    var download = DownloadManager.instance.download(content);
    var tourJsonFile = await download.file;
    var tourJson = await tourJsonFile.readAsString();
    return TourModel.parse(content.name, jsonDecode(tourJson));
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
    required this.links,
  });

  static TourModel parse(String path, dynamic json) => TourModel._(
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
        links: json["links"] != null
            ? (json["links"] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, LinkModel._parse(value)))
            : {},
      );

  final String id;
  final String name;
  final String desc;
  final List<WaypointModel> waypoints;
  final List<AssetModel> gallery;
  final List<PoiModel> pois;
  final List<LatLng> path;
  final AssetModel tiles;
  final Map<String, LinkModel> links;

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
    yield* gallery
        .map((a) => AssetModel._("${a.name}.meta.json", required: false));
    yield tiles;

    for (final waypoint in waypoints) {
      yield* waypoint.gallery;
      yield* waypoint.gallery
          .map((a) => AssetModel._("${a.name}.meta.json", required: false));

      if (waypoint.narration != null) {
        yield waypoint.narration!;
      }
    }

    for (final poi in pois) {
      yield* poi.gallery;
      yield* poi.gallery
          .map((a) => AssetModel._("${a.name}.meta.json", required: false));
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
    required this.links,
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
        links: json["links"] != null
            ? (json["links"] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, LinkModel._parse(value)))
            : {},
      );

  final String name;
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

  static PoiModel _parse(dynamic json) => PoiModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>).map((e) => AssetModel._(e))),
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
  AssetModel._(this.name, {this.required = true});

  final String name;
  final bool required;

  Future<AssetMeta?> get meta async {
    var metaModel = AssetModel._("$name.meta.json", required: false);
    var metaFile = await DownloadManager.instance.download(metaModel).file;

    if (await metaFile.exists()) {
      var metaText = await metaFile.readAsString();
      var metaJson = jsonDecode(metaText);
      return AssetMeta._parse(metaJson);
    } else {
      return null;
    }
  }

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
