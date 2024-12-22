import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/models/aboutme_entry.dart';
import 'package:panganon_mobile/screens/about_me/aboutme_page.dart';
import 'package:panganon_mobile/screens/login.dart';
import 'package:panganon_mobile/screens/menu.dart';
import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  late Future<AboutMeModels> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserID();
  }

  Future<AboutMeModels> fetchUserID() async {
    try {
      final request = context.read<CookieRequest>();
      
      final response = await request.get('http://127.0.0.1:8000/profile/show_json_all/')
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      
      if (response == null) {
        throw Exception('Empty response from server');
      }
      
      // Directly convert and return response
      if (response is Map) {
        return AboutMeModels.fromJson(Map<String, dynamic>.from(response));
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/auth/logout_flutter/'), // Ganti dengan URL logout Anda
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
      backgroundColor: Colors.black87, // Background drawer lebih gelap
      child: FutureBuilder<AboutMeModels>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Saat data sedang diambil, tampilkan indikator loading
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Jika ada error, tampilkan pesan error
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (snapshot.hasData) {
            // Setelah data berhasil diambil, tampilkan drawer dengan informasi pengguna
            final user = snapshot.data!;
            final String profileImageUrl = 'http://127.0.0.1:8000/auth/image/${user.userID}/';

            return ListView(
              padding: EdgeInsets.zero, // Menghilangkan padding default
              children: <Widget>[
                // Header Kustom tanpa email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.black87, // Menyesuaikan dengan tema gelap
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(profileImageUrl), // Gambar profil pengguna
                        backgroundColor: Colors.grey[800], // Warna latar belakang gambar profil
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          '@${user.username}', // Menambahkan '@' sebelum username
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(username: user.username, profileImageUrl: profileImageUrl),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title: const Text('About Me', style: TextStyle(color: Colors.white)),
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
                  leading: const Icon(Icons.fastfood, color: Colors.white),
                  title: const Text('Daftar Makanan', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Aksi untuk membuka halaman Daftar Makanan
                    Navigator.pushNamed(context, '/food_list');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.white),
                  title: const Text('Favourite', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Aksi untuk membuka halaman Favourite
                    Navigator.pushNamed(context, '/favourite');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum, color: Colors.white),
                  title: const Text('Forum', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Aksi untuk membuka halaman Forum
                    Navigator.pushNamed(context, '/forum');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event, color: Colors.white),
                  title: const Text('Event', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Aksi untuk membuka halaman Event
                    Navigator.pushNamed(context, '/event');
                  },
                ),
                const Divider(color: Colors.white), // Garis pemisah berwarna putih
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.white),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    _logout(context); // Panggil fungsi logout saat item ini dipilih
                  },
                ),
              ],
            );
          } else {
            // Jika tidak ada data yang tersedia, tampilkan pesan default
            return const Center(
              child: Text(
                'No user data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}