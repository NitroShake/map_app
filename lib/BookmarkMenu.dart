import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/SearchResultRow.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SearchMenu.dart';
import 'package:map_app/SettingsMenu.dart';
import 'package:map_app/SystemManager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

class BookmarkMenu extends StatefulWidget {
  const BookmarkMenu({super.key});

  @override
  State<BookmarkMenu> createState() => BookmarkMenuState();
}

class BookmarkMenuState extends State<BookmarkMenu> with AutomaticKeepAliveClientMixin {
  final GlobalKey<NavigatorState> searchKey = GlobalKey<NavigatorState>();
  List<SearchResultRow> bookmarkWidgets = List.empty(growable:true);
  Widget signInPrompt = Container();

  BookmarkMenuState() {
    SystemManager().bookmarkMenu = this;
    if (ServerManager().user == null) {
      signInPrompt = Text("Sign in via Settings to access bookmarks and extra details about locations.");
    }
    else {signInPrompt = Container();}
  }

  void refresh() {
    if (ServerManager().user == null) {
      signInPrompt = Text("Sign in via Settings to access bookmarks and extra details about locations.");
    }
    else {signInPrompt = Container();}
    setState(() {
      
    });
  }

  void updateBookmarkList(List<LocationDetails> list) {
    List<SearchResultRow> newBookmarks = List.empty(growable: true);
    for (var i in list) {
      newBookmarks.add(SearchResultRow(details: i));
    }
    setState(() {
      bookmarkWidgets = newBookmarks;   
    });
  }

  late List<Widget> refreshButton = [FilledButton(onPressed: () {if (ServerManager().idTokenPost != null) {ServerManager().loadBookmarks();}}, child: Text("Refresh"))];
  
  @override
  Widget build(BuildContext context) {
    return ListView(children: [Column(children: refreshButton + [signInPrompt] + bookmarkWidgets,)], padding: EdgeInsets.zero,);
  }

  @override
  bool get wantKeepAlive => true;
}