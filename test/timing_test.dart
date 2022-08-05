import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager/algorithms/cluster_algorithm.dart';
import 'package:google_maps_cluster_manager/algorithms/distance_clustering.dart';
import 'package:google_maps_cluster_manager/algorithms/geohash_clustering.dart';
import 'package:google_maps_cluster_manager/cluster_item.dart';
import 'package:google_maps_cluster_manager/utils/distance_utils.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class Place with ClusterItem {
  Place(this.latLng);
  final LatLng latLng;
  @override
  LatLng get location => latLng;
}

List<ClusterItem> getItems({int scale = 10}) {
  return [
    for (int i = 0; i < scale; i++)
      Place(LatLng(48.848200 + i * 0.001, 2.319124 + i * 0.001)),
    for (int i = 0; i < scale; i++)
      Place(LatLng(48.858265 - i * 0.001, 2.350107 + i * 0.001)),
    for (int i = 0; i < scale; i++)
      Place(LatLng(48.858265 + i * 0.01, 2.350107 - i * 0.01)),
    for (int i = 0; i < scale; i++)
      Place(LatLng(48.858265 - i * 0.1, 2.350107 - i * 0.01)),
    for (int i = 0; i < scale; i++)
      Place(LatLng(66.160507 + i * 0.1, -153.369141 + i * 0.1)),
    for (int i = 0; i < scale; i++)
      Place(LatLng(-36.848461 + i * 1, 169.763336 + i * 1)),
  ];
}

var bounds = LatLngBounds(
  southwest: LatLng(48.7648185807006, 2.2878488525748253),
  northeast: LatLng(48.948239438634516, 2.4165948852896686),
);

void main() {
  group('test timing of distance computation', () {
    test('Haversine distance', () {
      final stopwatch = Stopwatch()..start();
      DistUtils.haversineDistance(
        bounds.northeast.latitude,
        bounds.northeast.longitude,
        bounds.southwest.latitude,
        bounds.southwest.longitude,
      );
      print('haversineDistance executed in ${stopwatch.elapsed}');
    });

    test('Euclidean distance', () {
      final stopwatch = Stopwatch()..start();
      DistUtils.euclideanDistance(
        bounds.northeast.latitude,
        bounds.northeast.longitude,
        bounds.southwest.latitude,
        bounds.southwest.longitude,
      );
      print('haversineDistance executed in ${stopwatch.elapsed}');
    });
  });

  group('test timing of cluster algorithms', () {
    var scale = 200;
    var distParams = DistanceParams(fixed: true, epsilon: 100);

    test('GEOHASH algorithm', () {
      var items = getItems(scale: scale);
      final stopwatch = Stopwatch()..start();
      GeohashClustering(ClusterAlgorithmType.GEOHASH, 20).run(items);
      print('GEOHASH executed in ${stopwatch.elapsed}');
    });

    test('DIST_AGGLO_HAVERSINE algorithm', () {
      var items = getItems(scale: scale);
      final stopwatch = Stopwatch()..start();
      DistanceClustering(
        ClusterAlgorithmType.DIST_AGGLO_HAVERSINE,
        distParams,
        bounds,
      ).run(items);
      print('DIST_AGGLO_HAVERSINE executed in ${stopwatch.elapsed}');
    });

    test('DIST_AGGLO_SIMPLIFIED algorithm', () {
      var items = getItems(scale: scale);
      final stopwatch = Stopwatch()..start();
      DistanceClustering(
        ClusterAlgorithmType.DIST_AGGLO_SIMPLIFIED,
        distParams,
        bounds,
      ).run(items);
      print('DIST_AGGLO_SIMPLIFIED executed in ${stopwatch.elapsed}');
    });

    test('DIST_GREEDY_HAVERSINE algorithm', () {
      var items = getItems(scale: scale);
      final stopwatch = Stopwatch()..start();
      DistanceClustering(
        ClusterAlgorithmType.DIST_GREEDY_HAVERSINE,
        distParams,
        bounds,
      ).run(items);
      print('DIST_GREEDY_HAVERSINE executed in ${stopwatch.elapsed}');
    });

    test('DIST_GREEDY_SIMPLIFIED algorithm', () {
      var items = getItems(scale: scale);
      final stopwatch = Stopwatch()..start();
      DistanceClustering(
        ClusterAlgorithmType.DIST_GREEDY_SIMPLIFIED,
        distParams,
        bounds,
      ).run(items);
      print('DIST_GREEDY_SIMPLIFIEd executed in ${stopwatch.elapsed}');
    });
  });
}
