import 'package:google_maps_cluster_manager/cluster.dart';
import 'package:google_maps_cluster_manager/cluster_item.dart';

enum ClusterAlgorithmType {
  GEOHASH,
  DIST_AGGLO_HAVERSINE,
  DIST_AGGLO_SIMPLIFIED,
  DIST_GREEDY_HAVERSINE,
  DIST_GREEDY_SIMPLIFIED
}

class ClusterAlgorithmParams {}

abstract class ClusterAlgorithm<T extends ClusterItem> {
  ClusterAlgorithm(this.type, {this.params});
  final ClusterAlgorithmParams? params;
  final ClusterAlgorithmType type;

  List<Cluster<T>> run(List<T> inputItems);
}
