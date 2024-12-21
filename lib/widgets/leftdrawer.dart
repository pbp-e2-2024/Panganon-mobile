import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/screens/about_me/aboutme_page.dart';
import 'package:panganon_mobile/screens/daftar_makanan/daftar_makanan.dart';
import 'package:panganon_mobile/screens/login.dart';
import 'dart:convert';

class LeftDrawer extends StatelessWidget {
  final String username; // Menambahkan username untuk ditampilkan di header
  final String profileImageUrl; // URL untuk gambar profil pengguna

  const LeftDrawer({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

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
      backgroundColor: Colors.black87, // Background drawer lebih gelap
      child: ListView(
        padding: EdgeInsets.zero, // Menghilangkan padding default
        children: <Widget>[
          // Bagian Drawer Header, menampilkan gambar profil dan username
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: const TextStyle(color: Colors.white), // Menampilkan nama pengguna
            ),
            accountEmail: const Text(
              'user@example.com',
              style: TextStyle(color: Colors.white70), // Menampilkan email pengguna (dummy)
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl), // Gambar profil pengguna
              backgroundColor: Colors.grey[800], // Warna latar belakang gambar profil
            ),
            decoration: const BoxDecoration(
              color: Colors.black87, // Menyesuaikan dengan tema gelap
            ),
          ),
          // Menu-item lainnya
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('About Me', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutMePage(username: username),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fastfood, color: Colors.white),
            title: const Text('Daftar Makanan', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
