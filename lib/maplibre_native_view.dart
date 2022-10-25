import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '/models.dart';

class MapLibreMap extends StatefulWidget {
  const MapLibreMap({
    super.key,
    required this.tour,
    required this.onCameraUpdate,
    required this.fakeGpsOverlay,
  });

  final TourModel tour;
  final void Function(LatLng center, double zoom) onCameraUpdate;
  final Widget fakeGpsOverlay;

  @override
  State<MapLibreMap> createState() => MapLibreMapState();
}

class MapLibreMapState extends State<MapLibreMap> {
  static const _channel = MethodChannel("evresi.org/app/map");

  late Future<String> style;

  void updateLocation(LatLng location) {
    _channel.invokeMethod<void>(
      "updateLocation",
      jsonEncode({
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [location.longitude, location.latitude],
            },
          },
        ],
      }),
    );
  }

  @override
  void initState() {
    super.initState();

    style = (() async {
      var assetBundle = DefaultAssetBundle.of(context);
      var styleText = await assetBundle.loadString('assets/style.json');
      var key = await assetBundle.loadString('assets/maptiler.txt');

      var styleJson = jsonDecode(styleText);

      styleJson["sources"]["openmaptiles"]["url"] =
          "mbtiles://${widget.tour.tilesPath}";
      styleJson["glyphs"] =
          "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key=$key";

      return jsonEncode(styleJson);
    })();

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "updateCameraPosition":
          double lat = call.arguments["lat"];
          double lng = call.arguments["lng"];
          double zoom = call.arguments["zoom"];
          widget.onCameraUpdate(LatLng(lat, lng), zoom);
          break;
      }

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // This is used in the platform side to register the view.
          const String viewType = 'org.evresi.app.MapLibrePlatformView';
          // Pass parameters to the platform side.
          final Map<String, dynamic> creationParams = <String, dynamic>{
            "style": snapshot.data,
            "pathGeoJson": _pathToGeoJson(widget.tour.path),
            "pointsGeoJson": _waypointsToGeoJson(widget.tour.waypoints),
          };

          return Stack(
            fit: StackFit.passthrough,
            children: [
              AndroidView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              ),
              widget.fakeGpsOverlay,
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

String _pathToGeoJson(List<LatLng> path) {
  return jsonEncode({
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            for (var point in path) [point.longitude, point.latitude],
          ]
        }
      }
    ]
  });
}

String _waypointsToGeoJson(List<WaypointModel> waypoints) {
  return jsonEncode({
    "type": "FeatureCollection",
    "features": [
      for (var waypoint in waypoints.asMap().entries)
        {
          "type": "Feature",
          "properties": {"number": "${waypoint.key + 1}"},
          "geometry": {
            "type": "Point",
            "coordinates": [waypoint.value.lng, waypoint.value.lat],
          },
        },
    ],
  });
}
