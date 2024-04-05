import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/LocationDetails.dart';

class Nominatim {
  static Future<LocationDetails> reverseSearch(LatLng point) async {
    var response = await http.get(Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${Uri.encodeComponent(point.latitude.toString())}&lon=${Uri.encodeComponent(point.longitude.toString())}&addressdetails=1&format=geocodejson"));
    if (response.statusCode == 200) {
      return LocationDetails.fromJson(json.decode(response.body)['features'][0]);
    }
    else {
      throw Exception("Unable to get details");
    }
  }
}