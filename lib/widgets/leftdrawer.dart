import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/models/aboutme_entry.dart';
import 'package:panganon_mobile/screens/about_me/aboutme_page.dart';
import 'package:panganon_mobile/screens/daftar_makanan/daftar_makanan.dart';
import 'package:panganon_mobile/screens/event/event_list.dart';
import 'package:panganon_mobile/screens/favorites/favorites_page.dart';
import 'package:panganon_mobile/screens/login.dart';
import 'package:panganon_mobile/screens/forum/home_forum.dart'; // Change this import
import 'dart:convert';

import 'package:panganon_mobile/screens/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  late Future<AboutMeModels> _userFuture; // Add this line

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserID();
  }

  Future<AboutMeModels> fetchUserID() async {
    try {
      final request = context.read<CookieRequest>();
      
      final response = await request.get('https://brian-altan-panganon.pbp.cs.ui.ac.id/profile/show_json_all/');
      
      if (response == null) {
        throw Exception('Empty response from server');
      }
      
      // Print response for debugging
      print('Response received: $response');
      
      // Handle both single object and list responses
      if (response is List) {
        // If response is a list, take the first item
        if (response.isNotEmpty) {
          return AboutMeModels.fromJson(Map<String, dynamic>.from(response[0]));
        } else {
          throw Exception('Empty response list');
        }
      } else if (response is Map<String, dynamic>) {
        // If response is a single object
        return AboutMeModels.fromJson(response);
      } else {
        throw Exception('Invalid response format: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://brian-altan-panganon.pbp.cs.ui.ac.id/auth/logout_flutter/'), // Ganti dengan URL logout Anda
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);

    // Menangani respon dari server
    if (response.statusCode == 200) {
      String message = responseBody["message"];
      String uname = responseBody["username"];
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$message Sampai jumpa, $uname.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()), // Pastikan LoginPage ada di aplikasi Anda
        );
      }
    } else {
      String message = responseBody["message"] ?? "Logout failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: FutureBuilder<AboutMeModels>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.black),
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            final String profileImageUrl = 'https://brian-altan-panganon.pbp.cs.ui.ac.id/auth/image/${user.userID}/';

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    user.username,
                    style: const TextStyle(color: Colors.black),
                  ),
                  accountEmail: Text(  // Removed const here
                    '@${user.username}',  // Using string interpolation
                    style: const TextStyle(color: Colors.black54),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black),
                  title: const Text('Home', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(
                          username: user.username,
                          profileImageUrl: profileImageUrl
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.black), // Change from white to black
                  title: const Text('About Me', style: TextStyle(color: Colors.black)), // Change from white to black
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutMePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.black), // Change from white to black
                  title: const Text('Daftar Makanan', style: TextStyle(color: Colors.black)), // Change from white to black
                  onTap: () {
                    // Aksi untuk membuka halaman Daftar Makanan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DaftarMakananPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.black),
                  title: const Text('Favourite', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteRestaurantsScreen()
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum, color: Colors.black),
                  title: const Text('Forum', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumPage(
                          username: user.username,
                          profileImageUrl: profileImageUrl,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event, color: Colors.black),
                  title: const Text('Event', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    // Aksi untuk membuka halaman Daftar Makanan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventListPage(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.black), // Change from white to black
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black), // Change from white to black
                  title: const Text('Logout', style: TextStyle(color: Colors.black)), // Change from white to black
                  onTap: () {
                    _logout(context); // Panggil fungsi logout saat item ini dipilih
                  },
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'No user data available',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
        },
      ),
    );
  }
}