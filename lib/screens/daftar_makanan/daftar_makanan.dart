import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/restaurant.dart';

class DaftarMakananPage extends StatefulWidget {
  const DaftarMakananPage({super.key});

  @override
  State<DaftarMakananPage> createState() => _DaftarMakananPageState();
}

class _DaftarMakananPageState extends State<DaftarMakananPage> {
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  String? nameFilter;
  double? minRatingFilter;
  String? addressFilter;
  int? ratingCountFilter;
  String? orderingFilter;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    setState(() => isLoading = true);
    
    var url = Uri.parse('http://localhost:8000/daftar_toko/json/');
    var queryParams = <String, String>{};
    
    if (nameFilter != null) queryParams['name'] = nameFilter!;
    if (minRatingFilter != null) queryParams['min_rating'] = minRatingFilter.toString();
    if (addressFilter != null) queryParams['address'] = addressFilter!;
    if (ratingCountFilter != null) queryParams['rating_count'] = ratingCountFilter.toString();
    if (orderingFilter != null) queryParams['ordering'] = orderingFilter!;

    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    try {
      final response = await http.get(url);


      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        
        setState(() {
          restaurants = jsonData.map((data) => Restaurant.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setModalState(() => nameFilter = value),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<double>(
                decoration: const InputDecoration(
                  labelText: 'Minimum Rating',
                  border: OutlineInputBorder(),
                ),
                value: minRatingFilter,
                items: [1.0, 2.0, 3.0, 4.0, 5.0]
                    .map((rating) => DropdownMenuItem(
                          value: rating,
                          child: Text(rating.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setModalState(() => minRatingFilter = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  fetchRestaurants();
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Toko'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurants.isEmpty 
              ? const Center(child: Text('No restaurants found'))
              : ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          restaurant.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(restaurant.address),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                Text(
                                  restaurant.rating.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              '(${restaurant.ratingAmount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (restaurant.priceRange != null) 
                                  Text('Price Range: ${restaurant.priceRange}'),
                                const SizedBox(height: 8),
                                Text('Services: ${restaurant.services.join(", ")}'),
                                const SizedBox(height: 8),
                                const Text('Opening Hours:'),
                                ...restaurant.openingHours.entries.map(
                                  (e) => Text('${e.key}: ${e.value}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}