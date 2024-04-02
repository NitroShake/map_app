import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/AddressSearchResult.dart';
import 'package:map_app/ApiKeys.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SystemManager.dart';
import 'package:map_app/TripAdvisorAPI.dart';

class AddressInformationPage extends StatefulWidget {
  final AddressSearchResult details;

  const AddressInformationPage({super.key, required this.title, required this.details});

  final String title;

  @override
  State<AddressInformationPage> createState() => _AddressInformationPage(details: details);
}

class _AddressInformationPage extends State<AddressInformationPage> {
  AddressSearchResult details;
  ButtonStyle buttonStyle = FilledButton.styleFrom(
    padding: EdgeInsets.zero
  );
  _AddressInformationPage({required this.details}) {
    getTripAdvisorInfo();
  }

  Widget taDetails = Column();
  List<Widget> taReviews = List.empty(growable: true);

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

  List<Widget> createStarRating(int rating) {
    List<Widget> icons = List.empty(growable: true);
    int starsToCreate = 5;
    while (starsToCreate > 0) {
      if (rating > 0) {
        icons.add(Icon(Icons.star));
        rating--;
      }
      else {
        icons.add(Icon(Icons.star_outline));
      }
      starsToCreate--;
    }
    return icons;
  }

  void getTripAdvisorInfo() async {
    String searchQuery = '${details.name} ${details.street ?? ""}';
    final searchResponse = await http.get(Uri.parse("https://api.content.tripadvisor.com/api/v1/location/search?key=${ApiKeys().tripAdvisorKey}&latLong=${details.lat},${details.lon}&radius=5&radiusUnit=km&searchQuery=${Uri.encodeComponent(searchQuery)}"));
    if (searchResponse.statusCode == 200) {
      print("11111");
      Iterable i = json.decode(searchResponse.body)['data'];
      List<TripAdvisorSearchResult> searchResults = List<TripAdvisorSearchResult>.from(i.map((e) => TripAdvisorSearchResult.fromJson(e)));

      TripAdvisorSearchResult? result;
      for (TripAdvisorSearchResult r in searchResults) {
        if (r.name.toLowerCase().contains(details.name.toLowerCase()) || details.name.toLowerCase().contains(r.name.toLowerCase())) {
          result = r;
        }
      } 

      if (result != null) {
        final detailResponse = await http.get(Uri.parse("https://api.content.tripadvisor.com/api/v1/location/${result.locationId}/details?key=${ApiKeys().tripAdvisorKey}"));
        if (detailResponse.statusCode == 200) {
          print("222222");
          Map<String, dynamic> map = json.decode(detailResponse.body);
          TripAdvisorDetails details = TripAdvisorDetails.fromJson(map);
          setState(() {
            taDetails = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TripAdvisor Results for ${result!.name}"),
                Row(children: createStarRating(details.rating) + [Text("${details.numReviews} reviews")]),
                Text(details.description ?? ""),
                details.websiteLink != null ? Text("Read More: ${details.websiteLink}") : Container(),
              ],
            );          
          });
        }
        else {
          Map<String, dynamic> map = json.decode(detailResponse.body);
          print(map['error']['message']);
          print(map['error']['type']);
          print(map['error']['code']);
        }





        final reviewResponse = await http.get(Uri.parse("https://api.content.tripadvisor.com/api/v1/location/${result.locationId}/reviews?key=${ApiKeys().tripAdvisorKey}"));
        if (reviewResponse.statusCode == 200) {
          print("33333");
          Iterable i = json.decode(reviewResponse.body)['data'];
          List<TripAdvisorReview> reviews = List<TripAdvisorReview>.from(i.map((e) => TripAdvisorReview.fromJson(e)));

          for (TripAdvisorReview review in reviews) {
            setState(() {
              taReviews.add(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: createStarRating(review.rating) + [Text(review.date ?? "")],),
                    Text(review.text),
                    Text("${review.helpfulVotes} ${review.helpfulVotes == 1 ? "person" : "people"} found this helpful")
                  ]
                )
              );          
            });
          }
        }
      }

    }
  }

  IconData bookmarkIcon = Icons.bookmark_outline;
  void addBookmark() async {
    if (await ServerManager().addBookmark(details.id, details.lat, details.lon, details.name)) {
      bookmarkIcon = Icons.bookmark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(onPressed: Navigator.of(context).pop, child: const Text("< Back")),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assembleDetails([((details.houseNumber != null && details.street != null) ? details.houseNumber! + " " + details.street! : details.name) != (details.city ?? details.county) ? 
                      (details.houseNumber != null ? details.houseNumber! + " " + details.street! : details.name) : null, details.city ?? details.county]), textScaler: const TextScaler.linear(1.7), softWrap: true,),
                    Text(assembleDetails([(details.houseNumber == null ? details.street : null), details.postcode, details.county, details.state, details.country]), textScaler: const TextScaler.linear(1.1), softWrap: true,),
                    Text(assembleDetails([details.osmValue]), textScaler: const TextScaler.linear(1.1), softWrap: true,),
                  ],
                ),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton(onPressed: () => {addBookmark()}, style: buttonStyle, child: Icon(bookmarkIcon)),
                    Row(children: [
                      FilledButton(onPressed: () => {}, style: buttonStyle, child: const Row(children: [Icon(Icons.route), Icon(Icons.directions_car)])),
                      FilledButton(onPressed: () => {}, style: buttonStyle, child: const Row(children: [Icon(Icons.route), Icon(Icons.directions_walk)])),
                    ],),
                ],)
              ],
            ),
            taDetails,
            Column(
              children: taReviews,
            )

            

          ],
        )
      ],
    );
  }
}