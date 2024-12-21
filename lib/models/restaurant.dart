import 'dart:convert';

class Restaurant {
  final String id;
  final String name;
  final double rating;
  final String address;
  final int ratingAmount;
  final String? priceRange;
  final Map<String, String> openingHours;
  final List<String> services;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
    required this.ratingAmount,
    this.priceRange,
    required this.openingHours,
    required this.services,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var fields = json["fields"];
    return Restaurant(
      id: json["pk"],
      name: fields["name"] ?? "",
      rating: (fields["rating"] ?? 0.0).toDouble(),
      address: fields["address"] ?? "",
      ratingAmount: fields["rating_amount"] ?? 0,
      priceRange: fields["price_range"],
      openingHours: Map<String, String>.from(fields["opening_hours"] ?? {}),
      services: List<String>.from(fields["services"] ?? []),
    );
  }
}