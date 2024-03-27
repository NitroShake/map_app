import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'SearchResultRow.dart';
import 'AddressSearchResult.dart';
import 'SearchMenu.dart';
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
  final PanelController panelController = PanelController();
  final MapController mapController = MapController();
  final GlobalKey<NavigatorState> searchKey = GlobalKey<NavigatorState>();

  List<SearchResultRow> searchResults = List.empty(growable: true);
  LatLng userPosition = const LatLng(0, 0);
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );
  final ButtonStyle menuOptionButtonStyle = OutlinedButton.styleFrom(
    shape: const LinearBorder(top: LinearBorderEdge()),
    padding: EdgeInsets.all(10)
  );
  final TileLayer tileLayer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.app',
  );
  late StreamSubscription<Position> positionStream;
  late Timer timer;

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
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(51.509364, -0.128928),
            initialZoom: 9.2,
            maxZoom: 20,
            minZoom: 2.5,
            cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(const LatLng(-90, -180), const LatLng(90, 180))),
          ),
          children: [
            tileLayer,
            MarkerLayer(markers: [Marker(point: userPosition, width: 30, height: 30, child: const Center(child: Icon(Icons.location_on)))])
          ],
        ),
        SlidingUpPanel(
          controller: panelController,
          onPanelClosed: () {FocusManager.instance.primaryFocus?.unfocus();},
          panel: DefaultTabController(length: 3, child: Column ( 
            children: [
              const Material(child: TabBar(tabs: [
                Tab(icon: Icon(Icons.search)),
                Tab(icon: Icon(Icons.bookmark),),
                Tab(icon: Icon(Icons.settings),),
              ])),
              Expanded(child: Material(child: TabBarView(children: [
                Navigator(
                  key: searchKey,
                  onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => SearchMenu(title: "Hello", panelController: panelController, mapController: mapController)),
                ),
                //SearchMenu(title: "Hello", panelController: panelController),
                Icon(Icons.bookmark),
                Icon(Icons.settings),
              ]),))
            ],)
          ),
        )
      ],
    );
  }
}