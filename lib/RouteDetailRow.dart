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

  List<String> exitNums = ["first", "second", "third", "forth", "fifth", "sixth", "seventh", "eight", "ninth", "tenth"];

  String checkpointExit() {
    if (checkpoint.roundaboutExit! <= exitNums.length) {
      return "${exitNums[checkpoint.roundaboutExit! - 1]} exit";
    }
    else return "exit ${checkpoint.roundaboutExit}";
  }

  String generateInstructions() {
    String instruction = "";
    switch (checkpoint.modifierType) {
      case "end of road":
        instruction = "At the end of the road, turn ${checkpoint.modifier}";
      case "roundabout":
        instruction = "Go ${checkpoint.modifier} on the roundabout, ${checkpointExit()}";
      case "exit roundabout":
        instruction = "Exit roundabout, ${checkpointExit()}";
      case "rotary":
        instruction = "Go ${checkpoint.modifier} on the rotary, ${checkpointExit()}";
      case "exit rotary":
        instruction = "Exit rotary, ${checkpointExit()}";
      default:
        instruction = "Turn ${checkpoint.modifier}";
    }
    instruction = instruction.replaceAll("slight ", "");
    return instruction;
  }

  @override Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text("${generateInstructions()}",textScaler: TextScaler.linear(1.25),),
          Text("${checkpoint.locationName}, ${distance}m", textScaler: TextScaler.linear(1)),
        ]
      ),
    );
  }
}