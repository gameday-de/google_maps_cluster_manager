import 'dart:math';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class _Tuple {
  _Tuple(this.pos1, this.pos2);
  final LatLng pos1;
  final LatLng pos2;

  bool operator ==(o) => o is _Tuple && pos1 == o.pos1 && pos2 == o.pos2;
  int get hashCode => pos1.hashCode + pos2.hashCode;
}

class DistUtils {
  final Map<_Tuple, double> distCache = {};

  double getLatLonDist(LatLng point1, LatLng point2) {
    if (distCache[_Tuple(point1, point2)] != null) {
      return distCache[_Tuple(point1, point2)]!;
    }
    double dist = haversineDistance(
        point1.latitude, point1.longitude, point2.latitude, point2.longitude);

    distCache[_Tuple(point1, point2)] = dist;
    return dist;
  }

  double haversineDistance(double lat, double lng, double lat0, double lng0) {
    var R = 6371; // Radius of the earth in km
    var dLat = _degreeToRadian(lat0 - lat);
    var dLon = _degreeToRadian(lng0 - lng);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat)) *
            cos(_degreeToRadian(lat0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double euclideanDistance(double lat, double lng, double lat0, double lng0) {
    final deglen = 110.25;
    final x = lat - lat0;
    final y = (lng - lng0) * cos(lat0);
    return deglen * sqrt(pow(x, 2) + pow(y, 2));
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  double zoom2meterPerPixel(double zoomLevel) {
    int base = 156412;
    return base / (pow(zoomLevel + 1, 2));
  }
}
