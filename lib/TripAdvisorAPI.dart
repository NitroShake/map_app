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
        text: json['text'],
        helpfulVotes: json['helpful_votes']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}

class TripAdvisorDetails {
  final String? description;
  final int rating;
  final int numReviews;
  final String? websiteLink;

  TripAdvisorDetails({
    required this.description, 
    required this.rating,
    required this.numReviews,
    required this.websiteLink,
    });
  
  factory TripAdvisorDetails.fromJson(Map<String, dynamic> json) {
    try {
      return TripAdvisorDetails(
        description: json['description'],
        rating: double.parse(json['rating']).round(),
        numReviews: double.parse(json['num_reviews']).round(),
        websiteLink: json['website_link']
      );
    }
    on Exception catch (e) {throw Exception("JSON invalid. ${e.toString()}");}
  }
}