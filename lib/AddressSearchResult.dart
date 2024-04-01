class AddressSearchResult {
  final int id;
  final double lat;
  final double long;
  final String classification;
  final String type;
  final String osmkey;
  final String osmValue;
  final String name;
  final String? houseNumber;
  final String? street;
  final String? locality;
  final String? district;
  final String? postcode;
  final String? city;
  final String? county;
  final String? state;
  final String? country;

  const AddressSearchResult({
    required this.id,
    required this.lat,
    required this.long,
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
    required this.country
  });

  factory AddressSearchResult.fromJson(Map<String, dynamic> json) {
    try {
      return AddressSearchResult(
        id: json["properties"]["geocoding"]['place_id'],
        lat: json["geometry"]["coordinates"][1], 
        long: json["geometry"]["coordinates"][0], 
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
        country: json["properties"]["geocoding"]['country']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}