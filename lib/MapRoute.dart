import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapRoute {
  final List<LatLng> pathPoints;
  final List<dynamic> checkpoints;
  final List<Marker> test;

  const MapRoute({
    required this.pathPoints,
    required this.checkpoints,
    required this.test,
  });

  factory MapRoute.fromJson(Map<String, dynamic> json) {
    List<LatLng> pathPoints = List<LatLng>.empty(growable: true);
    List<Marker> test = List<Marker>.empty(growable: true);
    try {
      for (Map<String, dynamic> checkpoint in json['routes'][0]['legs'][0]['steps']) {
        for (List<dynamic> pathPoint in checkpoint['geometry']['coordinates']) {
          pathPoints.add(LatLng(pathPoint[1], pathPoint[0]));
        }
        test.add(Marker(child: Icon(Icons.location_on_rounded), point: LatLng(checkpoint['maneuver']['location'][1], checkpoint['maneuver']['location'][0])));
      }

      

      return MapRoute(
        pathPoints: pathPoints,
        checkpoints: List.empty(),
        test: test
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}

class RouteCheckpoint {
  int pathPointIndex;
  String modifier;
  String modifierType;
  LatLng position;

  RouteCheckpoint({
    required this.pathPointIndex,
    required this.modifier,
    required this.modifierType,
    required this.position
  });
}