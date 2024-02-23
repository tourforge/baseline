import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourforge/src/help_viewed.dart';
import 'package:provider/provider.dart';

import '../../controllers/narration_playback.dart';
import '../../controllers/navigation.dart';
import '../../data.dart';
import '../../location.dart';
import '../../models/current_location.dart';
import '../../models/current_waypoint.dart';
import '../../models/fake_gps.dart';
import '../../models/map_controlledness.dart';
import '../../models/satellite_enabled.dart';
import '../../screens/navigation/drawer.dart';
import '../../screens/navigation/help.dart';
import '../../screens/navigation/map.dart';
import '../../screens/navigation/panel.dart';
import '../../screens/poi_details.dart';
import '../../screens/waypoint_details.dart';
import 'attribution.dart';

class NavigationRoute extends PopupRoute {
  NavigationRoute(this.tour);

  final TourModel tour;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: DisclaimerScreen(tour),
    );
  }
}

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Remember to obey the law and pay attention to '
              'your surroundings while driving.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Container(
            color: const Color(0xFFE8F7E1),
            child: LayoutBuilder(builder: (context, constraints) {
              // manual calculation of width and height required to avoid layout
              // shift. :)
              const aspect = 1285.0 / 1985.0;
              final width = constraints.maxWidth;
              final height = width * aspect;
              return Image.asset(
                "assets/traffic.png",
                package: "tourforge",
                width: width,
                height: height,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('I understand'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => NavigationScreen(tour)));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationMapController _mapController = NavigationMapController();
  final StreamController<void> _userInteract = StreamController.broadcast();

  final FakeGpsModel _fakeGps = FakeGpsModel();
  final CurrentLocationModel _currentLocation = CurrentLocationModel();
  final CurrentWaypointModel _currentWaypoint = CurrentWaypointModel();
  final MapControllednessModel _mapControlledness = MapControllednessModel();
  final SatelliteEnabledModel _satelliteEnabled = SatelliteEnabledModel();

  final GlobalKey<TourNavigationDrawerState> _drawerKey = GlobalKey();

  late NavigationController _navController;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});
  LatLng _cameraLocation = LatLng(0, 0);

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

    _fakeGps.addListener(_onFakeGpsChanged);
    _currentLocation.addListener(_onCurrentLocationChanged);
    _currentWaypoint.addListener(_onCurrentWaypointChanged);
    _mapControlledness.addListener(_onMapControllednessChanged);
    _satelliteEnabled.addListener(_onSatelliteEnabledChanged);

    NarrationPlaybackController.instance.tour = widget.tour;

    _startGpsListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    (() async {
      if (!await HelpViewed.viewed("navigation")) {
        _launchHelp();
      }
    })();
  }

  @override
  void dispose() {
    _fakeGps.removeListener(_onFakeGpsChanged);
    _currentLocation.removeListener(_onCurrentLocationChanged);
    _currentWaypoint.removeListener(_onCurrentWaypointChanged);
    _mapControlledness.removeListener(_onMapControllednessChanged);
    _satelliteEnabled.removeListener(_onSatelliteEnabledChanged);
    _locationStream.cancel();
    _currentLocation.dispose();

    NarrationPlaybackController.instance.reset();

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

  void _onFakeGpsChanged() {
    if (_fakeGps.value) {
      _stopGpsListening();
    } else {
      _startGpsListening();
    }
  }

  void _onCurrentLocationChanged() {
    _navController.tick(context, _currentLocation.value).then((waypoint) {
      if (_currentWaypoint.index != waypoint && waypoint != null) {
        _currentWaypoint.index = waypoint;
      }
    });
  }

  void _onCurrentWaypointChanged() {
    if (_currentWaypoint.index != null) {
      NarrationPlaybackController.instance
          .playWaypoint(_currentWaypoint.index!);
    }
  }

  void _onMapControllednessChanged() {
    if (_mapControlledness.value && _currentLocation.value != null) {
      _mapController.moveCamera(_currentLocation.value!);
    }
  }

  void _onSatelliteEnabledChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const bottomHeight = 88.0;
    const drawerHandleHeight = 28.0;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _fakeGps),
        ChangeNotifierProvider.value(value: _currentLocation),
        ChangeNotifierProvider.value(value: _currentWaypoint),
        ChangeNotifierProvider.value(value: _mapControlledness),
        ChangeNotifierProvider.value(value: _satelliteEnabled),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _satelliteEnabled.value
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: NavigationMap(
                  controller: _mapController,
                  tour: widget.tour,
                  onCameraMove: (cameraLocation) {
                    _cameraLocation = cameraLocation;
                  },
                  onMoveUpdate: () {
                    _userInteract.add(null);

                    if (_currentLocation.value == null) return;

                    var a = _mapController
                        .latLngToScreenPoint(_currentLocation.value!)!;
                    var b =
                        _mapController.latLngToScreenPoint(_cameraLocation)!;

                    if (a.distanceTo(b) > 48) {
                      _mapControlledness.value = false;
                    }
                  },
                  onMoveBegin: () {},
                  onMoveEnd: () {
                    if (_mapControlledness.value &&
                        _currentLocation.value != null) {
                      _mapController.moveCamera(_currentLocation.value!);
                    }
                  },
                  onPointClick: (index) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            WaypointDetails(widget.tour.waypoints[index])));
                  },
                  onPoiClick: (index) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PoiDetails(widget.tour.pois[index])));
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
                        color: Theme.of(context).colorScheme.secondary,
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
                                            .onSecondary,
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
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      color: Theme.of(context).colorScheme.secondary,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          iconSize: 32,
                          splashRadius: 30,
                          color: Theme.of(context).colorScheme.onSecondary,
                          icon: const Icon(Icons.arrow_back),
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
                    child: _HelpButton(
                      onPressed: _launchHelp,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: bottomHeight + drawerHandleHeight,
                left: 0.0,
                child: SafeArea(
                  child: AttributionInfo(
                    userInteract: _userInteract.stream,
                  ),
                ),
              ),
              if (kDebugMode)
                const Positioned(
                  bottom: bottomHeight + drawerHandleHeight + 72 * 2,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _FakeGpsButton(),
                    ),
                  ),
                ),
              const Positioned(
                bottom: bottomHeight + drawerHandleHeight + 72,
                right: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: _SatelliteEnabledButton(),
                  ),
                ),
              ),
              const Positioned(
                bottom: bottomHeight + drawerHandleHeight,
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
                child: SafeArea(
                  child: TourNavigationDrawer(
                    key: _drawerKey,
                    handleHeight: drawerHandleHeight,
                    tour: widget.tour,
                    playWaypoint: (waypointIdx) {
                      _currentWaypoint.index = waypointIdx;
                      NarrationPlaybackController.instance
                          .playWaypoint(waypointIdx);
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: SafeArea(
                  child: SizedBox(
                    height: bottomHeight,
                    child: GestureDetector(
                      child: NavigationPanel(tour: widget.tour),
                      onVerticalDragStart: (details) =>
                          _drawerKey.currentState?.onVerticalDragStart(details),
                      onVerticalDragEnd: (details) =>
                          _drawerKey.currentState?.onVerticalDragEnd(details),
                      onVerticalDragUpdate: (details) => _drawerKey.currentState
                          ?.onVerticalDragUpdate(details),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchHelp() {
    HelpViewed.markViewed("navigation");
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NavigationHelpScreen()));
  }
}

class _SatelliteEnabledButton extends StatelessWidget {
  const _SatelliteEnabledButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var satelliteEnabled = context.watch<SatelliteEnabledModel>();

    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      color: const Color.fromARGB(255, 48, 48, 48),
      child: SizedBox(
        width: 60,
        height: 60,
        child: IconButton(
          onPressed: () {
            satelliteEnabled.value = !satelliteEnabled.value;
          },
          iconSize: 32,
          splashRadius: 30,
          color: Theme.of(context).colorScheme.onSecondary,
          icon: satelliteEnabled.value
              ? const Icon(Icons.layers_clear)
              : const Icon(Icons.layers),
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({Key? key, required this.onPressed}) : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      color: Theme.of(context).colorScheme.secondary,
      child: SizedBox(
        width: 60,
        height: 60,
        child: IconButton(
          onPressed: onPressed,
          iconSize: 32,
          splashRadius: 30,
          color: Theme.of(context).colorScheme.onSecondary,
          icon: const Icon(Icons.question_mark),
        ),
      ),
    );
  }
}

class _FakeGpsButton extends StatelessWidget {
  const _FakeGpsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      color: const Color.fromARGB(255, 48, 48, 48),
      child: SizedBox(
        width: 60,
        height: 60,
        child: IconButton(
          onPressed: () {
            var fakeGps = context.read<FakeGpsModel>();

            fakeGps.value = !fakeGps.value;
          },
          iconSize: 32,
          splashRadius: 30,
          color: Theme.of(context).colorScheme.onSecondary,
          icon: const Icon(Icons.bug_report),
        ),
      ),
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

    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      color: const Color.fromARGB(255, 48, 48, 48),
      child: SizedBox(
        width: 60,
        height: 60,
        child: IconButton(
          onPressed: () {
            mapControlledness.value = !mapControlledness.value;
          },
          iconSize: 32,
          splashRadius: 30,
          color: Theme.of(context).colorScheme.onSecondary,
          icon: mapControlledness.value
              ? const Icon(Icons.gps_fixed)
              : const Icon(Icons.gps_not_fixed),
        ),
      ),
    );
  }
}
