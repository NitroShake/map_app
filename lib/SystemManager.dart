import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_app/BookmarkMenu.dart';
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/MainMenu.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/RoutePage.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SettingsMenu.dart';
import 'package:map_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SystemManager {
  late MyHomePageState mainPage;
  late MainMenuState mainMenu;
  late BookmarkMenuState? bookmarkMenu = null;
  late SettingsMenuState? settingsMenu = null;
  bool isLowPowerMode = false;
  bool isExtraButtonsEnabled = false;
  final ttsPlayer = FlutterTts();
  RoutePageState? routePage;
  bool menuIsShowingRoute = false;
  late SharedPreferences prefs;

  SystemManager._privateConstructor() {
    ttsPlayer.setLanguage(("en-AU"));
    Timer.run(() { lateInit();});
  }

  void lateInit() async {
    prefs = await SharedPreferences.getInstance();
    setLowPowerMode(prefs.getBool('lowpower') ?? false);
    setExtraButtons(prefs.getBool('extrabuttons') ?? false);
  }

  static final SystemManager _instance = SystemManager._privateConstructor();

  factory SystemManager() {
    return _instance;
  }

  PanelController getMainPanelController() {
    return mainPage.panelController;
  }

  MapController getMapController() {
    return mainPage.mapController;
  }

  MapRoute? getRoute() {
    return mainPage.route;
  }

  LatLng getUserPosition() {
    return mainPage.userPosition;
  }

  void openRoutePage() {
    mainPage.panelKey.currentState!.push(MaterialPageRoute(builder: (context) => RoutePage())); 
    SystemManager().menuIsShowingRoute = true;
  }

  void closeRoutePage() {
    if (routePage != null) {
      routePage!.close();
    }
  }

  void clearRoute() {
    mainPage.route = null;
    if (routePage != null) {
      routePage?.refresh();
    }
    mainPage.refresh();
  }

  void setRoute(MapRoute? route) {
    mainPage.route = route;
    if (routePage != null) {
      routePage?.refresh();
    }
    mainPage.refresh();
  }

  void updateBookmarkUI(List<LocationDetails> list) {
    if (bookmarkMenu != null) {
      bookmarkMenu!.updateBookmarkList(list);
    }
  }

  void updateSignInPromptUI() {
    if (bookmarkMenu != null) {
      bookmarkMenu!.refresh();
    }
    
    if (settingsMenu != null) {
      settingsMenu!.refresh();
    }
  }

  void openPageInTab(MaterialPageRoute route,int tabNum) {
    mainPage.panelController.open();
    mainMenu.openPageInTab(route, tabNum);
  }

  void updatePosition(LatLng position) {
    if (routePage != null) {
      routePage?.refresh();
    }
  }
  
  void ttsSpeak(String text) {
    ttsPlayer.speak(text);
  }

  void setLowPowerMode(bool enable) {
    isLowPowerMode = enable;
    prefs.setBool('lowpower', enable);
    mainPage.setLowPowerMode(enable);
  }

  void setExtraButtons(bool enable) {
    isExtraButtonsEnabled = enable;
    prefs.setBool('extrabuttons', enable);
    mainPage.refresh();
  }
}