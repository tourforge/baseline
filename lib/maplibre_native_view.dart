import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  static const _channel = MethodChannel("opentourbuilder.org/guide/map");

  late Future<String> buildStyle;

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

    buildStyle = _createStyleIfNotExists();

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

  Future<String> _createStyleIfNotExists() async {
    final stylePath =
        p.join((await getTemporaryDirectory()).path, "style.json");

    if (await File(stylePath).exists()) {
      return stylePath;
    }

    if (!mounted) return stylePath;
    var assetBundle = DefaultAssetBundle.of(context);
    var styleText = await assetBundle.loadString('assets/style.json');
    var key = await assetBundle.loadString('assets/maptiler.txt');

    var baseStyle = jsonDecode(styleText);

    baseStyle["glyphs"] =
        "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key=$key";

    var style = jsonEncode(baseStyle);

    await File(stylePath).writeAsString(style);

    return stylePath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: buildStyle,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          // This is used in the platform side to register the view.
          const String viewType =
              'org.opentourbuilder.guide.MapLibrePlatformView';
          // Pass parameters to the platform side.
          final Map<String, dynamic> creationParams = <String, dynamic>{
            "stylePath": snapshot.data,
            "tilesUrl": "mbtiles://${widget.tour.tilesPath}",
            "pathGeoJson": _pathToGeoJson(widget.tour.path),
            "pointsGeoJson": _waypointsToGeoJson(widget.tour.waypoints),
          };

          return Stack(
            fit: StackFit.passthrough,
            children: [
              if (Platform.isAndroid)
                AndroidView(
                  viewType: viewType,
                  layoutDirection: TextDirection.ltr,
                  creationParams: creationParams,
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              if (Platform.isIOS)
                UiKitView(
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
