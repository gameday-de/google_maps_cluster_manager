import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

enum DistanceType { EUCLIDEAN, HAVERSINE }

class DistUtils {
  final Map<_Tuple, double> distCache = {};

  double getLatLonDist(
    LatLng point1,
    LatLng point2, {
    DistanceType type = DistanceType.HAVERSINE,
  }) {
    if (distCache[_Tuple(point1, point2)] != null) {
      return distCache[_Tuple(point1, point2)]!;
    }

    double dist;
    if (type == DistanceType.HAVERSINE) {
      dist = haversineDistance(
        point1.latitude,
        point1.longitude,
        point2.latitude,
        point2.longitude,
      );
    } else {
      dist = euclideanDistance(
        point1.latitude,
        point1.longitude,
        point2.latitude,
        point2.longitude,
      );
    }

    distCache[_Tuple(point1, point2)] = dist;
    return dist;
  }

  static double haversineDistance(
      double lat, double lng, double lat0, double lng0) {
    var R = 6371; // Radius of the earth in km
    var dLat = degreeToRadian(lat0 - lat);
    var dLon = degreeToRadian(lng0 - lng);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreeToRadian(lat)) *
            cos(degreeToRadian(lat0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  static double euclideanDistance(
      double lat, double lng, double lat0, double lng0) {
    final deglen = 110.25;
    final x = lat - lat0;
    final y = (lng - lng0) * cos(lat0);
    return deglen * sqrt(pow(x, 2) + pow(y, 2));
  }

  static double degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  static double zoom2meterPerPixel(double zoomLevel) {
    int base = 156412;
    return base / (pow(zoomLevel + 1, 2));
  }

  static double boundsPercent2km(LatLngBounds bounds, double percent) {
    var ne = bounds.northeast;
    var nw = LatLng(bounds.northeast.latitude, bounds.southwest.longitude);
    var dist =
        haversineDistance(ne.latitude, ne.longitude, nw.latitude, nw.longitude);

    return dist * percent / 100;
  }
}

class _Tuple {
  _Tuple(this.pos1, this.pos2);
  final LatLng pos1;
  final LatLng pos2;

  bool operator ==(o) => o is _Tuple && pos1 == o.pos1 && pos2 == o.pos2;
  int get hashCode => pos1.hashCode + pos2.hashCode;
}
