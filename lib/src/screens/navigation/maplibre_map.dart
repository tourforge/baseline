import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../math.dart';
import '../../data.dart';

class MapLibreMapController {
  late final _MapLibreMapState _state;

  bool get satelliteEnabled => _state._satelliteEnabled;
  set satelliteEnabled(bool value) {
    _state._satelliteEnabled = value;

    _MapLibreMapState._channel.invokeMethod<void>("setStyle",
        _state._satelliteEnabled ? _state.satStylePath : _state.stylePath);
  }

  void updateLocation(LatLng location) {
    _MapLibreMapState._channel.invokeMethod<void>(
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

  void moveCamera(LatLng where) {
    _MapLibreMapState._channel.invokeMethod<void>(
      "moveCamera",
      {
        "lat": where.latitude,
        "lng": where.longitude,
        "duration": 1500,
      },
    );
  }
}

class MapLibreMap extends StatefulWidget {
  const MapLibreMap({
    super.key,
    required this.tour,
    required this.controller,
    required this.onMoveUpdate,
    required this.onMoveBegin,
    required this.onMoveEnd,
    required this.onCameraUpdate,
    required this.onPointClick,
    required this.onPoiClick,
    required this.fakeGpsOverlay,
  });

  final TourModel tour;
  final MapLibreMapController controller;
  final void Function() onMoveUpdate;
  final void Function() onMoveBegin;
  final void Function() onMoveEnd;
  final void Function(LatLng center, double zoom) onCameraUpdate;
  final void Function(int index) onPointClick;
  final void Function(int index) onPoiClick;
  final Widget fakeGpsOverlay;

  @override
  State<MapLibreMap> createState() => _MapLibreMapState();
}

class _MapLibreMapState extends State<MapLibreMap> {
  static const _channel = MethodChannel("tourforge.org/guide/map");

  late final String stylePath;
  late final String satStylePath;
  late Future<String> buildStyle;
  late final LatLng center;
  late final double zoom;

  bool _satelliteEnabled = false;

  @override
  void initState() {
    super.initState();

    widget.controller._state = this;

    buildStyle = _createStyle();

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "updateCameraPosition":
          double lat = call.arguments["lat"];
          double lng = call.arguments["lng"];
          double zoom = call.arguments["zoom"];
          widget.onCameraUpdate(LatLng(lat, lng), zoom);
          break;
        case "moveUpdate":
          widget.onMoveUpdate();
          break;
        case "moveBegin":
          widget.onMoveBegin();
          break;
        case "moveEnd":
          widget.onMoveEnd();
          break;
        case "pointClick":
          widget.onPointClick(call.arguments["index"] as int);
          break;
        case "poiClick":
          widget.onPoiClick(call.arguments["index"] as int);
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
      final fontsBasePath =
          p.join((await getTemporaryDirectory()).path, "fonts");
      final notoRegularPath =
          p.join(fontsBasePath, "Noto Sans Regular", "0-255.pbf");
      final notoBoldPath = p.join(fontsBasePath, "Noto Sans Bold", "0-255.pbf");
      final notoItalicPath =
          p.join(fontsBasePath, "Noto Sans Italic", "0-255.pbf");

      if (!mounted) return satStylePath;
      var assetBundle = DefaultAssetBundle.of(context);
      var assetPrefix = "packages/tourforge";
      var styleText =
          await assetBundle.loadString('$assetPrefix/assets/style.json');
      var satStyleText = await assetBundle
          .loadString('$assetPrefix/assets/style-satellite.json');
      var tomtomKey = "";
      try {
        tomtomKey = (await assetBundle.loadString('assets/tomtom.txt')).trim();
      } catch (e) {
        if (kDebugMode) {
          print("Failed to load TomTom key. Proceeding with empty key.");
        }
      }
      var spritePng = await assetBundle.load('$assetPrefix/assets/sprite.png');
      var spriteJson =
          await assetBundle.loadString('$assetPrefix/assets/sprite.json');
      var sprite2xPng =
          await assetBundle.load('$assetPrefix/assets/sprite@2x.png');
      var sprite2xJson =
          await assetBundle.loadString('$assetPrefix/assets/sprite@2x.json');
      var spriteSatPng =
          await assetBundle.load('$assetPrefix/assets/sprite-satellite.png');
      var spriteSatJson = await assetBundle
          .loadString('$assetPrefix/assets/sprite-satellite.json');
      var spriteSat2xPng =
          await assetBundle.load('$assetPrefix/assets/sprite-satellite@2x.png');
      var spriteSat2xJson = await assetBundle
          .loadString('$assetPrefix/assets/sprite-satellite@2x.json');
      var notoRegular = await assetBundle
          .load('$assetPrefix/assets/fonts/Noto Sans Regular/0-255.pbf');
      var notoBold = await assetBundle
          .load('$assetPrefix/assets/fonts/Noto Sans Bold/0-255.pbf');
      var notoItalic = await assetBundle
          .load('$assetPrefix/assets/fonts/Noto Sans Italic/0-255.pbf');

      var style = jsonDecode(styleText);
      var satStyle = jsonDecode(satStyleText);

      satStyle["glyphs"] =
          style["glyphs"] = "file://$fontsBasePath/{fontstack}/{range}.pbf";
      satStyle["sprite"] = "file://$spriteSatPath";
      style["sprite"] = "file://$spritePath";
      satStyle["sources"]["openmaptiles"]["url"] = style["sources"]
          ["openmaptiles"]["url"] = "mbtiles://${widget.tour.tiles.localPath}";
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
      await Directory(p.dirname(notoRegularPath)).create(recursive: true);
      await File(notoRegularPath)
          .writeAsBytes(notoRegular.buffer.asUint8List());
      await Directory(p.dirname(notoBoldPath)).create(recursive: true);
      await File(notoBoldPath).writeAsBytes(notoBold.buffer.asUint8List());
      await Directory(p.dirname(notoItalicPath)).create(recursive: true);
      await File(notoItalicPath).writeAsBytes(notoItalic.buffer.asUint8List());
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
          const String viewType = 'org.tourforge.guide.MapLibrePlatformView';
          // Pass parameters to the platform side.
          final Map<String, dynamic> creationParams = <String, dynamic>{
            "stylePath": snapshot.data,
            "pathGeoJson": _pathToGeoJson(widget.tour.path),
            "pointsGeoJson": _waypointsToGeoJson(widget.tour.waypoints),
            "poisGeoJson": _poisToGeoJson(widget.tour.pois),
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

String _poisToGeoJson(List<PoiModel> pois) {
  return jsonEncode({
    "type": "FeatureCollection",
    "features": [
      for (var poi in pois.asMap().entries)
        {
          "type": "Feature",
          "properties": {"name": poi.value.name},
          "geometry": {
            "type": "Point",
            "coordinates": [poi.value.lng, poi.value.lat],
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
