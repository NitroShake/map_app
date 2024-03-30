import 'package:flutter/material.dart';
import 'package:map_app/SearchMenu.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  final GlobalKey<NavigatorState> searchKey = GlobalKey<NavigatorState>();

  MainMenuState() {
    SystemManager().mainMenu = this;
  }
  
  @override Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: Column ( 
      children: [
        Material(child: TabBar(
          onTap: (value) => {SystemManager().getMainPanelController().open()},
          tabs: const [
          Tab(icon: Icon(Icons.search)),
          Tab(icon: Icon(Icons.bookmark),),
          Tab(icon: Icon(Icons.settings),),
        ])),
        Expanded(child: Material(child: TabBarView(children: [
          Navigator(
            key: searchKey,
            onGenerateRoute: (route) => MaterialPageRoute(settings: route, builder: (context) => SearchMenu(title: "Search")),
          ),
          //SearchMenu(title: "Hello", panelController: panelController),
          Icon(Icons.bookmark),
          Icon(Icons.settings),
        ]),))
      ],)
    );
  }
}