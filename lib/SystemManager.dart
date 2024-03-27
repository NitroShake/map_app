import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SystemManager {
  late PanelController mainPanelController;
  late MapController mapController;

  SystemManager._privateConstructor();

  static final SystemManager _instance = SystemManager._privateConstructor();

  factory SystemManager() {
    return _instance;
  }

}