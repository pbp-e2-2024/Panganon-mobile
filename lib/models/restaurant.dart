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
    // Extract fields from Django's serialized format
    final fields = json['fields'] as Map<String, dynamic>;
    
    return Restaurant(
      id: json['pk'].toString(),
      name: fields['name'] ?? '',
      rating: fields['rating']?.toDouble() ?? 0.0,
      address: fields['address'] ?? '',
      ratingAmount: fields['rating_amount'] ?? 0,
      priceRange: fields['price_range'],
      openingHours: Map<String, String>.from(fields['opening_hours'] ?? {}),
      services: List<String>.from(fields['services'] ?? []),
    );
  }
}