import 'dart:convert';

import 'package:map_app/ServerManager.dart';

class TripAdvisorSearchResult {
  final String name;
  final String locationId;

  TripAdvisorSearchResult({required this.name, required this.locationId});
  
  factory TripAdvisorSearchResult.fromJson(Map<String, dynamic> json) {
    try {
      return TripAdvisorSearchResult(
        locationId: json['location_id'],
        name: json['name']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }

  static Future<List<TripAdvisorSearchResult>?> fromQuery(String query, double lat, double lon) async {
    final searchResponse = await ServerManager().makeRequest(Uri.parse("http://130.162.169.225/tasearch.php?lat=${lat}&lon=${lon}&query=${Uri.encodeComponent(query)}"));
    if (searchResponse.statusCode == 200) {
      try {
        Iterable i = json.decode(searchResponse.body)['data'];
        List<TripAdvisorSearchResult> searchResults = List<TripAdvisorSearchResult>.from(i.map((e) => TripAdvisorSearchResult.fromJson(e)));
        return searchResults;
      } catch (e) {
        return null;
      }
    }
    else {
      return null;
    }
  }
}

//note: this isn't used nor finished. it's here anyway. say hi, tripadvisorimage!!!
class TripAdvisorImage {
  final String name;
  final int locationId;

  TripAdvisorImage({required this.name, required this.locationId});
  
  factory TripAdvisorImage.fromJson(Map<String, dynamic> json) {
    try {
      return TripAdvisorImage(
        name: json['location_id'],
        locationId: json['name']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}

class TripAdvisorReview {
  final String? date;
  final int rating;
  final String text;
  final int helpfulVotes;

  TripAdvisorReview({
    required this.date, 
    required this.rating,
    required this.text,
    required this.helpfulVotes
  });
  
  factory TripAdvisorReview.fromJson(Map<String, dynamic> json) {
    try {
      return TripAdvisorReview(
        date: json['date'],
        rating: json['rating'],
        text: (json['text'] as String).replaceAll("â", "'"), //yeah i can't explain this either
        helpfulVotes: json['helpful_votes']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }

  static Future<List<TripAdvisorReview>?> listFromId(String locationId) async {
    final reviewResponse = await ServerManager().makeRequest(Uri.parse("http://130.162.169.225/tareviews.php?id=${locationId}"));
    if (reviewResponse.statusCode == 200) {
      try {
        Iterable i = json.decode(reviewResponse.body)['data'];
        List<TripAdvisorReview> reviews = List<TripAdvisorReview>.from(i.map((e) => TripAdvisorReview.fromJson(e)));
        return reviews;
      } catch (e) {
        return null;
      }
    }
    else {
      return null;
    }

  }
}

class TripAdvisorDetails {
  final String? description;
  final int? rating;
  final int? numReviews;
  final String? websiteLink;
  final String taLink;

  TripAdvisorDetails({
    required this.description, 
    required this.rating,
    required this.numReviews,
    required this.websiteLink,
    required this.taLink
    });
  
  factory TripAdvisorDetails.fromJson(Map<String, dynamic> json) {
    try {
      return TripAdvisorDetails(
        description: json['description'],
        rating: (json['rating'] != null ? double.parse(json['rating']).round() : null) ,
        numReviews: (json['rating'] != null ? double.parse(json['num_reviews']).round() : null),
        websiteLink: json['website'],
        taLink: json['web_url']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }

  static Future<TripAdvisorDetails?> fromId(String locationId) async {
    final detailResponse = await ServerManager().makeRequest(Uri.parse("http://130.162.169.225/tadetails.php?id=${locationId}"));
    TripAdvisorDetails? taDetails = null;
    if (detailResponse.statusCode == 200) {
      try {
        Map<String, dynamic> map = json.decode(detailResponse.body);
        taDetails = TripAdvisorDetails.fromJson(map);
        return taDetails;
      }
      catch (e) {
        return null;
      }
    }
    else {
      return null;
    }
  }
}