import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/MapRoute.dart';

class RouteDetailRow extends StatelessWidget {
  RouteCheckpoint checkpoint;

  RouteDetailRow({required this.checkpoint});

  @override Widget build(BuildContext context) {
    return Material(
      child: Column(children: [
      Text("${checkpoint.modifierType} ${checkpoint.modifier?? ''}",textScaler: TextScaler.linear(2),),
      Text("${checkpoint.locationName}, put distance here", textScaler: TextScaler.linear(2)),
      Divider()
    ],),
    );
  }
}