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
import '/screens/navigation/disclaimer.dart';
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
  late NavigationController _navController;
  late NarrationPlaybackController _playbackController;
  bool _fakeGpsEnabled = false;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});
  bool _disclaimerShown = false;

  final CurrentLocationModel _currentLocation = CurrentLocationModel();
  final CurrentWaypointModel _currentWaypoint = CurrentWaypointModel();

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
      if (_currentWaypoint.index != waypoint && waypoint != null) {
        _playbackController.arrivedAtWaypoint(waypoint);
        setState(() => _currentWaypoint.index = waypoint);
      }
    });
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
        ChangeNotifierProvider<CurrentLocationModel>.value(
            value: _currentLocation),
        ChangeNotifierProvider.value(value: _currentWaypoint)
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
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: bottomHeight,
                  child: NavigationDrawer(
                    key: _drawerKey,
                    handleHeight: drawerHandleHeight,
                    tour: widget.tour,
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
