import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/RouteDetailRow.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  late AlertDialog cancelRouteDialog;

  @override void dispose() {
    SystemManager().routePage = null;
    super.dispose();
  }

  RoutePageState() {
    SystemManager().routePage = this;

    cancelRouteDialog = AlertDialog(
    title: Text("Cancel Route?"),
    content: Text("Are you sure you want to cancel the current route?"),
    actions: [
      TextButton(onPressed: () {Navigator.of(context, rootNavigator: true).pop();}, child: Text("No")),
      TextButton(onPressed: () {SystemManager().clearRoute(); Navigator.of(context, rootNavigator: true).pop(); close();}, child: Text("Yes"))
    ],
  );
  }

  List<Widget> generateRouteWidgets() {
    List<Widget> list = List.empty(growable: true);
    Distance distance = Distance();
    if (SystemManager().getRoute() != null) {
      for (var i in (SystemManager().getRoute() as MapRoute).checkpoints) {
        list.add(RouteDetailRow(checkpoint: i, distance: distance.as(LengthUnit.Meter, SystemManager().getUserPosition(), i.position)));
      }
    }
    return list;
  }

  void refresh() {
    setState(() { });
  }

  void close() {
    SystemManager().menuIsShowingRoute = false;
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return
    MediaQuery.removePadding(context: context, removeTop: true, child: Scaffold(
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        title: Row(children: [
          FilledButton(onPressed: () {SystemManager().menuIsShowingRoute = false; close();}, child: Text("Back")),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [FilledButton(onPressed: () {showDialog(context: context, builder: (context) {return cancelRouteDialog;});}, child: Text("Cancel Route"))],) )
        ]),
        automaticallyImplyLeading: false,
      ),
      body:    ListView(
      padding: EdgeInsets.zero,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
            List<Widget>.from([
              SystemManager().getRoute() != null ? Text("Route Directions to ${SystemManager().getRoute()!.destinationName}", textScaler: TextScaler.linear(1.75  * MediaQuery.of(context).textScaleFactor),) : Container(),
            ])
            + generateRouteWidgets()
            + [Container(height: 20,)],
        )
      ],
    )
    )
    );

  }
}