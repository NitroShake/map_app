import 'dart:async';
import 'dart:convert';
import 'SearchResultRow.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/AddressSearchResult.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SearchMenu extends StatefulWidget {
  final PanelController panelController;

  const SearchMenu({super.key, required this.title, required this.panelController});

  final String title;

  @override
  State<SearchMenu> createState() => _SearchMenuState(panelController);
}

class _SearchMenuState extends State<SearchMenu> {
  late PanelController panelController;
  List<Widget> searchResults = List.empty(growable: true);
  final ButtonStyle menuOptionButtonStyle = OutlinedButton.styleFrom(
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
          onTap: () { panelController.open(); },
          onSubmitted: searchAddresses,)
        );
        for (var entry in entries) {
          searchResults.add(SearchResultRow(details: entry, optionStyle: menuOptionButtonStyle,));
        }
      });
    }
  }

  _SearchMenuState(PanelController pc) {
    panelController = pc;
    Timer.run(() => setState(() {  
        searchResults.add(
          TextField(
          onTap: () { panelController.open(); },
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