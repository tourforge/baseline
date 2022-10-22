import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/maplibre_native_view.dart';
import '/models.dart';
import '/models/current_location.dart';

class NavigationMap extends StatefulWidget {
  const NavigationMap({
    super.key,
    required this.tour,
    required this.fakeGpsEnabled,
  });

  final TourModel tour;
  final bool fakeGpsEnabled;

  @override
  State<NavigationMap> createState() => _NavigationMapState();
}

class _NavigationMapState extends State<NavigationMap> {
  final GlobalKey<MapLibreMapState> _mapKey = GlobalKey();
  final GlobalKey<_FakeGpsOverlayState> _fakeGpsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<CurrentLocationModel>().addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    var location = context.read<CurrentLocationModel>().value;

    if (location != null) {
      _mapKey.currentState?.updateLocation(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MapLibreMap(
        key: _mapKey,
        tour: widget.tour,
        onCameraUpdate: (center, zoom) {
          _fakeGpsKey.currentState?.updateCameraPosition(center, zoom);
        },
        fakeGpsOverlay: kDebugMode
            ? _FakeGpsOverlay(
                key: _fakeGpsKey,
                fakeGpsEnabled: widget.fakeGpsEnabled,
              )
            : const SizedBox(),
      );
    } else {
      return FlutterMap(
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
                points: widget.tour.path,
                strokeWidth: 4,
                color: Colors.red,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              for (var waypoint in widget.tour.waypoints.asMap().entries)
                Marker(
                  point: LatLng(waypoint.value.lat, waypoint.value.lng),
                  builder: (context) => _MarkerIcon(waypoint.key + 1),
                ),
            ],
          ),
          const _CurrentLocationMarkerLayer(),
          if (kDebugMode && widget.fakeGpsEnabled)
            _FakeGpsPosition(
              onPositionChanged: (ll) {
                context.read<CurrentLocationModel>().value = ll;
              },
            ),
        ],
      );
    }
  }
}

// TODO: Implement this overlay *without* FlutterMap
class _FakeGpsOverlay extends StatefulWidget {
  const _FakeGpsOverlay({
    Key? key,
    required this.fakeGpsEnabled,
  }) : super(key: key);

  final bool fakeGpsEnabled;

  @override
  State<_FakeGpsOverlay> createState() => _FakeGpsOverlayState();
}

class _FakeGpsOverlayState extends State<_FakeGpsOverlay> {
  final controller = MapController();

  void updateCameraPosition(LatLng center, double zoom) {
    controller.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(interactiveFlags: InteractiveFlag.none),
      children: [
        if (kDebugMode && widget.fakeGpsEnabled)
          _FakeGpsPosition(
            onPositionChanged: (ll) {
              context.read<CurrentLocationModel>().value = ll;
            },
          ),
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
