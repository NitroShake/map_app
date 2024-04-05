import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/LocationInfoPage.dart';
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/SystemManager.dart';

class SearchResultRow extends StatelessWidget {
  
  SearchResultRow({
    required this.details,
  });
  final LocationDetails details;
  final ButtonStyle rowButtonStyle = OutlinedButton.styleFrom(
    shape: const LinearBorder(top: LinearBorderEdge()),
    padding: EdgeInsets.all(10)
  );

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
          SystemManager().getMapController().move(LatLng(details.lat, details.lon), min(SystemManager().getMapController().camera.zoom, 15), offset: const Offset(0, -100));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationInfoPage(title: "Location Details", details: details,)),
          );
        }, 
        style: rowButtonStyle,
        child: Align(alignment: Alignment.centerLeft, child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assembleDetails([(details.houseNumber != null && details.street != null) ? details.houseNumber! + " " + details.street! : details.name, details.city ?? details.county]), textScaler: TextScaler.linear(1.15 * MediaQuery.of(context).textScaleFactor)),
            Text(assembleDetails([details.postcode, details.county, details.state, details.country, details.osmValue]), textScaler: TextScaler.linear(0.85 * MediaQuery.of(context).textScaleFactor)),
          ],
        ),
      )
    );
  }
}