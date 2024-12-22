// To parse this JSON data, do
//
//     final favoriteRestaurant = favoriteRestaurantFromJson(jsonString);

import 'dart:convert';

List<FavoriteRestaurant> favoriteRestaurantFromJson(String str) =>
    List<FavoriteRestaurant>.from(json.decode(str).map((x) => FavoriteRestaurant.fromJson(x)));

String favoriteRestaurantToJson(List<FavoriteRestaurant> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FavoriteRestaurant {
  String model;
  String pk;
  FavoriteFields fields;

  FavoriteRestaurant({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory FavoriteRestaurant.fromJson(Map<String, dynamic> json) => FavoriteRestaurant(
        model: json["model"],
        pk: json["pk"],
        fields: FavoriteFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class FavoriteFields {
  int user;
  int restaurant;
  bool isFavorite;

  FavoriteFields({
    required this.user,
    required this.restaurant,
    required this.isFavorite,
  });

  factory FavoriteFields.fromJson(Map<String, dynamic> json) => FavoriteFields(
        user: json["user"],
        restaurant: json["restaurant"],
        isFavorite: json["is_favorite"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "restaurant": restaurant,
        "is_favorite": isFavorite,
      };
}

// To parse this JSON data, do
//
//     final restaurantReview = restaurantReviewFromJson(jsonString);

List<RestaurantReview> restaurantReviewFromJson(String str) =>
    List<RestaurantReview>.from(json.decode(str).map((x) => RestaurantReview.fromJson(x)));

String restaurantReviewToJson(List<RestaurantReview> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RestaurantReview {
  String model;
  String pk;
  ReviewFields fields;

  RestaurantReview({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory RestaurantReview.fromJson(Map<String, dynamic> json) => RestaurantReview(
        model: json["model"],
        pk: json["pk"],
        fields: ReviewFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class ReviewFields {
  int user;
  int restaurant;
  int rating;
  String review;
  DateTime createdAt;

  ReviewFields({
    required this.user,
    required this.restaurant,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory ReviewFields.fromJson(Map<String, dynamic> json) => ReviewFields(
        user: json["user"],
        restaurant: json["restaurant"],
        rating: json["rating"],
        review: json["review"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "restaurant": restaurant,
        "rating": rating,
        "review": review,
        "created_at": createdAt.toIso8601String(),
      };
}