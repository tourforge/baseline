import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/controllers/narration_playback.dart';
import '/controllers/navigation.dart';
import '/location.dart';
import '/models/current_location.dart';
import '/models/current_waypoint.dart';
import '/models/data.dart';
import '/models/map_controlledness.dart';
import '/screens/navigation/disclaimer.dart';
import '/screens/navigation/drawer.dart';
import '/screens/navigation/map.dart';
import '/screens/navigation/panel.dart';
import 'attribution.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late NavigationController _navController;
  late NarrationPlaybackController _playbackController;
  bool _fakeGpsEnabled = false;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});
  bool _disclaimerShown = false;
  LatLng _cameraLocation = LatLng(0, 0);

  final CurrentLocationModel _currentLocation = CurrentLocationModel();
  final CurrentWaypointModel _currentWaypoint = CurrentWaypointModel();
  final MapControllednessModel _mapControlledness = MapControllednessModel();

  final GlobalKey<NavigationDrawerState> _drawerKey = GlobalKey();
  final GlobalKey<NavigationMapState> _mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _navController = NavigationController(
      path: widget.tour.path,
      waypoints: widget.tour.waypoints
          .map((e) => NavigationWaypoint(
                position: LatLng(e.lat, e.lng),
                triggerRadius: e.triggerRadius,
              ))
          .toList(),
    );

    _currentLocation.addListener(_onCurrentLocationChanged);
    _mapControlledness.addListener(_onMapControllednessChanged);

    _startGpsListening();

    _playbackController = NarrationPlaybackController(
      narrations: widget.tour.waypoints.map((e) => e.narration).toList(),
    );
    _playbackController.onPositionChanged.listen((position) {});
  }

  @override
  void dispose() {
    _currentLocation.removeListener(_onCurrentLocationChanged);
    _mapControlledness.removeListener(_onMapControllednessChanged);
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
      if (_currentWaypoint.index != waypoint && waypoint != null) {
        _playbackController.play(waypoint);
        setState(() => _currentWaypoint.index = waypoint);
      }
    });
  }

  void _onMapControllednessChanged() {
    if (_mapControlledness.value && _currentLocation.value != null) {
      _mapKey.currentState?.moveCamera(_currentLocation.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bottomHeight = 88.0;
    const drawerHandleHeight = 28.0;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_disclaimerShown) {
        _disclaimerShown = true;
        showDisclaimer(context);
      }
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _currentLocation),
        ChangeNotifierProvider.value(value: _currentWaypoint),
        ChangeNotifierProvider.value(value: _mapControlledness),
      ],
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _mapKey.currentState != null &&
                  _mapKey.currentState!.satelliteEnabled
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: bottomHeight + drawerHandleHeight,
                  child: NavigationMap(
                    key: _mapKey,
                    tour: widget.tour,
                    fakeGpsEnabled: _fakeGpsEnabled,
                    onCameraMove: (cameraLocation) {
                      _cameraLocation = cameraLocation;
                    },
                    onMoveUpdate: () {
                      if (_currentLocation.value == null) return;

                      var a = _mapKey.currentState!
                          .latLngToScreenPoint(_currentLocation.value!)!;
                      var b = _mapKey.currentState!
                          .latLngToScreenPoint(_cameraLocation)!;

                      if (a.distanceTo(b) > 48) {
                        _mapControlledness.value = false;
                      }
                    },
                    onMoveBegin: () {},
                    onMoveEnd: () {
                      if (_mapControlledness.value &&
                          _currentLocation.value != null) {
                        _mapKey.currentState
                            ?.moveCamera(_currentLocation.value!);
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 5.0,
                  left: 0.0,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Material(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Navigating",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontSize: 22,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(context).colorScheme.primary,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            iconSize: 32,
                            splashRadius: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                            icon: Icon(Icons.adaptive.arrow_back),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(context).colorScheme.primary,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: IconButton(
                            onPressed: () {
                              _mapKey.currentState!.satelliteEnabled =
                                  !_mapKey.currentState!.satelliteEnabled;
                              setState(() {});
                            },
                            iconSize: 32,
                            splashRadius: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                            icon: _mapKey.currentState != null &&
                                    _mapKey.currentState!.satelliteEnabled
                                ? const Icon(Icons.layers_clear)
                                : const Icon(Icons.layers),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: bottomHeight + drawerHandleHeight,
                  left: 0.0,
                  child: SafeArea(
                    child: AttributionInfo(),
                  ),
                ),
                if (kDebugMode)
                  Positioned(
                    bottom: bottomHeight + drawerHandleHeight,
                    right: 0.0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          color: Colors.red.withAlpha(128),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: IconButton(
                              onPressed: () {
                                if (!_fakeGpsEnabled) {
                                  setState(() => _fakeGpsEnabled = true);
                                  _stopGpsListening();
                                } else {
                                  setState(() => _fakeGpsEnabled = false);
                                  _startGpsListening();
                                }
                              },
                              iconSize: 32,
                              splashRadius: 30,
                              color: Colors.black,
                              icon: const Icon(Icons.bug_report),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const Positioned(
                  bottom: bottomHeight + drawerHandleHeight + 100,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _MapControllednessButton(),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: bottomHeight,
                  child: NavigationDrawer(
                    key: _drawerKey,
                    handleHeight: drawerHandleHeight,
                    tour: widget.tour,
                    playWaypoint: (waypointIdx) {
                      setState(() => _currentWaypoint.index = waypointIdx);
                      _playbackController.play(waypointIdx);
                    },
                  ),
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
                        currentWaypoint: _currentWaypoint.index,
                        tour: widget.tour,
                      ),
                      onVerticalDragStart: (details) =>
                          _drawerKey.currentState?.onVerticalDragStart(details),
                      onVerticalDragEnd: (details) =>
                          _drawerKey.currentState?.onVerticalDragEnd(details),
                      onVerticalDragUpdate: (details) => _drawerKey.currentState
                          ?.onVerticalDragUpdate(details),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapControllednessButton extends StatefulWidget {
  const _MapControllednessButton();

  @override
  State<_MapControllednessButton> createState() =>
      _MapControllednessButtonState();
}

class _MapControllednessButtonState extends State<_MapControllednessButton> {
  @override
  Widget build(BuildContext context) {
    var mapControlledness = context.watch<MapControllednessModel>();

    if (!mapControlledness.value) {
      return Material(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        color: mapControlledness.value
            ? Colors.blue.withAlpha(64)
            : Colors.blue.withAlpha(128),
        child: SizedBox(
          width: 60,
          height: 60,
          child: IconButton(
            onPressed: () {
              mapControlledness.value = true;
            },
            iconSize: 32,
            splashRadius: 30,
            color: mapControlledness.value
                ? Colors.black.withAlpha(128)
                : Colors.black,
            icon: mapControlledness.value
                ? const Icon(Icons.gps_fixed)
                : const Icon(Icons.gps_not_fixed),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
