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
  RouteCheckpoint? lastSpokenCheckpoint = null;
  String mode;
  final String destinationName;
  late LatLng? lastKnownUserLocation = null;
  int positionRouteMismatchCount = 0;

  MapRoute({
    required this.pathPoints,
    required this.checkpoints,
    required this.test,
    required this.mode,
    required this.destinationName
  }) {
    if (checkpoints.length > 1 && checkpoints[0].modifier == null) {
      checkpoints.removeAt(0);
    }
  }
  

  void update(LatLng userPosition) async {
    Distance distance = const Distance();
    int closestIndex = 0;
    double distanceToBeat = distance(userPosition, pathPoints[0]);
    double newDistance = distance(userPosition, pathPoints[1]);
    while(closestIndex + 1 < pathPoints.length && distanceToBeat >= newDistance) {
      distanceToBeat = newDistance;
      newDistance = distance(userPosition, pathPoints[closestIndex+1]);
      closestIndex++;
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

    if (checkpoints.isEmpty && SystemManager().getRoute() == this) {
      SystemManager().clearRoute();
    } else {
      if (distance(checkpoints[0].position, userPosition) < 500 && checkpoints[0] != lastSpokenCheckpoint) {
        SystemManager().ttsSpeak(checkpoints[0].generateInstructions());
        lastSpokenCheckpoint = checkpoints[0];
      }

      if (closestIndex == 0) {
        if (lastKnownUserLocation != null && distance(pathPoints[0], lastKnownUserLocation!) < distance(userPosition, pathPoints[0])) {
          positionRouteMismatchCount++;
          if (positionRouteMismatchCount > 5) {
            MapRoute? newRoute = await MapRoute.createNewRoute(SystemManager().getUserPosition().latitude, SystemManager().getUserPosition().longitude, checkpoints[checkpoints.length - 1].position.latitude, checkpoints[checkpoints.length - 1].position.longitude, mode, destinationName);
            if (newRoute != null) {
              SystemManager().setRoute(newRoute);
            }
          }
        }
      }
    }
    lastKnownUserLocation = userPosition;
  }

  factory MapRoute.fromJson(Map<String, dynamic> json, String mode, String destinationName) {
    List<LatLng> pathPoints = List<LatLng>.empty(growable: true);
    List<Marker> test = List<Marker>.empty(growable: true);
    List<RouteCheckpoint> checkpoints = List.empty(growable: true);
    try {
      for (Map<String, dynamic> checkpoint in json['routes'][0]['legs'][0]['steps']) {
        checkpoints.add(RouteCheckpoint(pathPointIndex: pathPoints.length,
          modifier: checkpoint['maneuver']['modifier'], 
          modifierType: checkpoint['maneuver']['type'], 
          position: LatLng(checkpoint['maneuver']['location'][1], checkpoint['maneuver']['location'][0]),
          locationName: checkpoint['name'],
          roundaboutExit: checkpoint['maneuver']['exit'],
          ),
        );
        for (List<dynamic> pathPoint in checkpoint['geometry']['coordinates']) {
          pathPoints.add(LatLng(pathPoint[1], pathPoint[0]));
        }
      }

      return MapRoute(
        pathPoints: pathPoints,
        checkpoints: checkpoints,
        test: test,
        mode: mode,
        destinationName: destinationName
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }


  static Future<MapRoute?> createNewRoute(double latStart, double lonStart, double latEnd, double lonEnd, String transportMode, String destinationName) async {
    String url = 'https://router.project-osrm.org/route/v1/${transportMode}/${lonStart},${latStart};${lonEnd},${latEnd}?overview=false&steps=true&geometries=geojson&annotations=false';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);

      return MapRoute.fromJson(map, transportMode, destinationName); 
    }
    else {
      return null;
    }
  }
}

class RouteCheckpoint {
  int pathPointIndex;
  String? modifier;
  String modifierType;
  LatLng position;
  String locationName;
  int? roundaboutExit;

  RouteCheckpoint({
    required this.pathPointIndex,
    required this.modifier,
    required this.modifierType,
    required this.position,
    required this.locationName,
    required this.roundaboutExit
  });

    List<String> exitNums = ["first", "second", "third", "forth", "fifth", "sixth", "seventh", "eight", "ninth", "tenth"];

  String checkpointExit() {
    if (roundaboutExit! <= exitNums.length) {
      return "${exitNums[roundaboutExit! - 1]} exit";
    }
    else return "exit ${roundaboutExit}";
  }

  String generateInstructions() {
    String instruction = "";
    switch (modifierType) {
      case "end of road":
        instruction = "At the end of the road, turn ${modifier}";
      case "roundabout":
        instruction = "Go ${modifier} on the roundabout, ${checkpointExit()}";
      case "exit roundabout":
        instruction = "Exit roundabout, ${checkpointExit()}";
      case "rotary":
        instruction = "Go ${modifier} on the rotary, ${checkpointExit()}";
      case "exit rotary":
        instruction = "Exit rotary, ${checkpointExit()}";
      case "arrive":
        instruction = "You have reached your destination";
      default:
        instruction = "Turn ${modifier}";
    }
    instruction = instruction.replaceAll("slight ", "");
    return instruction;
  }
}