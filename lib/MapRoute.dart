import 'dart:convert';
import 'package:http/http.dart' as http;

class MapRoute {
  final List<List<double>> pathPoints;
  final List<dynamic> checkpoints;

  const MapRoute({
    required this.pathPoints,
    required this.checkpoints
  });

  factory MapRoute.fromJson(Map<String, dynamic> json) {
    try {
      return MapRoute(
        pathPoints: json['routes']['geometry']['coordinates'],
        checkpoints: json['routes']['legs']['steps']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}