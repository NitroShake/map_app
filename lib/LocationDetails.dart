import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationDetails {
  final int id;
  final int osmId;
  final double lat;
  final double lon;
  final String classification;
  final String type;
  final String osmkey;
  final String osmValue;
  final String osmType;
  final String? name;
  final String? houseNumber;
  final String? street;
  final String? locality;
  final String? district;
  final String? postcode;
  final String? city;
  final String? county;
  final String? state;
  final String? country;

  const LocationDetails({
    required this.id,
    required this.lat,
    required this.lon,
    required this.classification,
    required this.type,
    required this.osmkey,
    required this.osmValue,
    required this.name,
    required this.houseNumber,
    required this.street,
    required this.locality, 
    required this.district, 
    required this.postcode, 
    required this.city, 
    required this.county, 
    required this.state, 
    required this.country,
    required this.osmId,
    required this.osmType
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    try {
      return LocationDetails(
        id: json["properties"]["geocoding"]['place_id'],
        lat: json["geometry"]["coordinates"][1], 
        lon: json["geometry"]["coordinates"][0], 
        classification: json["properties"]["geocoding"]['type'], 
        type: json["properties"]["geocoding"]['type'], 
        osmkey: json["properties"]["geocoding"]['osm_key'], 
        osmValue: json["properties"]["geocoding"]['osm_value'],
        name: json["properties"]["geocoding"]['name'], 
        houseNumber: json["properties"]["geocoding"]['housenumber'], 
        street: json["properties"]["geocoding"]['street'],
        locality: json["properties"]["geocoding"]['locality'],
        district: json["properties"]["geocoding"]['district'],
        postcode: json["properties"]["geocoding"]['postcode'],
        city: json["properties"]["geocoding"]['city'],
        county: json["properties"]["geocoding"]['county'],
        state: json["properties"]["geocoding"]['state'],
        country: json["properties"]["geocoding"]['country'],
        osmId: json['properties']['geocoding']['osm_id'],
        osmType: json['properties']['geocoding']['osm_type']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }

  static Future<LocationDetails?> fromNomReverseSearch(LatLng point) async {
    var response = await http.get(Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${Uri.encodeComponent(point.latitude.toString())}&lon=${Uri.encodeComponent(point.longitude.toString())}&addressdetails=1&format=geocodejson"));
    if (response.statusCode == 200) {
      try {
        return LocationDetails.fromJson(json.decode(response.body)['features'][0]);
      } catch (e) {
        return null;
      }
    }
    else {
      return null;
    }
  }

  static Future<List<LocationDetails>?> listFromNomSearch(String query) async {
    final response = await http.get(Uri.parse('http://nominatim.openstreetmap.org/search?format=geocodejson&addressdetails=1&q=${Uri.encodeComponent(query)}'));
    
    if (response.statusCode == 200) {
      String test = "[${response.body}]";
      try {
        List<dynamic> m = json.decode((test));
        Iterable i = m[0]['features'];
        List<LocationDetails> entries = List<LocationDetails>.from(i.map((e) => LocationDetails.fromJson(e)));
        return entries;
      } catch (e) {
        return null;
      }
    }
    else return null;
  }

  static Future<List<LocationDetails>?> listFromNomLookup(String lookupParams) async {
    final lookupResponse = await http.get(Uri.parse("https://nominatim.openstreetmap.org/lookup?format=geocodejson&addressdetails=1&osm_ids=${lookupParams}"));
    if (lookupResponse.statusCode == 200) {
      try {
        Iterable iter = json.decode(lookupResponse.body)['features'];
        List<LocationDetails> results = List<LocationDetails>.from(iter.map((e) => LocationDetails.fromJson(e)));
        return results;
      } catch (e) {
        return null;
      }
    } else return null;
  }

  bool isSameAs(LocationDetails details) {
    if (osmValue == details.osmValue && osmId == details.osmId) {
      return true;
    }
    else {
      return false;
    }
  }
}