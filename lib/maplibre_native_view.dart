import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/math/math.dart';
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

  late final String stylePath;
  late final String satStylePath;
  late Future<String> buildStyle;
  late final LatLng center;
  late final double zoom;

  bool _satelliteEnabled = false;

  bool get satelliteEnabled => _satelliteEnabled;
  set satelliteEnabled(bool value) {
    _satelliteEnabled = value;

    _channel.invokeMethod<void>(
        "setStyle", _satelliteEnabled ? satStylePath : stylePath);
  }

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

    buildStyle = _createStyle();

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

    center =
        averagePoint(widget.tour.waypoints.map((w) => LatLng(w.lat, w.lng)));
    zoom = _calculateTourZoom(widget.tour);
  }

  Future<String> _createStyle() async {
    try {
      final spritePath = p.join((await getTemporaryDirectory()).path, "sprite");
      final spriteSatPath =
          p.join((await getTemporaryDirectory()).path, "sprite-satellite");
      stylePath = p.join((await getTemporaryDirectory()).path, "style.json");
      satStylePath =
          p.join((await getTemporaryDirectory()).path, "style-satellite.json");

      if (!mounted) return satStylePath;
      var assetBundle = DefaultAssetBundle.of(context);
      var styleText = await assetBundle.loadString('assets/style.json');
      var satStyleText =
          await assetBundle.loadString('assets/style-satellite.json');
      var key = await assetBundle.loadString('assets/maptiler.txt');
      var tomtomKey = await assetBundle.loadString('assets/tomtom.txt');
      var spritePng = await assetBundle.load('assets/sprite.png');
      var spriteJson = await assetBundle.loadString('assets/sprite.json');
      var sprite2xPng = await assetBundle.load('assets/sprite@2x.png');
      var sprite2xJson = await assetBundle.loadString('assets/sprite@2x.json');
      var spriteSatPng = await assetBundle.load('assets/sprite-satellite.png');
      var spriteSatJson =
          await assetBundle.loadString('assets/sprite-satellite.json');
      var spriteSat2xPng =
          await assetBundle.load('assets/sprite-satellite@2x.png');
      var spriteSat2xJson =
          await assetBundle.loadString('assets/sprite-satellite@2x.json');

      var style = jsonDecode(styleText);
      var satStyle = jsonDecode(satStyleText);

      satStyle["glyphs"] = style["glyphs"] =
          "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key=$key";
      satStyle["sprite"] = "file://$spriteSatPath";
      style["sprite"] = "file://$spritePath";
      satStyle["sources"]["openmaptiles"]["url"] = style["sources"]
          ["openmaptiles"]["url"] = "mbtiles://${widget.tour.tilesPath}";
      satStyle["sources"]["satellite"]["tiles"][0] =
          "https://api.tomtom.com/map/1/tile/sat/main/{z}/{x}/{y}.jpg?key=$tomtomKey";

      styleText = jsonEncode(style);
      satStyleText = jsonEncode(satStyle);

      await File("$spritePath.png")
          .writeAsBytes(spritePng.buffer.asUint8List());
      await File("$spritePath.json").writeAsString(spriteJson);
      await File("$spritePath@2x.png")
          .writeAsBytes(sprite2xPng.buffer.asUint8List());
      await File("$spritePath@2x.json").writeAsString(sprite2xJson);
      await File("$spriteSatPath.png")
          .writeAsBytes(spriteSatPng.buffer.asUint8List());
      await File("$spriteSatPath.json").writeAsString(spriteSatJson);
      await File("$spriteSatPath@2x.png")
          .writeAsBytes(spriteSat2xPng.buffer.asUint8List());
      await File("$spriteSatPath@2x.json").writeAsString(spriteSat2xJson);
      await File(stylePath).writeAsString(styleText);
      await File(satStylePath).writeAsString(satStyleText);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

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
            "pathGeoJson": _pathToGeoJson(widget.tour.path),
            "pointsGeoJson": _waypointsToGeoJson(widget.tour.waypoints),
            "center": {"lat": center.latitude, "lng": center.longitude},
            "zoom": zoom,
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

double _calculateTourZoom(TourModel tour) {
  var distance = const Distance();
  var center = averagePoint(tour.waypoints.map((w) => LatLng(w.lat, w.lng)));
  var minRadius = tour.waypoints
      .map((w) => distance(LatLng(w.lat, w.lng), center))
      .reduce(max);
  return max(-log(minRadius) / ln2 + 25.25 - 1.5, 1);
}
