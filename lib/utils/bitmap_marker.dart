import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/cluster.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

Future<Marker> Function(Cluster) get basicMarkerBuilder => (cluster) async {
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        onTap: () {
          debugPrint(cluster.toString());
        },
        icon: await _getBasicClusterBitmap(
          cluster.isMultiple ? 125 : 75,
          text: cluster.isMultiple ? cluster.count.toString() : null,
        ),
      );
    };

Future<BitmapDescriptor> _getBasicClusterBitmap(
  int size, {
  String? text,
}) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint1 = Paint()..color = Colors.red;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

  if (text != null) {
    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size / 3,
        color: Colors.white,
        fontWeight: FontWeight.normal,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );
  }

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}
