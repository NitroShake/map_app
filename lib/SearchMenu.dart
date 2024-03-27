import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_app/SystemManager.dart';

import 'SearchResultRow.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/AddressSearchResult.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchMenu extends StatefulWidget {
  const SearchMenu({super.key, required this.title});

  final String title;

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  List<Widget> searchResults = List.empty(growable: true);
  final ButtonStyle queryResultButtonStyle = OutlinedButton.styleFrom(
    shape: const LinearBorder(top: LinearBorderEdge()),
    padding: EdgeInsets.all(10)
  );

  void searchAddresses(String string) async {
    searchResults = List.empty(growable: true);
    List<AddressSearchResult> entries = List<AddressSearchResult>.empty();
    final response = await http
      .get(Uri.parse('http://nominatim.openstreetmap.org/search?format=geocodejson&addressdetails=1&q=${Uri.encodeComponent(string)}'));
    
    if (response.statusCode == 200) {
      print(response.body);

      //geocodejson
      String test = "[${response.body}]";
      List<dynamic> m = json.decode((test));
      Iterable i = m[0]['features'];

      entries = List<AddressSearchResult>.from(i.map((e) => AddressSearchResult.fromJson(e)));
      setState(() {  
        searchResults.add(
          TextField(
          onTap: () { SystemManager().mainPanelController.open(); },
          onSubmitted: searchAddresses,)
        );
        for (var entry in entries) {
          searchResults.add(SearchResultRow(details: entry, optionStyle: queryResultButtonStyle));
        }
      });
    }
  }

  _SearchMenuState() {
    Timer.run(() => setState(() {  
        searchResults.add(
          TextField(
          onTap: () { SystemManager().mainPanelController.open(); },
          onSubmitted: searchAddresses,)
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [Column(children: searchResults,)], padding: EdgeInsets.zero,);
  }
}