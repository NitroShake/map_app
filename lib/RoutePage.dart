import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/RouteDetailRow.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key, required this.title});

  final String title;

  @override
  State<RoutePage> createState() => _RoutePage();
}

class _RoutePage extends State<RoutePage> {
  List<Widget> generateRouteWidgets() {
    List<Widget> list = List.empty(growable: true);
    for (var i in (SystemManager().route as MapRoute).checkpoints) {
      list.add(RouteDetailRow(checkpoint: i));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: Column(children: 
        List<Widget>.from([
          FilledButton(onPressed: () => {SystemManager().clearRoute()}, child: Text("Delete Route"))
          FilledButton(onPressed: () => {SystemManager().clearRoute()}, child: Text("Delete Route"))
        ])
        + generateRouteWidgets(),
      )
    );
  }
}