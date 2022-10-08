import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

const _distance = Distance();
const _pathClosenessThresholdMeters = 50;
const _waypointClosenessThresholdMeters = 50;
const _pathExtraClosenessThresholdMeters = 10;
const _dotThreshold = 0;
const _distanceOnPathThresholdMeters = 200;

class NavigationController {
  NavigationController({
    this.path = const <LatLng>[],
    required this.waypointIndexToPathIndex,
    required this.waypoints,
    required this.getLocation,
  });

  final List<LatLng> path;
  final List<int> waypointIndexToPathIndex;
  final List<LatLng> waypoints;
  final Future<LatLng?> Function(BuildContext) getLocation;

  int? _prevWaypoint;
  LatLng? _location;

  void start(BuildContext context) async {
    _location = await getLocation(context);
  }

  Future<int?> tick(BuildContext context) async {
    var prevLocation = _location;
    var location = _location = await getLocation(context);

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
              position: e.value,
              distance: _distance(location, e.value),
            ))
        .where((e) => e.distance < _waypointClosenessThresholdMeters)
        .toList();

    if (nearbyWaypoints.isEmpty) return _prevWaypoint = null;

    // get the nearest/most likely segment along the tour path
    var segment = _nearestPathSegment(prevLocation, location);
    if (segment != null) {
      // if a segment is found, we will decide that, of those waypoints, the
      // user must be at the one that is closest to the path segment that the
      // user is nearest to.
      var closest = nearbyWaypoints
          .map((e) => _WaypointWithIndexAndDistance(
                index: e.index,
                position: e.position,
                distance: (waypointIndexToPathIndex[e.index] < segment
                            ? path.skip(waypointIndexToPathIndex[e.index]).take(
                                segment - waypointIndexToPathIndex[e.index])
                            : path.skip(segment).take(
                                waypointIndexToPathIndex[e.index] - segment))
                        .fold<_PointAndDistance?>(
                            null,
                            (prev, point) => _PointAndDistance(
                                point: point,
                                distance: prev != null
                                    ? prev.distance +
                                        _distance(prev.point, point)
                                    : 0))
                        ?.distance ??
                    0,
              ))
          .reduce((a, b) => a.distance < b.distance ? a : b);

      if (closest.distance < _distanceOnPathThresholdMeters) {
        return _prevWaypoint = closest.index;
      } else {
        return _prevWaypoint = null;
      }
    } else {
      // if we don't know what segment the user is on, just return the closest
      // waypoint.
      return _prevWaypoint = nearbyWaypoints
          .reduce((a, b) => a.distance < b.distance ? a : b)
          .index;
    }
  }

  int? _nearestPathSegment(LatLng? prevLocation, LatLng location) {
    // let's get a list of all segments of the tour path that the user is nearby
    var segments = <_Segment>[];
    for (int i = 0; i < path.length - 1; i++) {
      var distance = distanceToSegment(path[i], path[i + 1], location);
      if (distance < _pathClosenessThresholdMeters) {
        segments.add(_Segment(i, distance));
      }
    }

    // the user isn't near the path
    if (segments.isEmpty) return null;

    // sort these segments in order of increasing distance
    segments.sort((a, b) => a.distance.compareTo(b.distance));

    if (segments.length > 1) {
      // if we have more than one segment, filter out all of the segments with
      // a distance greater than _pathExtraClosenessThresholdMeters, except for
      // the closest segment (in case none of the segments are within
      // _pathExtraClosenessThresholdMeters of the user's location)
      segments = [
        segments.first,
        ...segments.skip(1).where(
            (segment) => segment.distance < _pathExtraClosenessThresholdMeters),
      ];
    }

    if (segments.length > 1) {
      // if we still have more than one segment, let's eliminate some based on
      // how well they match the user's direction of travel, but only if we know
      // the direction of travel

      var userDirection = prevLocation != null
          ? (location.toVector() - prevLocation.toVector()).normalize()
          : null;

      if (userDirection != null) {
        var segmentsWithDot = segments
            .map((e) => _SegmentWithDot(
                  segment: e,
                  dot: (path[e.startIdx + 1].toVector() -
                          path[e.startIdx].toVector())
                      .normalize()
                      .dot(userDirection),
                ))
            .toList()
          ..sort((a, b) => b.dot.compareTo(a.dot)); // descending order

        segments = [
          segmentsWithDot.first.segment,
          ...segmentsWithDot
              .skip(1)
              .where((e) => e.dot < _dotThreshold)
              .map((e) => e.segment),
        ];
      }
    }

    // we reduce it so that if there are still any segments remaining, we choose
    // the earliest one, the one with the smallest index.
    return segments.isNotEmpty
        ? segments.reduce((a, b) => a.startIdx < b.startIdx ? a : b).startIdx
        : null;
  }
}

double distanceToSegment(LatLng l1, LatLng l2, LatLng p) {
  // easy case: segment is a single point
  if (_distance(l1, l2) == 0) {
    return _distance(l1, p);
  }

  // convert all the points to vectors so we can do some linear algebra on them.
  // technically, this is invalid since the Earth is curved, but it should be
  // close enough considering the small scales this will be working on.
  var vl1 = l1.toVector(), vl2 = l2.toVector(), vp = p.toVector();

  // we take the dot product of the vector from the initial point of the line to
  // the test point and the vector from the initial point of the line to the
  // second point of the line. this gives us a number representing how far along
  // the line the closest point on the line to the test point is. we clamp from
  // 0 to 1 because it's a line segment, not an infinite line
  var t = clampDouble((vp - vl1).dot(vl2 - vl1), 0, 1);

  // finally, get the actual projected point and convert it back to a LatLng
  var projected = (vl1 + (vl2 - vl1).scaleBy(t)).toLatLng();

  // return the distance from the test point to the closest point to the test
  // point that lies on the line segment
  return _distance(p, projected);
}

class _Vector {
  _Vector(this.x, this.y);

  final double x;
  final double y;

  LatLng toLatLng() {
    return LatLng(x, y);
  }

  double dot(_Vector other) {
    return x * other.x + y * other.y;
  }

  _Vector scaleBy(double t) {
    return _Vector(t * x, t * y);
  }

  _Vector normalize() {
    var l = length();
    return _Vector(x / l, y / l);
  }

  double length() {
    return sqrt(x * x + y * y);
  }

  _Vector operator +(_Vector other) {
    return _Vector(x + other.x, y + other.y);
  }

  _Vector operator -(_Vector other) {
    return _Vector(x - other.x, y - other.y);
  }
}

extension _LatLngToVectorExtension on LatLng {
  _Vector toVector() => _Vector(latitude, longitude);
}

class _Segment {
  const _Segment(this.startIdx, this.distance);

  final int startIdx;
  final double distance;
}

class _SegmentWithDot {
  const _SegmentWithDot({required this.segment, required this.dot});

  final _Segment segment;
  final double dot;
}

class _WaypointWithIndexAndDistance {
  const _WaypointWithIndexAndDistance({
    required this.index,
    required this.position,
    required this.distance,
  });

  final int index;
  final LatLng position;
  final double distance;
}

class _PointAndDistance {
  const _PointAndDistance({
    required this.point,
    required this.distance,
  });

  final LatLng point;
  final double distance;
}
