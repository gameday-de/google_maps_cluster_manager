import 'package:google_maps_cluster_manager/algorithms/cluster_algorithm.dart';
import 'package:google_maps_cluster_manager/cluster.dart';
import 'package:google_maps_cluster_manager/cluster_item.dart';

class GeohashClustering<T extends ClusterItem> extends ClusterAlgorithm<T> {
  GeohashClustering(ClusterAlgorithmType type, this.precision) : super(type);
  final int precision;

  List<Cluster<T>> run(List<T> inputItems) {
    return _computeClusters(inputItems, List.empty(growable: true));
  }

  List<Cluster<T>> _computeClusters(
      List<T> inputItems, List<Cluster<T>> clusters) {
    if (inputItems.isEmpty) return clusters;

    String nextGeohash = inputItems[0].geohash.substring(0, precision);
    List<T> items = inputItems
        .where((p) => p.geohash.substring(0, precision) == nextGeohash)
        .toList();

    clusters.add(Cluster<T>.fromItems(items));

    List<T> newInputList = List.from(inputItems
        .where((i) => i.geohash.substring(0, precision) != nextGeohash));

    return _computeClusters(newInputList, clusters);
  }
}
