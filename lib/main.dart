import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_app/MainMenu.dart';
import 'package:map_app/RoutePage.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'SearchResultRow.dart';
import 'LocationDetails.dart';
import 'SearchMenu.dart';
import 'MapRoute.dart';
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
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final PanelController panelController = PanelController();
  final MapController mapController = MapController();
  final GlobalKey<NavigatorState> panelKey = GlobalKey<NavigatorState>();


  List<SearchResultRow> searchResults = List.empty(growable: true);
  LatLng userPosition = const LatLng(0, 0);
  late StreamSubscription<Position> positionStream;
  late Timer timer;

  final AndroidSettings locationSettings = AndroidSettings(
    intervalDuration: Duration(milliseconds: 500),
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );
  final TileLayer tileLayer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.app',
  );

  MapRoute? route;

  void destroyRoute() {
    route = null;
    setState(() {
    });
  }

  void refresh() {
    setState(() { });
  }

  void updatePosition() async {
    var perm = await Geolocator.checkPermission();
    print(perm);
    while (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
      await Future.delayed(const Duration(milliseconds: 250));
      print("e");
      perm = await Geolocator.checkPermission();
    }
    var position2 = await Geolocator.getCurrentPosition();
    route = await MapRoute.createNewRoute(position2.latitude, position2.longitude, 50.844770, -0.775550);
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        setState(() {
          if (position != null) {
            route?.update(LatLng(position.latitude, position.longitude));
          }
          userPosition = LatLng(position == null ? 0 : position.latitude, position == null ? 0 : position.longitude);   
        });
      print("${position?.latitude}, ${position?.longitude}");
    });
    var position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), mapController.camera.zoom);
  }

  @override
  void initState() {
    super.initState();
    buttonOffset = calculateButtonOffset(0);
    //timer = Timer.periodic(Duration(seconds: 5), (Timer t) => backgroundUpdate());
    SystemManager().mainPage = this;
    Timer.run(() {updatePosition();});
  }

  double panelMinSize = 53;
  double panelMaxSize = 500;
  double buttonOffset = 0;
  double calculateButtonOffset(double position) {
    return panelMinSize + ((panelMaxSize - panelMinSize) * position);
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
            MarkerLayer(markers: [Marker(point: userPosition, width: 30, height: 30, child: const Center(child: Icon(Icons.location_on)))]),
            MarkerLayer(markers: (route != null ? route!.test : [])),
            PolylineLayer(polylines: [(route != null ? Polyline(points: route!.pathPoints, color: Colors.blue, strokeWidth: 5) : Polyline(points: []))])
          ],
        ),
        
        Container(
          height: MediaQuery.of(context).size.height - buttonOffset, width: MediaQuery.of(context).size.width, 
          alignment: Alignment.bottomRight,
          child: ElevatedButton(child: Icon(Icons.route), 
            onPressed: () {
              if (!SystemManager().menuIsShowingRoute) {
                panelKey.currentState!.push(MaterialPageRoute(builder: (context) => RoutePage())); 
                SystemManager().menuIsShowingRoute = true;
              }
              panelController.open();
              },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(10),
            ),
          ), 
        ),

        SlidingUpPanel(
          controller: panelController,
          onPanelSlide: (position) {buttonOffset = calculateButtonOffset(position); setState(() {});},
          minHeight: panelMinSize,
          maxHeight: panelMaxSize,
          padding: EdgeInsets.all(2),
          onPanelClosed: () {FocusManager.instance.primaryFocus?.unfocus();},
          panel: Navigator(
            key: panelKey,
            onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => const MainMenu()),
          ),
        )
      ],
    );
  }
}