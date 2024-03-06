import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../model/GeofenceModel.dart';

class GeoFenceEdit extends StatelessWidget {
  const GeoFenceEdit({super.key, required this.geofence});

  final Geofence geofence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit GeoFence'),
      ),
      body: Column(
        children: [
          Text(geofence.name),
        ],
      ),
    );
  }
}
