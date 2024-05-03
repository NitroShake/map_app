// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/LocationInfoPage.dart';
import 'package:map_app/MainMenu.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/SearchMenu.dart';
import 'package:map_app/SearchResultRow.dart';
import 'package:map_app/ServerManager.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/SystemManager.dart';
import 'package:map_app/main.dart';

class _HttpOverrides extends HttpOverrides {}

void main() async {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   //await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  MapRoute? route;
  test("Route init", () async {
    HttpOverrides.global = _HttpOverrides();
    route = await MapRoute.createNewRoute(50.770941, -0.870648, 50.844770, -0.775550, "car", "test");
    //verify route information
    print(route!.checkpoints[0].position);
    expect(route!.checkpoints[0].position, LatLng(50.770858, -0.870672));
    expect(route!.checkpoints[9].locationName, "Stockbridge Road");
  });


  test("Route update", () async {
    //verify route updates correctly
    route!.update( LatLng(50.775424, -0.867573));
    expect(route!.checkpoints[0].position, LatLng(50.769986, -0.870364));
  });

  //TODO: this should be seperated into multiple tests
  testWidgets("search menu tests", (widgetTester) async {
    await widgetTester.pumpWidget(const MyApp());
    //tap search tab
    final searchTab = find.byIcon(Icons.search);
    expect(searchTab, findsOneWidget);
    await widgetTester.tap(searchTab);
    await widgetTester.pump(Duration(seconds: 1));

    //find search menu
    final searchMenu = find.byType(SearchMenu);
    expect(searchMenu, findsOneWidget);

    //populate search menu
    final searchMenuState = widgetTester.state(find.byType(SearchMenu));
    (searchMenuState as SearchMenuState).searchResults.add(
      SearchResultRow(details:
        const LocationDetails(
          id: 1,lat: 1,lon: 1,classification: "classification",type: "type",osmkey: "osm_key",osmValue: "osm_value", 
          name: "Test Name", houseNumber: null, street: null, locality: '', district: '', postcode: '', city: '', county: '', state: '', country: '', osmId: 1, osmType: ''
        )
      )
    );
    (searchMenuState as SearchMenuState).update();
    await widgetTester.pump(Duration(seconds: 1));

    //tap search result
    final button = find.byType(OutlinedButton);
    expect(button, findsOneWidget);
    await widgetTester.tap(button);
    await widgetTester.pump(Duration(seconds: 3));

    //check new page's title and buttons
    final titleTest = find.byType(LocationInfoPage);
    expect(titleTest, findsOneWidget);
    final buttons = find.byType(FilledButton);
    expect(buttons, findsNWidgets(2));

    //close any timers
    await widgetTester.pumpAndSettle();
  });

  testWidgets("Settings page tests", (widgetTester) async {
    await widgetTester.pumpWidget(const MyApp());
    //tap settings tab
    final settingsTab = find.byIcon(Icons.settings);
    expect(settingsTab, findsOneWidget);
    print(SystemManager().mainMenu.tabController.index);
    await widgetTester.tap(settingsTab);
    await widgetTester.pump(Duration(seconds: 3));
    print(SystemManager().mainMenu.tabController.index);
    await widgetTester.pumpAndSettle();
  });

  testWidgets("Route page tests", (widgetTester) async {
    await widgetTester.pumpWidget(const MyApp());
    SystemManager().setRoute(MapRoute(
      pathPoints: new List.from([LatLng(0, 0)]), 
      checkpoints: List.from([
        RouteCheckpoint(
          pathPointIndex: 0, 
          modifier: 'left', 
          modifierType: 'end of road', 
          position: LatLng(0,0), 
          locationName: 'end of road name', 
          roundaboutExit: null    
        ),
        RouteCheckpoint(
          pathPointIndex: 0, 
          modifier: 'right', 
          modifierType: 'roundabout', 
          position: LatLng(0,0), 
          locationName: 'roundabout name', 
          roundaboutExit: 1    
        ),
      ]), 
      test: new List.empty(), 
      mode: 'car', 
      destinationName: 'destination name')
    );
    await widgetTester.pump(Duration(seconds: 1));
    var routeButton = find.byType(ElevatedButton);
    expect(routeButton, findsOneWidget);

    await widgetTester.tap(routeButton);
    await widgetTester.pump(Duration(seconds: 1));
    expect(find.text("At the end of the road, turn left"), findsOne);
    expect(find.text("Go right on the roundabout, first exit"), findsOne);

    //cancel route
    final cancelButton = find.widgetWithText(FilledButton, "Cancel Route");
    expect(cancelButton, findsOneWidget);
    await widgetTester.tap(cancelButton);
    await widgetTester.pump(Duration(seconds: 1));
    await widgetTester.tap(find.widgetWithText(TextButton, "Yes"));
    await widgetTester.pump(Duration(seconds: 1));
    expect(find.text("At the end of the road, turn left"), findsNothing);
    routeButton = find.byType(ElevatedButton);
    expect(routeButton, findsNothing);
  });
}
