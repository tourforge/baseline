import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/models/current_location.dart';
import '/models/data.dart';
import '/models/fake_gps.dart';
import '/models/map_controlledness.dart';
import '/models/satellite_enabled.dart';
import 'maplibre_map.dart';

class NavigationMapController {
  NavigationMapState? _state;

  void moveCamera(LatLng where) {
    _state?._mapController.moveCamera(where);
  }

  CustomPoint<num>? latLngToScreenPoint(LatLng latLng) {
    return _state?._fakeGpsKey.currentState?.latLngToScreenPoint(latLng);
  }
}

class NavigationMap extends StatefulWidget {
  const NavigationMap({
    super.key,
    required this.tour,
    required this.controller,
    required this.onCameraMove,
    required this.onMoveUpdate,
    required this.onMoveBegin,
    required this.onMoveEnd,
  });

  final TourModel tour;
  final NavigationMapController controller;
  final void Function(LatLng) onCameraMove;
  final void Function() onMoveUpdate;
  final void Function() onMoveBegin;
  final void Function() onMoveEnd;

  @override
  State<NavigationMap> createState() => NavigationMapState();
}

class NavigationMapState extends State<NavigationMap> {
  final MapLibreMapController _mapController = MapLibreMapController();
  final GlobalKey<_FakeGpsOverlayState> _fakeGpsKey = GlobalKey();
  late final void Function() removeListeners;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;

    var currentLocation = context.read<CurrentLocationModel>();
    var satelliteEnabled = context.read<SatelliteEnabledModel>();
    currentLocation.addListener(_onLocationChanged);
    satelliteEnabled.addListener(_onSatelliteEnabledChanged);
    removeListeners = () {
      currentLocation.removeListener(_onLocationChanged);
      satelliteEnabled.removeListener(_onSatelliteEnabledChanged);
    };
  }

  @override
  void dispose() {
    removeListeners();
    super.dispose();
  }

  void _onSatelliteEnabledChanged() {
    _mapController.satelliteEnabled =
        context.read<SatelliteEnabledModel>().value;
  }

  void _onLocationChanged() {
    if (!mounted) return;

    var location = context.read<CurrentLocationModel>().value;

    if (location != null) {
      _mapController.updateLocation(location);
      if (context.read<MapControllednessModel>().value) {
        _mapController.moveCamera(location);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      tour: widget.tour,
      controller: _mapController,
      onMoveUpdate: widget.onMoveUpdate,
      onMoveBegin: widget.onMoveBegin,
      onMoveEnd: widget.onMoveEnd,
      onCameraUpdate: (center, zoom) {
        _fakeGpsKey.currentState?.updateCameraPosition(center, zoom);
        widget.onCameraMove(center);
      },
      fakeGpsOverlay:
          kDebugMode ? _FakeGpsOverlay(key: _fakeGpsKey) : const SizedBox(),
    );
  }
}

// TODO: Implement this overlay *without* FlutterMap
class _FakeGpsOverlay extends StatefulWidget {
  const _FakeGpsOverlay({Key? key}) : super(key: key);

  @override
  State<_FakeGpsOverlay> createState() => _FakeGpsOverlayState();
}

class _FakeGpsOverlayState extends State<_FakeGpsOverlay> {
  final controller = MapController();

  void updateCameraPosition(LatLng center, double zoom) {
    controller.move(center, zoom);
  }

  CustomPoint<num>? latLngToScreenPoint(LatLng latLng) {
    return controller.latLngToScreenPoint(latLng);
  }

  @override
  Widget build(BuildContext context) {
    var fakeGpsEnabled = context.watch<FakeGpsModel>();

    return FlutterMap(
      mapController: controller,
      options: MapOptions(interactiveFlags: InteractiveFlag.none),
      children: [
        if (kDebugMode && fakeGpsEnabled.value)
          _FakeGpsPosition(
            onPositionChanged: (ll) {
              context.read<CurrentLocationModel>().value = ll;
            },
          ),
      ],
    );
  }
}

class _FakeGpsPosition extends StatefulWidget {
  const _FakeGpsPosition({required this.onPositionChanged});

  final void Function(LatLng) onPositionChanged;

  @override
  State<_FakeGpsPosition> createState() => _FakeGpsPositionState();
}

class _FakeGpsPositionState extends State<_FakeGpsPosition> {
  LatLng _point = LatLng(34.183889, -79.774167);
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
          width: 64,
          height: 64,
          point: _point,
          builder: (context) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(32.0)),
              border: Border.all(
                color: Colors.orange.withAlpha(128),
                width: 3.0,
              ),
              color: _isDragging
                  ? Colors.blue.withAlpha(64)
                  : Colors.orange.withAlpha(32),
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
