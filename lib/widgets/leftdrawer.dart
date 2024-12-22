import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/screens/about_me/aboutme_page.dart';
import 'package:panganon_mobile/screens/daftar_makanan/daftar_makanan.dart';
import 'package:panganon_mobile/screens/login.dart';
import 'package:panganon_mobile/screens/forum/home_forum.dart'; // Change this import
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
      backgroundColor: Colors.white, // Change from Colors.black87 to Colors.white
      child: ListView(
        padding: EdgeInsets.zero, // Menghilangkan padding default
        children: <Widget>[
          // Bagian Drawer Header, menampilkan gambar profil dan username
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: const TextStyle(color: Colors.black), // Change text color to black
            ),
            accountEmail: const Text(
              'user@example.com',
              style: TextStyle(color: Colors.black54), // Change text color to dark grey
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl), // Gambar profil pengguna
              backgroundColor: Colors.grey[800], // Warna latar belakang gambar profil
            ),
            decoration: const BoxDecoration(
              color: Colors.white, // Change from Colors.black87 to Colors.white
            ),
          ),
          // Menu-item lainnya
          ListTile(
            leading: const Icon(Icons.info, color: Colors.black), // Change from white to black
            title: const Text('About Me', style: TextStyle(color: Colors.black)), // Change from white to black
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
              // TODO: Replace with actual navigation when page is ready
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feature coming soon!")),
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
                    username: username,
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
              // TODO: Replace with actual navigation when page is ready
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feature coming soon!")),
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
      ),
    );
  }
}
