import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:latlong2/latlong.dart';

import '/controllers/navigation.dart';
import '/location.dart';
import '/models.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

const _distance = Distance();

class _NavigationScreenState extends State<NavigationScreen> {
  double played = 0;
  int? currentWaypoint;
  late NavigationController _navController;
  late Timer _controllerTickTimer;

  GlobalKey<_FakeGpsPositionState>? _fakeGpsKey;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    var waypoints = <int>[];

    for (var waypoint in widget.tour.waypoints.asMap().entries) {
      var waypointLatLng = LatLng(waypoint.value.lat, waypoint.value.lng);
      var closest = 0;
      var closestDistance = _distance(waypointLatLng, widget.tour.path[0]);
      for (var i = 1; i < widget.tour.path.length; i++) {
        var distance = _distance(waypointLatLng, widget.tour.path[i]);
        if (distance < closestDistance) {
          closest = i;
          closestDistance = distance;
        }
      }
      waypoints.add(closest);
    }

    _navController = NavigationController(
      path: widget.tour.path,
      waypointIndexToPathIndex: waypoints,
      waypoints:
          widget.tour.waypoints.map((e) => LatLng(e.lat, e.lng)).toList(),
      getLocation: (context) async => _currentLocation,
    );

    _controllerTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _navController
            .tick(context)
            .then((waypoint) => setState(() => currentWaypoint = waypoint));
      } else {
        timer.cancel();
      }
    });

    _startGpsListening();
  }

  @override
  void dispose() {
    _controllerTickTimer.cancel();
    _locationStream.cancel();

    super.dispose();
  }

  void _startGpsListening() async {
    var stream = await getLocationStream(context);

    if (stream != null) {
      _locationStream.cancel();
      _locationStream = stream.listen((ll) {
        setState(() => _currentLocation = ll);
      });
    }
  }

  void _stopGpsListening() => _locationStream.cancel();

  @override
  Widget build(BuildContext context) {
    const bottomHeight = 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Navgiating"),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () {
                if (_fakeGpsKey == null) {
                  setState(() => _fakeGpsKey = GlobalKey());
                  _stopGpsListening();
                } else {
                  setState(() => _fakeGpsKey = null);
                  _startGpsListening();
                }
              },
              icon: const Icon(Icons.bug_report),
              tooltip: "Enable fake GPS debug mode",
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: bottomHeight,
            child: FlutterMap(
              options: MapOptions(
                interactiveFlags:
                    InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                if (kDebugMode && _fakeGpsKey != null)
                  _FakeGpsPosition(
                    key: _fakeGpsKey,
                    onPositionChanged: (ll) {
                      setState(() => _currentLocation = ll);
                    },
                  ),
                IgnorePointer(
                  ignoring: kDebugMode && _fakeGpsKey != null,
                  child: MarkerLayer(
                    markers: [
                      if (_currentLocation != null)
                        Marker(
                            point: _currentLocation!,
                            width: 25,
                            height: 25,
                            builder: (context) => const DecoratedBox(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                      border: Border.fromBorderSide(BorderSide(
                                          color: Colors.white, width: 3)),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 3,
                                            color: Colors.black38)
                                      ]),
                                )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: SizedBox(
              height: bottomHeight,
              child: Material(
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0)
                          .add(const EdgeInsets.symmetric(horizontal: 16.0)),
                      child: currentWaypoint != null
                          ? Text("Current waypoint: ${currentWaypoint! + 1}")
                          : const Text("Not at waypoint"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Slider(
                        value: played,
                        min: 0,
                        max: 1,
                        onChanged: (value) => setState(() => played = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: bottomHeight - 45,
            child: Center(
              child: SizedBox(
                height: 90,
                width: 90,
                child: Material(
                  shape: const CircleBorder(),
                  color: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    splashRadius: 45,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
          point: _point,
          builder: (context) => Container(
            color: _isDragging ? Colors.blue : Colors.blueGrey,
          ),
          useLongPress: true,
          onLongDragStart: (p0, p1) {
            setState(() {
              _point = p1;
              _isDragging = true;
            });
            widget.onPositionChanged(_point);
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
