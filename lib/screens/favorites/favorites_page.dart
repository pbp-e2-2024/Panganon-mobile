import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:panganon_mobile/screens/favorites/favorites.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Untuk CookieRequest
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FavoriteRestaurantsScreen extends StatefulWidget {
  @override
  _FavoriteRestaurantsScreenState createState() => _FavoriteRestaurantsScreenState();
}

class _FavoriteRestaurantsScreenState extends State<FavoriteRestaurantsScreen> {
  List<dynamic> userFavorites = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    // Replace with your API endpoint to fetch favorite restaurants
    final response = await http.get(Uri.parse('https://brian-altan-panganon.pbp.cs.ui.ac.id/favorites'));

    if (response.statusCode == 200) {
      setState(() {
        userFavorites = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load favorites');
    }
  }

  Future<void> removeFavorite(int restaurantId) async {
    // Replace with your API endpoint to remove a favorite restaurant
    final response = await http.post(
      Uri.parse('https://brian-altan-panganon.pbp.cs.ui.ac.id/favorites/remove_favorite/$restaurantId/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Successfully removed.')),
        );
        fetchFavorites();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to remove.')),
        );
      }
    } else {
      // Handle network error
      print('Failed to remove favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Favorite Restaurants'),
      ),
      body: userFavorites.isEmpty
          ? Center(
              child: Text('No favorite restaurants found.'),
            )
          : ListView.builder(
              itemCount: userFavorites.length,
              itemBuilder: (context, index) {
                final restaurant = userFavorites[index]['restaurant'];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Rating: ${restaurant['rating']}'),
                        SizedBox(height: 4),
                        Text('Address: ${restaurant['address']}'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => removeFavorite(userFavorites[index]['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('Remove From Favorite'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}