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
}

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
}