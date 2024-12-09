import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:panganon_mobile/models/aboutme_entry.dart';
import 'package:panganon_mobile/screens/about_me/forumpage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Untuk CookieRequest
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AboutMePage extends StatefulWidget {
  final String username; // Menambahkan parameter untuk username yang sedang login

  AboutMePage({required this.username});

  @override
  _AboutMePageState createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late Future<AboutMeModels> futureProfile;
  final List<String> _foodPreferences = [
    'Spicy Food Lover',
    'Sweet Tooth',
    'Sour Seeker',
    'Salt Craver',
    'Bitter Enthusiast',
  ];
  late List<String> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    futureProfile = fetchUserProfile(widget.username); // Mengambil data profile berdasarkan username yang login
  }

  // Fungsi untuk mengambil data JSON dan mengonversinya menggunakan model
  Future<AboutMeModels> fetchUserProfile(String username) async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/profile/show_json_all/');

    if (response is List) {
      // Mencari profile berdasarkan username yang sedang login
      for (var user in response) {
        if (user['username'] == username) {
          return AboutMeModels.fromJson(user); // Kembalikan profile yang sesuai
        }
      }
      throw Exception('User profile not found');
    } else {
      throw Exception('Failed to load user profiles');
    }
  }

  // Dialog untuk mengedit nama
  void _showEditNameDialog(BuildContext context, int userId, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateName(userId, nameController.text);
                Navigator.of(context).pop(); // Menutup dialog setelah update
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateName(int userId, String newName) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/profile/edit_name/$userId/'),
      body: json.encode({'name': newName}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Refresh profile setelah update
        futureProfile = fetchUserProfile(widget.username);
      });
    } else {
      print('Failed to update name');
    }
  }

  // Dialog untuk mengedit bio
  void _showEditBioDialog(BuildContext context, int userId, String currentBio) {
    final TextEditingController bioController = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Bio'),
          content: TextField(
            controller: bioController,
            decoration: const InputDecoration(hintText: "Enter new bio"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateBio(userId, bioController.text);
                Navigator.of(context).pop(); // Menutup dialog setelah update
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBio(int userId, String newBio) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/profile/edit_bio/$userId/'),
      body: json.encode({'bio': newBio}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Refresh profile setelah update
        futureProfile = fetchUserProfile(widget.username);
      });
    } else {
      print('Failed to update bio');
    }
  }

  Future<List<String>> fetchUserPreferences(int userId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/profile/get_preferences/$userId/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['preferences']);
    } else {
      throw Exception('Failed to load preferences');
    }
  }

  void _showEditPreferencesDialog(BuildContext context, int userId, List<String> currentPreferences) {
    // Salin preferensi yang sudah ada
    _selectedPreferences = List.from(currentPreferences);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Food Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _foodPreferences.map((preference) {
              // Cek apakah preferensi sudah ada dalam list yang dipilih
              bool isSelected = _selectedPreferences.contains(preference);

              return CheckboxListTile(
                title: Text(preference),
                value: isSelected,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected != null) {
                      if (selected) {
                        // Jika dipilih, tambahkan ke _selectedPreferences
                        _selectedPreferences.add(preference);
                      } else {
                        // Jika tidak dipilih, hapus dari _selectedPreferences
                        _selectedPreferences.remove(preference);
                      }
                    }
                  });
                },
                activeColor: isSelected ? Colors.green : Colors.grey, // Ubah warna saat dipilih
                checkColor: Colors.white, // Warna centang
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog tanpa perubahan
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updatePreferences(userId, _selectedPreferences); // Simpan preferensi yang dipilih
                Navigator.of(context).pop(); // Tutup dialog setelah menyimpan
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePreferences(int userId, List<String> newPreferences) async {
    // Hanya mengirim preferensi yang unik dan mengubah menjadi format string
    final uniquePreferences = newPreferences.toSet().toList();  // Menghapus duplikasi
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/profile/edit_preferences/$userId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'preferences': uniquePreferences}),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureProfile = fetchUserProfile(widget.username);
      });
    } else {
      print('Failed to update preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<AboutMeModels>(
          future: futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            } else {
              final profile = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Profil
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade500,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nama dan Username
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.username,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditNameDialog(context, profile.userId, profile.username),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bio Pengguna
                    ListTile(
                      title: const Text('Bio'),
                      subtitle: Text(profile.bio ?? 'No bio available'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditBioDialog(context, profile.userId, profile.bio ?? ''),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preferensi Makanan
                    ListTile(
                      title: const Text('Food Preferences'),
                      subtitle: Text(profile.foodPreferences.isEmpty ? 'No preferences set' : profile.foodPreferences.join(', ')),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditPreferencesDialog(context, profile.userId, profile.foodPreferences),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigasi ke halaman forum
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ForumPage(userId: profile.userId)),
                        );
                      },
                      child: const Text('Go to Forum'), // Menambahkan teks atau widget lain di dalam tombol
                    )


                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
