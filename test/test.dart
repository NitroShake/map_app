// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/ServerManager.dart';
import 'package:http/http.dart' as http;
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

  Future<void> getGoogleMockDetails() async {
    //http.post(Uri.https('https://www.googleapis.com/oauth2/v4/token'), headers: {
    //  'grant_type': '',
    //  'client_id': '465811042306-dom6qsketvf42g5k2v7uva69memphqg5.apps.googleusercontent.com',
    //  'client_secret': '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'
    //});

    var searchResponse = await http.post(Uri.parse('https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${Uri.encodeComponent('map-app-testing@mapapp-418912.iam.gserviceaccount.com')}:generateIdToken'), headers: {
      'audience': 'ss',
      'includeEmail': 'false'
    });
    print(searchResponse.body);
  }


  late MockGoogleSignIn googleSignIn;
  setUp(() {
    googleSignIn = MockGoogleSignIn();
  });

  test('should return idToken and accessToken when authenticating', () async {
    await getGoogleMockDetails();
    final signInAccount = await googleSignIn.signIn();
    final signInAuthentication = await signInAccount!.authentication;
    expect(signInAuthentication, isNotNull);
    expect(googleSignIn.currentUser, isNotNull);
    expect(signInAuthentication.accessToken, isNotNull);
    expect(signInAuthentication.idToken, isNotNull);
    ServerManager().user = signInAccount;
    ServerManager().idTokenPost = Map<String, String>.from({"id_token": 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImUxYjkzYzY0MDE0NGI4NGJkMDViZjI5NmQ2NzI2MmI2YmM2MWE0ODciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0NjU4MTEwNDIzMDYtZG9tNnFza2V0dmY0Mmc1azJ2N3V2YTY5bWVtcGhxZzUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0NjU4MTEwNDIzMDYtZG9tNnFza2V0dmY0Mmc1azJ2N3V2YTY5bWVtcGhxZzUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTM3MjU0MzkxMTc3MDEwMTI2OTgiLCJlbWFpbCI6ImNhbWVyb25za2VycnkxMzRAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJqRU5zX29hMV9sLWF2TnhoalJGZktnIiwiaWF0IjoxNzE0MjU3NzYxLCJleHAiOjE3MTQyNjEzNjF9.KSB0X3Z7eptWBSRswvkcTZIP-CS-hsa00BsxQ2zJkKCVIgOQhCOVBqKSl3XoKansa2r3gVF338G5mOpPPmRX242hkxX7OrfWO0t__Jy2DJtnqpSHuOjIsRN-_sMIDnZKAev77FZCdvpshe1T1lCnJ0SP2O1qXpD22PiU9UgIAsrslELFlxHvkrlxjOqSP1UBPZoRh5URFHoWl97ou6VMnrBNA7x23ENpq4zqQu5K5JN9mXmwnf9KwTNnslnTG51R6FVFTQinsJYxO_7Diu_qDq7MRDrLd_FiSnvhqo34Bcxlf5TdSOGbvWfmeNY8I08oGE2aKgsRGYX_O8WHlfYT1w'});
    await ServerManager().loadBookmarks();
    print(ServerManager().body.substring(0));
    print(ServerManager().responseCode);
    print(signInAuthentication.idToken);
  });

  test('should return null when google login is cancelled by the user',
      () async {
    googleSignIn.setIsCancelled(true);
    final signInAccount = await googleSignIn.signIn();
    expect(signInAccount, isNull);
  });
  test('testing google login twice, once cancelled, once not cancelled at the same test.', () async {
   googleSignIn.setIsCancelled(true);
    final signInAccount = await googleSignIn.signIn();
    expect(signInAccount, isNull);
    googleSignIn.setIsCancelled(false);
    final signInAccountSecondAttempt = await googleSignIn.signIn();
    expect(signInAccountSecondAttempt, isNotNull);
  });
}
