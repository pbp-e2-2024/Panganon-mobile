import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/screens/daftar_makanan/restaurant_detail.dart';
import '../../models/restaurant.dart';

class FilterOptions {
  String? name;
  double? minRating;
  double? maxRating;
  String? address;
  int? ratingCount;
  String? ordering;
}

class DaftarMakananPage extends StatefulWidget {
  const DaftarMakananPage({super.key});
  

  @override
  State<DaftarMakananPage> createState() => _DaftarMakananPageState();
}

class _DaftarMakananPageState extends State<DaftarMakananPage> {
  List<Restaurant> allRestaurants = []; // Store all restaurants
  List<Restaurant> filteredRestaurants = []; // Store filtered results
  bool isLoading = true;
  FilterOptions filters = FilterOptions();

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  void applyFilters() {
    setState(() {
      filteredRestaurants = allRestaurants.where((restaurant) {
        // Name filter
        if (filters.name?.isNotEmpty ?? false) {
          if (!restaurant.name.toLowerCase().contains(filters.name!.toLowerCase())) {
            return false;
          }
        }

        // Rating range filter
        if (filters.minRating != null && restaurant.rating < filters.minRating!) {
          return false;
        }
        if (filters.maxRating != null && restaurant.rating > filters.maxRating!) {
          return false;
        }

        // Address filter
        if (filters.address?.isNotEmpty ?? false) {
          if (!restaurant.address.toLowerCase().contains(filters.address!.toLowerCase())) {
            return false;
          }
        }

        // Rating count filter
        if (filters.ratingCount != null) {
          final ranges = {
            25: (1, 25),
            50: (26, 50),
            100: (51, 100),
            200: (101, 1000)
          };
          final (minCount, maxCount) = ranges[filters.ratingCount]!;
          if (restaurant.ratingAmount < minCount || restaurant.ratingAmount > maxCount) {
            return false;
          }
        }

        return true;
      }).toList();

      // Apply sorting
      if (filters.ordering != null) {
        switch (filters.ordering) {
          case 'rating_high':
            filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case 'rating_low':
            filteredRestaurants.sort((a, b) => a.rating.compareTo(b.rating));
            break;
          case 'name_asc':
            filteredRestaurants.sort((a, b) => a.name.compareTo(b.name));
            break;
          case 'name_desc':
            filteredRestaurants.sort((a, b) => b.name.compareTo(a.name));
            break;
        }
      }
    });
  }

  Future<void> fetchRestaurants() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/daftar_toko/json/'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          allRestaurants = jsonData.map((data) => Restaurant.fromJson(data)).toList();
          filteredRestaurants = List.from(allRestaurants); // Initialize filtered list
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
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
    var tempFilters = FilterOptions()
      ..name = filters.name
      ..minRating = filters.minRating
      ..maxRating = filters.maxRating
      ..address = filters.address
      ..ratingCount = filters.ratingCount
      ..ordering = filters.ordering;

    final orderingOptions = {
      'rating_high': 'Rating (High to Low)',
      'rating_low': 'Rating (Low to High)',
      'name_asc': 'Name (A to Z)',
      'name_desc': 'Name (Z to A)',
    };

    final ratingCountOptions = {
      25: '1-25 ratings',
      50: '26-50 ratings',
      100: '51-100 ratings',
      200: '101-1000 ratings',
    };

    final ratingOptions = List.generate(5, (index) => (index + 1).toDouble());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: tempFilters.name),
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => tempFilters.name = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: tempFilters.address),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => tempFilters.address = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: tempFilters.minRating,
                        decoration: const InputDecoration(
                          labelText: 'Min Rating',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Any'),
                          ),
                          ...ratingOptions.map(
                            (rating) => DropdownMenuItem(
                              value: rating,
                              child: Text(rating.toString()),
                            ),
                          ),
                        ],
                        onChanged: (value) => setModalState(() => tempFilters.minRating = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: tempFilters.maxRating,
                        decoration: const InputDecoration(
                          labelText: 'Max Rating',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Any'),
                          ),
                          ...ratingOptions.map(
                            (rating) => DropdownMenuItem(
                              value: rating,
                              child: Text(rating.toString()),
                            ),
                          ),
                        ],
                        onChanged: (value) => setModalState(() => tempFilters.maxRating = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: tempFilters.ratingCount,
                  decoration: const InputDecoration(
                    labelText: 'Rating Count Range',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Any'),
                    ),
                    ...ratingCountOptions.entries.map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(() => tempFilters.ratingCount = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempFilters.ordering,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Default'),
                    ),
                    ...orderingOptions.entries.map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(() => tempFilters.ordering = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempFilters = FilterOptions();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => filters = tempFilters);
                        Navigator.pop(context);
                        applyFilters();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter'),
            onPressed: _showFilterBottomSheet,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        label: const Text('Filter'),
        icon: const Icon(Icons.filter_alt),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : filteredRestaurants.isEmpty // Use filteredRestaurants instead of restaurants
              ? const Center(child: Text('No restaurants found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRestaurants.length, // Use filteredRestaurants
                  itemBuilder: (context, index) {
                    final restaurant = filteredRestaurants[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailPage(
                                  restaurant: restaurant,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            restaurant.name,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  restaurant.address,
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, 
                                            size: 20, 
                                            color: Colors.white
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            restaurant.rating.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (restaurant.services.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: restaurant.services
                                        .take(3)
                                        .map((service) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                service,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                                if (restaurant.priceRange != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    restaurant.priceRange!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}