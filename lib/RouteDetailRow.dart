import 'package:flutter/material.dart';
import 'package:map_app/MapRoute.dart';

class RouteDetailRow extends StatelessWidget {
  RouteCheckpoint checkpoint;

  RouteDetailRow({required this.checkpoint});

  @override Widget build(BuildContext context) {
    return Column(children: [
      Text(checkpoint.modifierType),
      Text(checkpoint.modifier?? '')
    ],);
  }
}