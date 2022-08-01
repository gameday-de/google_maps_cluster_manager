import 'package:google_maps_cluster_manager/algorithms/cluster_algorithm.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_cluster_manager/utils/common.dart';

class DistanceParams extends ClusterAlgorithmParams {
  DistanceParams({required this.epsilon});

  ///Threshold distance for two clusters to be considered as one cluster
  final double epsilon;
}

class DistanceClustering<T extends ClusterItem> extends ClusterAlgorithm<T> {
  DistanceClustering(ClusterAlgorithmType type, ClusterAlgorithmParams params)
      : super(type, params) {
    assert(this.params is DistanceParams);
  }

  // TODO somehow remove
  final DistUtils distUtils = DistUtils();

  ///Run clustering process, add configs in constructor
  List<Cluster<T>> run(List<T> inputItems) {
    double epsilon = (params as DistanceParams).epsilon;

    switch (type) {
      case ClusterAlgorithmType.DIST_AGGLO_HAVERSINE:
        return agglomerativeClustering(inputItems, epsilon);
      default:
        return agglomerativeClustering(inputItems, epsilon);
    }
  }

  List<Cluster<T>> agglomerativeClustering(
      List<T> inputMarker, double epsilon) {
    List<Cluster<T>> clusterList = [];

    // Initialize Cluster
    for (T marker in inputMarker) {
      clusterList.add(Cluster.fromItems([marker]));
    }

    bool changed = true;
    while (changed) {
      changed = false;
      for (Cluster<T> c in clusterList) {
        Cluster<T>? minDistCluster = getClosestCluster(clusterList, c, epsilon);

        if (minDistCluster != null) {
          clusterList.add(Cluster.fromClusters(minDistCluster, c));
          clusterList.remove(c);
          clusterList.remove(minDistCluster);
          changed = true;
        }
      }
    }
    return clusterList;
  }

  Cluster<T>? getClosestCluster(
      List<Cluster<T>> clusterList, Cluster cluster, double epsilon) {
    double minDist = double.infinity;

    Cluster<T>? minDistCluster;
    for (Cluster<T> c in clusterList) {
      if (c.location == cluster.location) continue;
      double dist = distUtils.getLatLonDist(c.location, cluster.location);
      if (dist < minDist && dist < epsilon) {
        minDist = dist;
        minDistCluster = c;
      }
    }
    return minDistCluster;
  }
}
