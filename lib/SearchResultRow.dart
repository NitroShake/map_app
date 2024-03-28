import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/AddressInformationPage.dart';
import 'package:map_app/AddressSearchResult.dart';
import 'package:map_app/SystemManager.dart';

class SearchResultRow extends StatelessWidget {
  
  const SearchResultRow({
    required this.details,
    required this.optionStyle,
  });
  final AddressSearchResult details;
  final ButtonStyle optionStyle;

  String assembleDetails(List<String?> components) {
    String string = "";
    for (String? component in components) {
      if (component != null) {
        if (string != "") {
          string += ", ";
        }
        string += component;
      }
    }
    return string;
  }

  @override
  Widget build(BuildContext context) {
      return OutlinedButton(
        onPressed: () {
          SystemManager().mapController.move(LatLng(details.lat, details.long), min(SystemManager().mapController.camera.zoom, 15), offset: const Offset(0, -100));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressInformationPage(title: "Location Details", details: details,)),
          );
        }, 
        style: optionStyle,
        child: Align(alignment: Alignment.centerLeft, child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assembleDetails([(details.houseNumber != null && details.street != null) ? details.houseNumber! + " " + details.street! : details.name, details.city ?? details.county]), textScaler: const TextScaler.linear(1.15)),
            Text(assembleDetails([details.postcode, details.county, details.state, details.country, details.osmValue]), textScaler: const TextScaler.linear(0.85)),
          ],
        ),
      )
    );
  }
}