import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '/models.dart';

class MapLibreMap extends StatefulWidget {
  const MapLibreMap({super.key, required this.tour});

  final TourModel tour;

  @override
  State<MapLibreMap> createState() => _MapLibreMapState();
}

class _MapLibreMapState extends State<MapLibreMap> {
  late Future<String> mapTilerKey;

  @override
  void initState() {
    super.initState();

    mapTilerKey =
        DefaultAssetBundle.of(context).loadString('assets/maptiler.txt');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: mapTilerKey,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // This is used in the platform side to register the view.
          const String viewType = 'org.evresi.app.MapLibrePlatformView';
          // Pass parameters to the platform side.
          final Map<String, dynamic> creationParams = <String, dynamic>{
            "mapTilerKey": snapshot.data,
            "pathGeoJson": _pathToGeoJson(widget.tour.path),
            "pointsGeoJson": _waypointsToGeoJson(widget.tour.waypoints),
          };

          return AndroidView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
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
