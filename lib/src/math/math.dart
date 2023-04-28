import 'dart:math';

import 'package:latlong2/latlong.dart';

LatLng averagePoint(Iterable<LatLng> points) =>
    points.map((p) => p.toVec3()).reduce((a, b) => a + b).toLatLng();

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

  Vec3 operator +(Vec3 other) {
    return Vec3(x + other.x, y + other.y, z + other.z);
  }
}

extension LatLngToVec3Extension on LatLng {
  Vec3 toVec3() => Vec3(
        sin(degToRadian(latitude)) * cos(degToRadian(longitude)),
        sin(degToRadian(latitude)) * sin(degToRadian(longitude)),
        cos(degToRadian(latitude)),
      );
}
