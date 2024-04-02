import 'dart:convert';

import 'package:flutter/material.dart';
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

class BookmarkMenuState extends State<BookmarkMenu> {
  final GlobalKey<NavigatorState> searchKey = GlobalKey<NavigatorState>();

  void getBookmarks() async {

    if (ServerManager().idTokenPost != null) {
      final searchResponse = await http.post(Uri.parse("http://130.162.169.225/getbookmarks.php"), headers: ServerManager().idTokenPost, body: ServerManager().idTokenPost);
      if (searchResponse.statusCode == 200) {
        jsonDecode(searchResponse.body);
      }
      
    }
  } 
  
  @override Widget build(BuildContext context) {
    return FilledButton(child: Icon(Icons.abc), onPressed: () => getBookmarks(),);
  }
}