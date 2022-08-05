import 'package:google_maps_cluster_manager/algorithms/cluster_algorithm.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_cluster_manager/utils/distance_utils.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class DistanceParams extends ClusterAlgorithmParams {
  DistanceParams({
    this.fixed = false,
    this.epsilon = 10,
    this.maxItems = 200,
  });

  /// If true epsilon is the distance in km
  final bool fixed;

  /// Threshold distance in percent of screen width or km for two clusters to be considered as one cluster
  final double epsilon;

  // Num of Items to switch to GEOHASH clustering
  final int maxItems;
}

class DistanceClustering<T extends ClusterItem> extends ClusterAlgorithm<T> {
  DistanceClustering(
    ClusterAlgorithmType type,
    ClusterAlgorithmParams params,
    this.screenBounds,
  ) : super(type, params: params) {
    assert(this.params is DistanceParams);
  }
  final LatLngBounds screenBounds;
  final DistUtils distUtils = DistUtils();

  ///Run clustering process, add configs in constructor
  List<Cluster<T>> run(List<T> inputItems) {
    DistanceParams params = this.params as DistanceParams;

    var epsilon;
    if (params.fixed) {
      epsilon = params.epsilon;
    } else {
      epsilon = DistUtils.boundsPercent2km(screenBounds, params.epsilon);
    }

    switch (type) {
      case ClusterAlgorithmType.DIST_AGGLO_HAVERSINE:
        return agglomerativeClustering(inputItems, epsilon);
      case ClusterAlgorithmType.DIST_AGGLO_SIMPLIFIED:
        return agglomerativeClustering(inputItems, epsilon);
      default:
        return greedyClustering(inputItems, epsilon);
    }
  }

  List<Cluster<T>> agglomerativeClustering(
      List<T> inputMarker, double epsilon) {
    List<Cluster<T>> clusterList = [];

    // Initialize Cluster with one marker each
    for (T marker in inputMarker) {
      clusterList.add(Cluster.fromItems([marker]));
    }

    bool changed = true;
    while (changed) {
      changed = false;
      for (Cluster<T> c in clusterList) {
        Cluster<T>? minDistCluster =
            _getClosestCluster(clusterList, c, epsilon);

        if (minDistCluster != null) {
          clusterList.add(Cluster.fromClusters(minDistCluster, c));
          clusterList.remove(c);
          clusterList.remove(minDistCluster);
          changed = true;

          break;
        }
      }
    }
    return clusterList;
  }

  List<Cluster<T>> greedyClustering(List<T> inputMarker, double epsilon) {
    List<Cluster<T>> currentList = [];
    List<Cluster<T>> outputList = [];

    // Initialize Cluster with one marker each
    for (T marker in inputMarker) {
      currentList.add(Cluster.fromItems([marker]));
    }

    while (currentList.length != 0) {
      List<Cluster<T>> remainingList = [];

      var curCluster = currentList.first;
      currentList.remove(curCluster);

      for (Cluster<T> c in currentList) {
        double dist = distUtils.getLatLonDist(
          c.location,
          curCluster.location,
          type: algorithmType2distanceType(type),
        );

        if (dist < epsilon) {
          curCluster = Cluster.fromClusters(curCluster, c);
        } else {
          remainingList.add(c);
        }
      }

      outputList.add(curCluster);
      currentList = remainingList;
    }

    return outputList;
  }

  Cluster<T>? _getClosestCluster(
      List<Cluster<T>> clusterList, Cluster cluster, double epsilon) {
    double minDist = double.infinity;

    Cluster<T>? minDistCluster;
    for (Cluster<T> c in clusterList) {
      if (c.location == cluster.location) continue;
      double dist = distUtils.getLatLonDist(
        c.location,
        cluster.location,
        type: algorithmType2distanceType(type),
      );
      if (dist < minDist && dist < epsilon) {
        minDist = dist;
        minDistCluster = c;
      }
    }
    return minDistCluster;
  }

  DistanceType algorithmType2distanceType(ClusterAlgorithmType type) {
    switch (type) {
      case ClusterAlgorithmType.DIST_AGGLO_HAVERSINE:
        return DistanceType.HAVERSINE;
      case ClusterAlgorithmType.DIST_GREEDY_HAVERSINE:
        return DistanceType.HAVERSINE;
      default:
        return DistanceType.EUCLIDEAN;
    }
  }
}
