import 'package:evresi/maplibre_native_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/models.dart';
import '/models/current_location.dart';

class NavigationMap extends StatelessWidget {
  const NavigationMap({
    super.key,
    required this.tour,
    required this.fakeGpsEnabled,
  });

  final TourModel tour;
  final bool fakeGpsEnabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /*FlutterMap(
          options: MapOptions(
            center: LatLng(34.000556, -81.034722),
            interactiveFlags: InteractiveFlag.pinchZoom |
                InteractiveFlag.pinchMove |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.drag,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "org.evresi.app",
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: tour.path,
                  strokeWidth: 4,
                  color: Colors.red,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (var waypoint in tour.waypoints.asMap().entries)
                  Marker(
                    point: LatLng(waypoint.value.lat, waypoint.value.lng),
                    builder: (context) => _MarkerIcon(waypoint.key + 1),
                  ),
              ],
            ),
            const _CurrentLocationMarkerLayer(),
            if (kDebugMode && fakeGpsEnabled)
              _FakeGpsPosition(
                onPositionChanged: (ll) {
                  context.read<CurrentLocationModel>().value = ll;
                },
              ),
          ],
        ),*/
        MapLibreMap(),
      ],
    );
  }
}

class _CurrentLocationMarkerLayer extends StatelessWidget {
  const _CurrentLocationMarkerLayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentLocation = context.watch<CurrentLocationModel>();

    return MarkerLayer(
      markers: [
        if (currentLocation.value != null)
          Marker(
            point: currentLocation.value!,
            width: 25,
            height: 25,
            builder: (context) => const DecoratedBox(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 3)),
                  boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black38)]),
            ),
          ),
      ],
    );
  }
}

class _FakeGpsPosition extends StatefulWidget {
  const _FakeGpsPosition({super.key, required this.onPositionChanged});

  final void Function(LatLng) onPositionChanged;

  @override
  State<_FakeGpsPosition> createState() => _FakeGpsPositionState();
}

class _FakeGpsPositionState extends State<_FakeGpsPosition> {
  LatLng _point = LatLng(34.000556, -81.034722);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragMarkers(
      markers: [
        DragMarker(
          width: 128,
          height: 128,
          point: _point,
          builder: (context) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(64)),
              color: _isDragging
                  ? Colors.blue.withAlpha(96)
                  : Colors.blueGrey.withAlpha(32),
            ),
          ),
          useLongPress: true,
          onLongDragStart: (p0, p1) {
            setState(() {
              _isDragging = true;
            });
          },
          onLongDragEnd: (p0, p1) {
            setState(() {
              _point = p1;
              _isDragging = false;
            });
            widget.onPositionChanged(_point);
          },
        ),
      ],
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  const _MarkerIcon(this.number, {super.key});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        border: Border.all(width: 3),
      ),
      child: Center(
          child: Text(
        "$number",
        style:
            Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
      )),
    );
  }
}
