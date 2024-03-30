import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:map_app/SystemManager.dart';

class MapRoute {
  final List<LatLng> pathPoints;
  final List<RouteCheckpoint> checkpoints;
  final List<Marker> test;
  late LatLng? lastKnownUserLocation = null;
  int positionRouteMismatchCount = 0;

  MapRoute({
    required this.pathPoints,
    required this.checkpoints,
    required this.test,
  });

  void update(LatLng userPosition) {
    Distance distance = const Distance();
    int closestIndex = 0;
    double distanceToBeat = distance(userPosition, pathPoints[0]);
    double newDistance = distance(userPosition, pathPoints[1]);
    while(closestIndex < pathPoints.length && distanceToBeat >= newDistance) {
      closestIndex++;
      distanceToBeat = newDistance;
      newDistance = distance(userPosition, pathPoints[closestIndex+1]);
    }

    for (int i = 0; i < closestIndex; i++) {
      pathPoints.removeAt(0);
    }

    for (int i = 0; i < checkpoints.length; i++) {
      checkpoints[i].pathPointIndex -= closestIndex;
      if (checkpoints[i].pathPointIndex < 0) {
        checkpoints.remove(checkpoints[i]);
        i--;
      }
    }

    if (closestIndex == 0) {
      if (lastKnownUserLocation != null && distance(pathPoints[0], lastKnownUserLocation!) < distance(userPosition, pathPoints[0])) {
        positionRouteMismatchCount++;
        if (positionRouteMismatchCount > 5) {
          //recalculate route
        }
      }
    }
    lastKnownUserLocation = userPosition;
  }

  factory MapRoute.fromJson(Map<String, dynamic> json) {
    List<LatLng> pathPoints = List<LatLng>.empty(growable: true);
    List<Marker> test = List<Marker>.empty(growable: true);
    List<RouteCheckpoint> checkpoints = List.empty(growable: true);
    try {
      for (Map<String, dynamic> checkpoint in json['routes'][0]['legs'][0]['steps']) {
        checkpoints.add(RouteCheckpoint(pathPointIndex: pathPoints.length,
          modifier: checkpoint['maneuver']['modifier'], 
          modifierType: checkpoint['maneuver']['type'], 
          position: LatLng(checkpoint['maneuver']['location'][1], checkpoint['maneuver']['location'][0]),
          visualTest: Marker(child: Icon(Icons.location_on_rounded), point: LatLng(checkpoint['maneuver']['location'][1], checkpoint['maneuver']['location'][0]))),
        );
        for (List<dynamic> pathPoint in checkpoint['geometry']['coordinates']) {
          pathPoints.add(LatLng(pathPoint[1], pathPoint[0]));
        }
      }

      return MapRoute(
        pathPoints: pathPoints,
        checkpoints: checkpoints,
        test: test
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}

class RouteCheckpoint {
  int pathPointIndex;
  String? modifier;
  String modifierType;
  LatLng position;
  Marker visualTest;

  RouteCheckpoint({
    required this.pathPointIndex,
    required this.modifier,
    required this.modifierType,
    required this.position,
    required this.visualTest
  });
}