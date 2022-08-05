import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager/utils/distance_utils.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group('test get_distance of coordinates', () {
    test(
        'should get dist of between 600m and 800m on call with close coordinates',
        () {
      LatLng start = LatLng(52.421327, 10.623056);
      LatLng end = LatLng(52.42748887594039, 10.623379056822062);
      double dist = DistUtils.haversineDistance(
          start.latitude, start.longitude, end.latitude, end.longitude);
      debugPrint('dist is $dist');
      expect(dist >= 0.6 && dist <= 0.8, true);
    });

    test(
        'should get dist of between 75km and 80km on call with wider coordinates',
        () {
      LatLng start = LatLng(52.45175365359977, 10.679139941065786);
      LatLng end = LatLng(51.7578902763405, 10.74257578002594);
      double dist = DistUtils.haversineDistance(
          start.latitude, start.longitude, end.latitude, end.longitude);
      debugPrint('dist is $dist');
      expect(dist >= 75 && dist <= 80, true);
    });
  });
}
