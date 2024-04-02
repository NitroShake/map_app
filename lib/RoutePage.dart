import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/RouteDetailRow.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  @override void dispose() {
    SystemManager().routePage = null;
    super.dispose();
  }

  RoutePageState() {
    SystemManager().routePage = this;
  }

  List<Widget> generateRouteWidgets() {
    List<Widget> list = List.empty(growable: true);
    if (SystemManager().getRoute() != null) {
      for (var i in (SystemManager().getRoute() as MapRoute).checkpoints) {
        list.add(RouteDetailRow(checkpoint: i));
      }
    }
    return list;
  }

  void refresh() {
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return
    MediaQuery.removePadding(context : context, removeTop:  true, child: Scaffold(
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        title: Row(children: [FilledButton(onPressed: () {SystemManager().menuIsShowingRoute = false; Navigator.of(context).pop();}, child: Text("Back"))]),
        automaticallyImplyLeading: false,
      ),
      body:    ListView(
      padding: EdgeInsets.zero,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
            List<Widget>.from([
              FilledButton(onPressed: () {SystemManager().menuIsShowingRoute = false; Navigator.of(context).pop();}, child: Text("Back")),
              Text("Route Directions"),
              FilledButton(onPressed: () {SystemManager().clearRoute(); setState(() {});}, child: Text("Delete Route"))
            ])
            + generateRouteWidgets(),
        )
      ],
    )
    )
    );

  }
}