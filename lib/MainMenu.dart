import 'package:flutter/material.dart';
import 'package:map_app/BookmarkMenu.dart';
import 'package:map_app/SearchMenu.dart';
import 'package:map_app/SettingsMenu.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  final GlobalKey<NavigatorState> searchKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> bookmarkKey = GlobalKey<NavigatorState>();
  late TabController tabController = TabController(length: 3, vsync: this);
  late List<GlobalKey<NavigatorState>> tabNumToKeyLookup;

  MainMenuState() {
    SystemManager().mainMenu = this;
    tabNumToKeyLookup = [searchKey, bookmarkKey];
  }

  void openPageInTab(MaterialPageRoute route, int tabNum) {
    tabController.animateTo(tabNum);
    tabNumToKeyLookup[tabNum].currentState!.push(route);
  }
  
  @override Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: Column ( 
      children: [
        Material(child: TabBar(
          controller: tabController,
          onTap: (value) {SystemManager().getMainPanelController().open();},
          tabs: [
          Semantics(label:"Search Menu", child: Tab(icon: Icon(Icons.search))),
          Semantics(label:"Bookmarks", child: Tab(icon: Icon(Icons.bookmark),),),
          Semantics(label:"Settings", child: Tab(icon: Icon(Icons.settings),),)
        ])),
        Expanded(child: Material(child: TabBarView(
          controller: tabController,
          children: [
          Navigator(
            key: searchKey,
            onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => SearchMenu(title: "Search")),
          ),
          Navigator(
            key: bookmarkKey,
            onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => BookmarkMenu()),
          ),
          SettingsMenu(),
        ]),))
      ],)
    );
  }
}