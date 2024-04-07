// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/MapRoute.dart';

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
    expect(route!.checkpoints[9].locationName, "Southgate");
  });


  test("Route update", () async {
    //verify route updates correctly
    route!.update( LatLng(50.775424, -0.867573));
    expect(route!.checkpoints[0].position, LatLng(50.769986, -0.870364));
  });


  test("Get location details", () async {

  });

  test("Get TripAdvisor details", () => {

  });

  test("UI - Search and load location", () => {

  });

  test("UI - Load and view Route", () => {

  });

  test("UI - Access Bookmark", () => {

  });
}
