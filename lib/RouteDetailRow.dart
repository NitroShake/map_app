import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/MapRoute.dart';

class RouteDetailRow extends StatelessWidget {
  final ButtonStyle menuOptionButtonStyle = OutlinedButton.styleFrom(
    shape: const LinearBorder(top: LinearBorderEdge()),
    padding: EdgeInsets.all(10)
  );
  RouteCheckpoint checkpoint;
  double distance;

  RouteDetailRow({required this.checkpoint, required this.distance});

  @override Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text(checkpoint.generateInstructions(),textScaler: TextScaler.linear(1.2  * MediaQuery.of(context).textScaleFactor),),
          Text("${checkpoint.locationName}, ${distance}m", textScaler: TextScaler.linear(0.8 * MediaQuery.of(context).textScaleFactor)),
        ]
      ),
    );
  }
}