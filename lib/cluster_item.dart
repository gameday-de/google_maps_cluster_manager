import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

abstract class ClusterItem {
  LatLng get location;

  String? _geohash;
  String get geohash => _geohash ??= GeoHasher().encode(
        location.longitude,
        location.latitude,
        precision: ClusterManager.precision,
      );
}
