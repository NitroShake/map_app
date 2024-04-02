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

  BookmarkMenuState() {
    SystemManager().bookmarkMenu = this;
  }

  void loadBookmarks() async {
    List<SearchResultRow> newBookmarks = List.empty(growable: true);
    if (ServerManager().idTokenPost != null) {
      final searchResponse = await http.post(Uri.parse("http://130.162.169.225/getbookmarks.php"), headers: ServerManager().idTokenPost, body: ServerManager().idTokenPost);
      if (searchResponse.statusCode == 200) {
        Iterable iter = json.decode(searchResponse.body);
        String lookupParams = "";
        for (Map<String, dynamic> i in iter) {
          lookupParams += "${i['osm_type'][0].toUpperCase()}${i['osm_id']},";
        }

        final lookupResponse = await http.get(Uri.parse("https://nominatim.openstreetmap.org/lookup?format=geocodejson&addressdetails=1&osm_ids=${lookupParams}"));
        if (lookupResponse.statusCode == 200) {
          Iterable iter = json.decode(lookupResponse.body)['features'];

          List<LocationDetails> results = List<LocationDetails>.from(iter.map((e) => LocationDetails.fromJson(e)));
          for (var i in results) {
            newBookmarks.add(SearchResultRow(details: i));
          }
          setState(() {
            bookmarkWidgets = newBookmarks;   
          });
        }
      }
    }
  } 

  late List<Widget> refreshButton = [FilledButton(onPressed: () {if (ServerManager().idTokenPost != null) {loadBookmarks();}}, child: Text("load"))];
  
  @override
  Widget build(BuildContext context) {
    return ListView(children: [Column(children: refreshButton + bookmarkWidgets,)], padding: EdgeInsets.zero,);
  }

  @override
  bool get wantKeepAlive => true;
}