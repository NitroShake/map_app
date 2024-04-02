import 'dart:async';
import 'dart:convert';
import 'package:map_app/SystemManager.dart';

import 'SearchResultRow.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/LocationDetails.dart';

class SearchMenu extends StatefulWidget {
  const SearchMenu({super.key, required this.title});

  final String title;

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  List<Widget> searchResults = List.empty(growable: true);

  void searchAddresses(String string) async {
    searchResults = List.empty(growable: true);
    List<LocationDetails> entries = List<LocationDetails>.empty();
    final response = await http
      .get(Uri.parse('http://nominatim.openstreetmap.org/search?format=geocodejson&addressdetails=1&q=${Uri.encodeComponent(string)}'));
    
    if (response.statusCode == 200) {
      print(response.body);

      //geocodejson
      String test = "[${response.body}]";
      List<dynamic> m = json.decode((test));
      Iterable i = m[0]['features'];

      entries = List<LocationDetails>.from(i.map((e) => LocationDetails.fromJson(e)));
      setState(() {  
        searchResults.add(
          TextField(
          onTap: () { SystemManager().getMainPanelController().open(); },
          onSubmitted: searchAddresses,)
        );
        for (var entry in entries) {
          searchResults.add(SearchResultRow(details: entry));
        }
      });
    }
  }

  _SearchMenuState() {
    Timer.run(() => setState(() {  
        searchResults.add(
          TextField(
          onTap: () { SystemManager().getMainPanelController().open(); },
          onSubmitted: searchAddresses,
          decoration: InputDecoration(
            
          ),)
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [Column(children: searchResults,)], padding: EdgeInsets.zero,);
  }
}