import 'dart:convert';

import 'package:flutter/services.dart';

class TourSummary {
  TourSummary._({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  static Future<List<TourSummary>> list() async =>
      await rootBundle.loadStructuredData(
        'assets/tours/tours.json',
        (jsonText) async => TourSummary._parse(await jsonDecode(jsonText)),
      );

  static List<TourSummary> _parse(dynamic json) =>
      List.unmodifiable((json! as List<dynamic>).map(
        (eJson) => TourSummary._(
          id: eJson["id"]! as String,
          name: eJson["name"]! as String,
          thumbnail:
              AssetModel._parse(eJson["id"]! as String, eJson["thumbnail"]),
        ),
      ));

  final String id;
  final String name;
  final AssetModel thumbnail;
}

class TourModel {
  TourModel._({
    required this.name,
    required this.desc,
    required this.waypoints,
    required this.gallery,
    required this.pois,
  });

  static Future<TourModel> load(String id) async =>
      await rootBundle.loadStructuredData<TourModel>(
        'assets/tours/$id/tour.json',
        (jsonText) async => TourModel._parse(id, await jsonDecode(jsonText)),
      );

  static TourModel _parse(String tourId, dynamic json) => TourModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        waypoints: List<WaypointModel>.unmodifiable(
            (json["waypoints"]! as List<dynamic>)
                .map((e) => WaypointModel._parse(tourId, e))),
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(tourId, e))),
        pois: List<PoiModel>.unmodifiable((json["pois"]! as List<dynamic>)
            .map((e) => PoiModel._parse(tourId, e))),
      );

  final String name;
  final String desc;
  final List<WaypointModel> waypoints;
  final List<AssetModel> gallery;
  final List<PoiModel> pois;
}

class WaypointModel {
  WaypointModel._({
    required this.name,
    required this.desc,
    required this.lat,
    required this.lng,
    required this.narration,
    required this.gallery,
  });

  static WaypointModel _parse(String tourName, dynamic json) => WaypointModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        narration: AssetModel._parse(tourName, json["narration"]),
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(tourName, e))),
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final AssetModel narration;
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

  static PoiModel _parse(String tourName, dynamic json) => PoiModel._(
        name: json["name"]! as String,
        desc: json["desc"]! as String,
        lat: json["lat"]! as double,
        lng: json["lng"]! as double,
        gallery: List<AssetModel>.unmodifiable(
            (json["gallery"]! as List<dynamic>)
                .map((e) => AssetModel._parse(tourName, e))),
      );

  final String name;
  final String desc;
  final double lat;
  final double lng;
  final List<AssetModel> gallery;
}

class AssetModel {
  AssetModel._(this._tourName, this.name);

  static AssetModel _parse(String tourName, dynamic name) =>
      AssetModel._(tourName, name! as String);

  final String _tourName;
  final String name;

  String get fullPath => 'assets/tours/$_tourName/assets/$name';
}
