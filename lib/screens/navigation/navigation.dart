import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/controllers/narration_playback.dart';
import '/controllers/navigation.dart';
import '/location.dart';
import '/models.dart';
import '/models/current_location.dart';
import '/screens/navigation/drawer.dart';
import '/screens/navigation/map.dart';
import '/screens/navigation/panel.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int? _currentWaypoint;
  late NavigationController _navController;
  late NarrationPlaybackController _playbackController;
  bool _fakeGpsEnabled = false;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});

  final CurrentLocationModel _currentLocation = CurrentLocationModel();

  final GlobalKey<NavigationDrawerState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _navController = NavigationController(
      path: widget.tour.path,
      waypoints:
          widget.tour.waypoints.map((e) => LatLng(e.lat, e.lng)).toList(),
    );

    _currentLocation.addListener(_onCurrentLocationChanged);

    _startGpsListening();

    _playbackController = NarrationPlaybackController(
      narrations: widget.tour.waypoints.map((e) => e.narration).toList(),
    );
    _playbackController.onPositionChanged.listen((position) {});
  }

  @override
  void dispose() {
    _currentLocation.removeListener(_onCurrentLocationChanged);
    _locationStream.cancel();
    _playbackController.dispose();
    _currentLocation.dispose();

    super.dispose();
  }

  void _startGpsListening() async {
    var stream = await getLocationStream(context);

    if (stream != null) {
      _locationStream.cancel();
      _locationStream = stream.listen((ll) {
        _currentLocation.value = ll;
      });
    }
  }

  void _stopGpsListening() => _locationStream.cancel();

  void _onCurrentLocationChanged() {
    _navController.tick(context, _currentLocation.value).then((waypoint) {
      if (_currentWaypoint != waypoint && waypoint != null) {
        _playbackController.arrivedAtWaypoint(waypoint);
        setState(() => _currentWaypoint = waypoint);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bottomHeight = 88.0;

    return ChangeNotifierProvider<CurrentLocationModel>.value(
      value: _currentLocation,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Navgiating"),
            actions: [
              if (kDebugMode)
                IconButton(
                  onPressed: () {
                    if (!_fakeGpsEnabled) {
                      setState(() => _fakeGpsEnabled = true);
                      _stopGpsListening();
                    } else {
                      setState(() => _fakeGpsEnabled = false);
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
                child: NavigationMap(
                  tour: widget.tour,
                  fakeGpsEnabled: _fakeGpsEnabled,
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: bottomHeight,
                child: NavigationDrawer(key: _drawerKey, tour: widget.tour),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: SizedBox(
                  height: bottomHeight,
                  child: GestureDetector(
                    child: NavigationPanel(
                      playbackController: _playbackController,
                      currentWaypoint: _currentWaypoint,
                      tour: widget.tour,
                    ),
                    onVerticalDragStart: (details) =>
                        _drawerKey.currentState?.onVerticalDragStart(details),
                    onVerticalDragEnd: (details) =>
                        _drawerKey.currentState?.onVerticalDragEnd(details),
                    onVerticalDragUpdate: (details) =>
                        _drawerKey.currentState?.onVerticalDragUpdate(details),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
