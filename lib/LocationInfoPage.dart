import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/MapRoute.dart';
import 'package:map_app/ServerManager.dart';
import 'package:map_app/SystemManager.dart';
import 'package:map_app/TripAdvisorAPI.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationInfoPage extends StatefulWidget {
  final LocationDetails details;

  const LocationInfoPage({super.key, required this.title, required this.details});

  final String title;

  @override
  State<LocationInfoPage> createState() => _AddressInformationPage(details: details);
}

class _AddressInformationPage extends State<LocationInfoPage> {
  LocationDetails details;
  ButtonStyle buttonStyle = FilledButton.styleFrom(
    padding: EdgeInsets.zero
  );
  late String destinationName; //to pass to route
  Widget taDetailsWidget = Column();
  List<Widget> taReviews = List.empty(growable: true);
  bool isDisposed = false;
  bool isBookmarked = false;
  IconData bookmarkIcon = Icons.bookmark_outline;

  _AddressInformationPage({required this.details}) {
    destinationName = assembleDetails([((details.houseNumber != null && details.street != null) ? details.houseNumber! + " " + details.street! : details.name) != (details.city ?? details.county) ? 
                      (details.houseNumber != null ? details.houseNumber! + " " + details.street! : details.name) : null, details.city ?? details.county]);
    if (details.name != null) {
      getTripAdvisorInfo();
    }
    ServerManager().loadBookmarks();
    for (LocationDetails i in ServerManager().bookmarks) {
      if (i.isSameAs(details)) {
        isBookmarked = true;
        Timer.run(() {setState(() {
          bookmarkIcon = Icons.bookmark;
        });});
      }
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

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

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  void getTripAdvisorInfo() async {
    try {
      String searchQuery = '${details.name} ${details.street ?? ""}';
      List<TripAdvisorSearchResult>? searchResults = await TripAdvisorSearchResult.fromQuery(searchQuery, details.lat, details.lon);
      if (searchResults != null) {
        TripAdvisorSearchResult? result;
        for (TripAdvisorSearchResult r in searchResults) {
          if (r.name.toLowerCase().contains(details.name!.toLowerCase()) || details.name!.toLowerCase().contains(r.name.toLowerCase())) {
            result = r;
          }
        } 

        if (result != null) {
          TripAdvisorDetails? taDetails = await TripAdvisorDetails.fromId(result.locationId);
          if (!isDisposed && taDetails != null) {
            setState(() {
              taDetailsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TripAdvisor Results for ${result!.name}", textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor * 1.25)),
                  taDetails.description != null ? Text(taDetails.description ?? "") : Container(),
                  taDetails.websiteLink != null ? FilledButton(child: const Text("View Website"), onPressed: () => _launchUrl(Uri.parse(taDetails!.websiteLink as String)),) : Container(),
                  FilledButton(child: const Text("View on TripAdvisor"), onPressed: () => _launchUrl(Uri.parse(taDetails!.taLink)),),
                  (taDetails!.rating != null) ? Row(children: createStarRating(taDetails.rating as int) + [Text("${taDetails.numReviews} reviews")]) : Container(),
                ],
              );
            });
          }

          if (taDetails != null && taDetails.rating != null) {
            List<TripAdvisorReview>? reviews = await TripAdvisorReview.listFromId(result.locationId);
            if (!isDisposed && reviews != null) {
              taReviews.add(Divider());
              for (TripAdvisorReview review in reviews) {
                setState(() {
                  taReviews.add(
                    Semantics(container: true, label: "${review.rating} star review", child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: createStarRating(review.rating) + [Text(review.date ?? "")],),
                          Text(review.text),
                          Text("${review.helpfulVotes} ${review.helpfulVotes == 1 ? "person" : "people"} found this helpful")
                        ]
                      )
   
                    )
                  );          
                });
              }
            }
          }
        }
      }
    } catch (e) {

    }
  }

  void addBookmark() async {
    if (await ServerManager().addBookmark(details.osmId, details.osmType)) {
      isBookmarked = true;
      setState(() {
        bookmarkIcon = Icons.bookmark;
      });
    }
  }

  void removeBookmark() async {
    if (await ServerManager().removeBookmark(details.osmId, details.osmType)) {
      isBookmarked = false;
      setState(() {
        bookmarkIcon = Icons.bookmark_outline;
      });
    }
  }

  void setRoadRoute() async {
    SystemManager().setRoute(await MapRoute.createNewRoute(SystemManager().getUserPosition().latitude, SystemManager().getUserPosition().longitude, details.lat, details.lon, "car", destinationName));
  }

  void setFootpathRoute() async {
    SystemManager().setRoute(await MapRoute.createNewRoute(SystemManager().getUserPosition().latitude, SystemManager().getUserPosition().longitude, details.lat, details.lon, "foot", destinationName));
  }

  @override
  Widget build(BuildContext context) {
    return
      ListView(
        padding: EdgeInsets.zero,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(container: true, label: "Go back", button:true, excludeSemantics: true, child: TextButton(onPressed: Navigator.of(context).pop, child: const Text("< Back")),),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                  child: Semantics(hidden: false, child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(container: true, hidden: false, child: Text(destinationName, textScaler: TextScaler.linear(1.7 * MediaQuery.of(context).textScaleFactor), softWrap: true,)), 
                      Semantics(container: true, hidden: false, child: Text(assembleDetails([(details.houseNumber == null ? details.street : null), details.postcode, details.county, details.state, details.country]), softWrap: true,)),
                      Text(assembleDetails([details.osmValue]), textScaler: const TextScaler.linear(1.1), softWrap: true,),
                    ],
                  ),
                  ) ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Semantics(label: isBookmarked ? "Remove bookmark" : "Add bookmark", container:true, excludeSemantics: true, button: true, hidden: false, child:
                        FilledButton(onPressed: () {if (!isBookmarked) {addBookmark();} else {removeBookmark();}}, style: buttonStyle, child: Icon(bookmarkIcon)),
                      ),
                      Row(children: [
                        Semantics(label: "Begin navigation", container:true, excludeSemantics: true, button: true, hidden: false, child:
                          FilledButton(onPressed: () {setRoadRoute(); SystemManager().openRoutePage();}, style: buttonStyle, child: const Row(children: [Icon(Icons.route), Icon(Icons.directions_car)])),
                          //FilledButton(onPressed: () {setFootpathRoute(); SystemManager().openRoutePage();}, style: buttonStyle, child: const Row(children: [Icon(Icons.route), Icon(Icons.directions_walk)])),
                        )
                    ],),
                  ],)
                ],
              ),
              Divider(),
              taDetailsWidget,
              Column(
                children: taReviews,
              )
            ],
          )
        ],
      
    );
  }
}