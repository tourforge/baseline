import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/models/current_location.dart';
import '/models/data.dart';
import 'maplibre_native_view.dart';

class NavigationMap extends StatefulWidget {
  const NavigationMap({
    super.key,
    required this.tour,
    required this.fakeGpsEnabled,
  });

  final TourModel tour;
  final bool fakeGpsEnabled;

  @override
  State<NavigationMap> createState() => NavigationMapState();
}

class NavigationMapState extends State<NavigationMap> {
  final GlobalKey<MapLibreMapState> _mapKey = GlobalKey();
  final GlobalKey<_FakeGpsOverlayState> _fakeGpsKey = GlobalKey();

  bool get satelliteEnabled => _mapKey.currentState!.satelliteEnabled;
  set satelliteEnabled(bool value) {
    _mapKey.currentState!.satelliteEnabled = value;
  }

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
