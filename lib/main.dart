import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_app/LocationInfoPage.dart';
import 'package:map_app/MainMenu.dart';
import 'package:map_app/RoutePage.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SystemManager.dart';
import 'package:path_provider/path_provider.dart';
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
  late TabController tabController;
  final GlobalKey<NavigatorState> panelKey = GlobalKey<NavigatorState>();
  bool showExtraButtons = false;
  final double minZoom = 2.5;
  final double maxZoom = 20;
  double zoom = 10;

  List<SearchResultRow> searchResults = List.empty(growable: true);
  LatLng userPosition = const LatLng(0, 0);
  late StreamSubscription<Position> positionStream;
  late Timer timer;

  AndroidSettings locationSettings = AndroidSettings(
    intervalDuration: Duration(milliseconds: 500),
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );
  TileLayer tileLayer = TileLayer(
    urlTemplate: '',
    userAgentPackageName: 'com.example.app',
  );

  MapRoute? route = null;

  void destroyRoute() {
    route = null;
    setState(() {
    });
  }

  void refresh() {
    setState(() { });
  }

  void setLowPowerMode(bool enable) {
    locationSettings = AndroidSettings(
      intervalDuration: Duration(milliseconds: enable ? 1000 : 300),
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
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
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        setState(() {
          if (position != null) {
            route?.update(LatLng(position.latitude, position.longitude));
          }
          userPosition = LatLng(position == null ? 0 : position.latitude, position == null ? 0 : position.longitude);   
        });
    });
    var position = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(position.latitude, position.longitude), mapController.camera.zoom);
  }

  final dio = Dio();
  final cachePolicy = CachePolicy.forceCache;
  void initCacheTileLayer() async {
    tileLayer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
      tileProvider: CachedTileProvider (
        dio: dio,
        maxStale: const Duration(days: 7),
        store: HiveCacheStore((await getTemporaryDirectory()).path, hiveBoxName: 'MapCacheStore'),
        // interceptors: [
        //   LogInterceptor(
        //     responseHeader: false,
        //     requestHeader: false,
        //     request: false
        //   )
        // ]
      ),
    );   
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    buttonOffset = calculateButtonOffset(0);
    //timer = Timer.periodic(Duration(seconds: 5), (Timer t) => backgroundUpdate());
    SystemManager().mainPage = this;
    ServerManager().googleSignIn();
    Timer.run(() {
      updatePosition();
      initCacheTileLayer();
    });
  }

  double panelMinSize = 55;
  double panelMaxSize = 500;
  double buttonOffset = 0;
  double calculateButtonOffset(double position) {
    return panelMinSize + ((panelMaxSize - panelMinSize) * position);
  }

  void loadTappedLocation(LatLng point) async {
    LocationDetails? details = await LocationDetails.fromNomReverseSearch(point);
    if (details != null) {
      SystemManager().openPageInTab(MaterialPageRoute(builder: (context) => LocationInfoPage(title: "tapped location", details: details)), 0);
    }
  }

  void sliderZoom(double newZoom) {
    mapController.move(mapController.camera.center, newZoom);
    setState(() {
      zoom = newZoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      textDirection: TextDirection.ltr,
      children: [
        Semantics(enabled: false, hidden: true, focusable: false, onTap: () => print("aeae"), child: 
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onPositionChanged: (position, hasGesture) => setState(() {zoom = position.zoom!;}),
            onLongPress: (position, point) => loadTappedLocation(point),
            initialCenter: const LatLng(51.509364, -0.128928),
            initialZoom: zoom,
            maxZoom: maxZoom,
            minZoom: minZoom,
            cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(const LatLng(-90, -180), const LatLng(90, 180))),
          ),
          children: [
            tileLayer,
            MarkerLayer(markers: [Marker(point: userPosition, width: 30, height: 30, child: const Center(child: Icon(Icons.location_on)))]),
            MarkerLayer(markers: (route != null ? route!.test : [])),
            PolylineLayer(polylines: [(route != null ? Polyline(points: route!.pathPoints, color: Colors.blue, strokeWidth: 5) : Polyline(points: []))])
          ],
        )),
        
        Container(
          height: MediaQuery.of(context).size.height - buttonOffset - 10, width: MediaQuery.of(context).size.width, 
          alignment: Alignment.bottomRight,
          child: Container(height: 200, 
          child: 
            Semantics(container: true, expanded: true, enabled: true, focusable: true, hidden: false, button: true, excludeSemantics: true, blockUserActions: false, onTap: ()  {print("eeee");}, child:
            Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
              route != null ? Semantics(container: true, enabled: true, hidden: false, button: true, obscured: false, excludeSemantics: false, label: "Open Route Instructions", 
                child:ElevatedButton(child: Icon(Icons.route), 
                onPressed: () {
                  if (!SystemManager().menuIsShowingRoute) {
                    SystemManager().openRoutePage();
                  }
                  panelController.open();
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
              )) : Container(),
              SystemManager().isExtraButtonsEnabled ? RotatedBox(
                quarterTurns: 3,
                child: Material(type: MaterialType.transparency, child: Slider(min: minZoom, max: maxZoom, value: zoom, onChanged: (value) {sliderZoom(value);}, )) ,
              ) : Container()
            ],)
          )
          )
        ),

        SlidingUpPanel(
          controller: panelController,
          onPanelSlide: (position) {buttonOffset = calculateButtonOffset(position); showExtraButtons = true; setState(() {}); },
          minHeight: panelMinSize,
          maxHeight: panelMaxSize,
          padding: EdgeInsets.all(3.5),
          onPanelClosed: () {FocusManager.instance.primaryFocus?.unfocus(); showExtraButtons = false; setState(() {});},
          panel: Navigator(
            key: panelKey,
            onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => const MainMenu()),
          ),
          footer: SizedBox( 
            width: MediaQuery.of(context).size.width - 10,
            child: Column( crossAxisAlignment: CrossAxisAlignment.end, children: [SystemManager().isExtraButtonsEnabled && showExtraButtons ? Semantics(container: true, label: "Close Panel", excludeSemantics: true, button: true, child: FilledButton(onPressed: () {panelController.close(); setState(() {showExtraButtons = false;});}, child: Icon(Icons.close))) : Container()])
          ),
        )
      ],
    );
  }

  @override void dispose() {
    ServerManager().timer.cancel();
    super.dispose();
  }
}