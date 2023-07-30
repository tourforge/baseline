import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

const _distance = Distance();

class NavigationWaypoint {
  const NavigationWaypoint({
    required this.position,
    required this.triggerRadius,
  });

  final LatLng position;
  final double triggerRadius;
}

class NavigationController {
  NavigationController({
    this.path = const <LatLng>[],
    required this.waypoints,
  });

  final List<LatLng> path;
  final List<NavigationWaypoint> waypoints;

  int? _prevWaypoint;
  LatLng? _location;

  Future<int?> tick(BuildContext context, LatLng? location) async {
    var prevLocation = _location;
    _location = location;

    // can't do anything if we don't know the current location
    if (location == null) return null;

    // if current location hasn't changed since the last tick, return the
    // waypoint from the last tick
    if (location == prevLocation) return _prevWaypoint;

    // find the list of waypoints the user is within a threshold of
    var nearbyWaypoints = waypoints
        .asMap()
        .entries
        .map((e) => _WaypointWithIndexAndDistance(
              index: e.key,
              position: e.value.position,
              triggerRadius: e.value.triggerRadius,
              distance: _distance(location, e.value.position),
            ))
        .where((e) => e.distance < e.triggerRadius)
        .toList();

    if (nearbyWaypoints.isNotEmpty) {
      return _prevWaypoint = nearbyWaypoints
          .reduce((a, b) => a.distance < b.distance ? a : b)
          .index;
    } else {
      return _prevWaypoint = null;
    }
  }
}

class _WaypointWithIndexAndDistance {
  const _WaypointWithIndexAndDistance({
    required this.index,
    required this.position,
    required this.triggerRadius,
    required this.distance,
  });

  final int index;
  final LatLng position;
  final double triggerRadius;
  final double distance;
}
