import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_cluster_manager/algorithms/cluster_algorithm.dart';
import 'package:google_maps_cluster_manager/algorithms/distance_clustering.dart';
import 'package:google_maps_cluster_manager/algorithms/geohash_clustering.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_cluster_manager/utils/bitmap_marker.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class ClusterManager<T extends ClusterItem> {
  ClusterManager(
    this._items,
    this.updateMarkers, {
    Future<Marker> Function(Cluster<T>)? markerBuilder,
    this.levels = const [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
    this.extraPercent = 0.5,
    this.clusterAlgorithmType = ClusterAlgorithmType.GEOHASH,
    this.clusteringParams,
    this.stopClusteringZoom,
  })  : this.markerBuilder = markerBuilder ?? basicMarkerBuilder,
        assert(levels.length <= precision);

  /// Method to build markers
  final Future<Marker> Function(Cluster<T>) markerBuilder;

  /// Function to update Markers on Google Map
  final void Function(Set<Marker>) updateMarkers;

  /// Zoom levels configuration
  final List<double> levels;

  /// Extra percent of markers to be loaded (ex : 0.2 for 20%)
  final double extraPercent;

  // Clusteringalgorithm
  final ClusterAlgorithmType clusterAlgorithmType;

  /// ClusterAlgorithm specific parameters
  final ClusterAlgorithmParams? clusteringParams;

  /// Zoom level to stop cluster rendering
  final double? stopClusteringZoom;

  /// Precision of the geohash
  static final int precision = kIsWeb ? 12 : 20;

  /// Google Maps map id
  int? _mapId;

  /// List of items
  Iterable<T> get items => _items;
  Iterable<T> _items;

  /// Last known zoom
  late double _zoom;

  final double _maxLng = 180 - pow(10, -10.0) as double;

  /// Set Google Map Id for the cluster manager
  void setMapId(int mapId, {bool withUpdate = true}) async {
    _mapId = mapId;
    _zoom = await GoogleMapsFlutterPlatform.instance.getZoomLevel(mapId: mapId);
    if (withUpdate) updateMap();
  }

  /// Method called on map update to update cluster. Can also be manually called to force update.
  void updateMap() {
    _updateClusters();
  }

  void _updateClusters() async {
    List<Cluster<T>> mapMarkers = await getMarkers();

    final Set<Marker> markers =
        Set.from(await Future.wait(mapMarkers.map((m) => markerBuilder(m))));

    updateMarkers(markers);
  }

  /// Update all cluster items
  void setItems(List<T> newItems) {
    _items = newItems;
    updateMap();
  }

  /// Add on cluster item
  void addItem(ClusterItem newItem) {
    _items = List.from([...items, newItem]);
    updateMap();
  }

  /// Method called on camera move
  void onCameraMove(CameraPosition position, {forceUpdate = false}) {
    _zoom = position.zoom;
    if (forceUpdate) {
      updateMap();
    }
  }

  /// Retrieve cluster markers
  Future<List<Cluster<T>>> getMarkers() async {
    if (_mapId == null) return List.empty();

    final LatLngBounds mapBounds = await GoogleMapsFlutterPlatform.instance
        .getVisibleRegion(mapId: _mapId!);

    late LatLngBounds inflatedBounds = _inflateBounds(mapBounds);

    List<T> visibleItems = items.where((i) {
      return inflatedBounds.contains(i.location);
    }).toList();

    if (stopClusteringZoom != null && _zoom >= stopClusteringZoom!)
      return visibleItems.map((i) => Cluster<T>.fromItems([i])).toList();

    // Geohash CLustering
    if (clusterAlgorithmType == ClusterAlgorithmType.GEOHASH) {
      return GeohashClustering<T>(clusterAlgorithmType, _findLevel(levels))
          .run(visibleItems);
    }

    // Distance Clustering
    return DistanceClustering<T>(
      clusterAlgorithmType,
      clusteringParams ?? DistanceParams(),
      mapBounds,
    ).run(visibleItems);
  }

  LatLngBounds _inflateBounds(LatLngBounds bounds) {
    // Bounds that cross the date line expand compared to their difference with the date line
    double lng = 0;
    if (bounds.northeast.longitude < bounds.southwest.longitude) {
      lng = extraPercent *
          ((180.0 - bounds.southwest.longitude) +
              (bounds.northeast.longitude + 180));
    } else {
      lng = extraPercent *
          (bounds.northeast.longitude - bounds.southwest.longitude);
    }

    // Latitudes expanded beyond +/- 90 are automatically clamped by LatLng
    double lat =
        extraPercent * (bounds.northeast.latitude - bounds.southwest.latitude);

    double eLng = (bounds.northeast.longitude + lng).clamp(-_maxLng, _maxLng);
    double wLng = (bounds.southwest.longitude - lng).clamp(-_maxLng, _maxLng);

    return LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude - lat, wLng),
      northeast:
          LatLng(bounds.northeast.latitude + lat, lng != 0 ? eLng : _maxLng),
    );
  }

  int _findLevel(List<double> levels) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (levels[i] <= _zoom) {
        return i + 1;
      }
    }

    return 1;
  }
}
