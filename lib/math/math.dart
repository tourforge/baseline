import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

const _distance = Distance();

double pointDistanceToGeoSegment(LatLng l1, LatLng l2, LatLng p) {
  // easy case: segment is a single point
  if (_distance(l1, l2) == 0) {
    return _distance(l1, p);
  }

  // convert all the points to vectors so we can do some linear algebra on them.
  // technically, this is invalid since the Earth is curved, but it should be
  // close enough considering the small scales this will be working on.
  var vl1 = l1.toVec3(), vl2 = l2.toVec3(), vp = p.toVec3();

  var u = vl2 - vl1;

  // we take the dot product of the vector from the initial point of the line to
  // the test point and the vector from the initial point of the line to the
  // second point of the line. this gives us a number representing how far along
  // the line the closest point on the line to the test point is. we clamp from
  // 0 to 1 because it's a line segment, not an infinite line
  var t = clampDouble(u.dot(vp) / u.dot(u), 0, 1);

  // finally, get the actual projected point and convert it back to a LatLng
  var projected = (vl1 + u.scaleBy(t)).toLatLng();

  // return the distance from the test point to the closest point to the test
  // point that lies on the line segment
  return _distance(p, projected);
}

LatLng averagePoint(Iterable<LatLng> points) =>
    points.map((p) => p.toVec3()).reduce((a, b) => a + b).toLatLng();

GeoBox pathGeoBox(Iterable<LatLng> points) {
  return const GeoBox(0, 0);
}

class GeoBox {
  const GeoBox(this.width, this.height);

  final double width;
  final double height;
}

class Vec3 {
  Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  LatLng toLatLng() {
    var lat = atan(sqrt(x * x + y * y) / z);
    var lng = double.nan;
    if (x > 0) {
      lng = atan(y / x);
    } else if (x < 0 && y >= 0) {
      lng = atan(y / x) + pi;
    } else if (x < 0 && y < 0) {
      lng = atan(y / x) - pi;
    } else if (x == 0 && y > 0) {
      lng = pi / 2;
    } else if (x == 0 && y < 0) {
      lng = -pi / 2;
    }

    return LatLng(radianToDeg(lat), radianToDeg(lng));
  }

  double dot(Vec3 other) {
    return x * other.x + y * other.y + z * other.z;
  }

  Vec3 scaleBy(double t) {
    return Vec3(t * x, t * y, t * z);
  }

  Vec3 normalize() {
    var l = length();
    return Vec3(x / l, y / l, z / l);
  }

  double length() {
    return sqrt(x * x + y * y + z * z);
  }

  Vec3 operator +(Vec3 other) {
    return Vec3(x + other.x, y + other.y, z + other.z);
  }

  Vec3 operator -(Vec3 other) {
    return Vec3(x - other.x, y - other.y, z - other.z);
  }
}

extension LatLngToVec3Extension on LatLng {
  Vec3 toVec3() => Vec3(
        sin(degToRadian(latitude)) * cos(degToRadian(longitude)),
        sin(degToRadian(latitude)) * sin(degToRadian(longitude)),
        cos(degToRadian(latitude)),
      );
}
