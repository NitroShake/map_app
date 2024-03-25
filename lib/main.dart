import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PanelController panelController = PanelController();
  List<SearchResultRow> searchResults = List.empty(growable: true);
  LatLng userPosition = const LatLng(0, 0);
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );
  late StreamSubscription<Position> positionStream;
  late Timer timer;


  void searchAddresses(String string) async {
    searchResults = List.empty(growable: true);
    List<AddressSearchResultGeocoded> entries = List<AddressSearchResultGeocoded>.empty();
    final response = await http
      .get(Uri.parse('https://nominatim.openstreetmap.org/search?format=geocodejson&addressdetails=1&q=${Uri.encodeComponent(string)}'));
    
    if (response.statusCode == 200) {
      print(response.body);

      //geocodejson
      String test = "[${response.body}]";
      List<dynamic> m = json.decode((test));
      Iterable i = m[0]['features'];

      //regular json
      //Iterable i = json.decode(response.body);


      //entries = List<AddressSearchResult>.from(jsonDecode(response.body).Map((x) => AddressSearchResult.fromJson(x)));
      entries = List<AddressSearchResultGeocoded>.from(i.map((e) => AddressSearchResultGeocoded.fromJson(e)));
      setState(() {   
        for (var entry in entries) {
          searchResults.add(new SearchResultRow(title: "${entry.name}, ${entry.city}", subtitle: "${entry.county}, ${entry.country}"));
        }
      });
    }
  }

  void updatePosition() async {
    var perm = await Geolocator.checkPermission();
    print(perm);
    while (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
      await Future.delayed(const Duration(milliseconds: 1000));
      print("e");
      perm = await Geolocator.checkPermission();
    }
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        setState(() {
          userPosition = LatLng(position == null ? 0 : position.latitude, position == null ? 0 : position.longitude);   
        });
      print("${position?.latitude}, ${position?.longitude}");
    });
  }

  @override
  void initState() {
    super.initState();
    //timer = Timer.periodic(Duration(seconds: 5), (Timer t) => backgroundUpdate());

    Timer.run(() {updatePosition();});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(51.509364, -0.128928),
            initialZoom: 9.2,
            maxZoom: 20,
            minZoom: 2.5,
            cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(const LatLng(-90, -180), const LatLng(90, 180))),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: [Marker(point: userPosition, width: 30, height: 30, child: Center(child: Text("YOU ARE HERE")))])
          ],
        ),
        SlidingUpPanel(
          controller: panelController,
          onPanelClosed: () {FocusManager.instance.primaryFocus?.unfocus();},
          panel: Column(
            children: [
              Row(children: [
                Expanded(child: Material(child: TextField(
                  onTap: () { panelController.open(); },
                  onSubmitted: searchAddresses,
                ))),
                FilledButton(onPressed: () => {}, child: const Text('B')),
                FilledButton(onPressed: () => {}, child: const Text('S'))]
              ),
              Expanded(
                child:ListView(
                  children: searchResults,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    required this.title,
    required this.subtitle
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textScaler: const TextScaler.linear(0.5)),
        Text(subtitle, textScaler: const TextScaler.linear(0.25)),
        const Divider()
      ],
    );
  }
}

class AddressSearchResult {
  final String lat;
  final String long;
  final String classification;
  final String type;
  final String addressType;
  final String name;
  final Map<String, dynamic> address;

  const AddressSearchResult({
    required this.lat,
    required this.long,
    required this.classification,
    required this.type,
    required this.addressType,
    required this.name,
    required this.address
  });

  factory AddressSearchResult.fromJson(Map<String, dynamic> json) {
    try {
      return AddressSearchResult(
        lat: json["lat"], 
        long: json["lon"], 
        classification: json['class'], 
        type: json['type'], 
        addressType: json['addresstype'], 
        name: json['name'], 
        address: json['address']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}

class AddressSearchResultGeocoded {
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

  const AddressSearchResultGeocoded({
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

  factory AddressSearchResultGeocoded.fromJson(Map<String, dynamic> json) {
    try {
      return AddressSearchResultGeocoded(
        lat: json["geometry"]["coordinates"][0], 
        long: json["geometry"]["coordinates"][1], 
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