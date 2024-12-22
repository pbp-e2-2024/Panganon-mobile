import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:panganon_mobile/models/aboutme_entry.dart';
import 'package:panganon_mobile/screens/about_me/forumpage.dart';
import 'package:panganon_mobile/widgets/leftdrawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Untuk CookieRequest
import 'package:provider/provider.dart';

class AboutMePage extends StatefulWidget {
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
    futureProfile = fetchUserProfile(context);
  }

  Future<AboutMeModels> fetchUserProfile(BuildContext context) async {
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
      
      // Langsung convert dan return response
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
  final request = context.read<CookieRequest>();
  
  final response = await request.post(
    'http://127.0.0.1:8000/profile/edit_name/$userId/',
    jsonEncode({
      'name': newName
    })
  );

  if (response != null) {
    setState(() {
      // Refresh profile setelah update
      futureProfile = fetchUserProfile(context);
    });
  } else {
    print('Failed to update name');
  }
}

Future<void> _updateBio(int userId, String newBio) async {
  final request = context.read<CookieRequest>();
  
  final response = await request.post(
    'http://127.0.0.1:8000/profile/edit_bio/$userId/',
    jsonEncode({
      'bio': newBio
    })
  );

  if (response != null) {
    setState(() {
      // Refresh profile setelah update
      futureProfile = fetchUserProfile(context);
    });
  } else {
    print('Failed to update bio');
  }
}

Future<List<String>> fetchUserPreferences(int userId) async {
  final request = context.read<CookieRequest>();
  
  final response = await request.get(
    'http://127.0.0.1:8000/profile/get_preferences/$userId/'
  );

  if (response != null) {
    return List<String>.from(response['preferences'].split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
  } else {
    throw Exception('Failed to load preferences');
  }
}

Future<void> _updatePreferences(int userId, List<String> newPreferences) async {
  final request = context.read<CookieRequest>();
  
  // Hanya mengirim preferensi yang unik
  final uniquePreferences = newPreferences.toSet().toList();
  
  final response = await request.post(
    'http://127.0.0.1:8000/profile/edit_preferences/$userId/',
    jsonEncode({
      'preferences': uniquePreferences
    })
  );

  if (response != null) {
    setState(() {
      futureProfile = fetchUserProfile(context);
    });
  } else {
    print('Failed to update preferences');
  }
}

  // Future<void> _updateName(int userId, String newName) async {
  //   final response = await http.post(
  //     Uri.parse('http://127.0.0.1:8000/profile/edit_name/$userId/'),
  //     body: json.encode({'name': newName}),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       // Refresh profile setelah update
  //       futureProfile = fetchUserProfile(context);
  //     });
  //   } else {
  //     print('Failed to update name');
  //   }
  // }

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

  // Future<void> _updateBio(int userId, String newBio) async {
  //   final response = await http.post(
  //     Uri.parse('http://127.0.0.1:8000/profile/edit_bio/$userId/'),
  //     body: json.encode({'bio': newBio}),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       // Refresh profile setelah update
  //       futureProfile = fetchUserProfile(context);
  //     });
  //   } else {
  //     print('Failed to update bio');
  //   }
  // }

 
  // Future<List<String>> fetchUserPreferences(int userId) async {
  //   final response = await http.get(
  //     Uri.parse('http://127.0.0.1:8000/profile/get_preferences/$userId/'),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return List<String>.from(data['preferences']);
  //   } else {
  //     throw Exception('Failed to load preferences');
  //   }
  // }

  void _showEditPreferencesDialog(BuildContext context, int userId, List<String> currentPreferences) {
  // Salin preferensi yang sudah ada
  List<String> _selectedPreferences = List.from(currentPreferences);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
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
                    setDialogState(() {
                      if (selected != null) {
                        if (selected) {
                          _selectedPreferences.add(preference);
                        } else {
                          _selectedPreferences.remove(preference);
                        }
                      }
                    });
                  },
                  activeColor: Colors.green, // Warna kotak centang
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
    },
  );
}

  // Future<void> _updatePreferences(int userId, List<String> newPreferences) async {
  //   // Hanya mengirim preferensi yang unik dan mengubah menjadi format string
  //   final uniquePreferences = newPreferences.toSet().toList();  // Menghapus duplikasi
  //   final response = await http.post(
  //     Uri.parse('http://127.0.0.1:8000/profile/edit_preferences/$userId/'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'preferences': uniquePreferences}),
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       futureProfile = fetchUserProfile(context);
  //     });
  //   } else {
  //     print('Failed to update preferences');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('About Me'),
  backgroundColor: Colors.black,
  iconTheme: const IconThemeData(
    color: Colors.white, // Mengatur ikon AppBar menjadi putih
  ),
  titleTextStyle: const TextStyle(
    color: Colors.white, // Mengatur warna teks judul AppBar
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
    drawer: const LeftDrawer(),
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
                    Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                              'http://127.0.0.1:8000/auth/image/${profile.userID}/',
                            ),
                            backgroundColor: Colors.grey.shade500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        '@${profile.username}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nama dan Username
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            profile.name.isNotEmpty ? profile.name : profile.username,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditNameDialog(context, profile.userID, profile.name),
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
                        onPressed: () => _showEditBioDialog(context, profile.userID, profile.bio ?? ''),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preferensi Makanan
                    ListTile(
                            title: const Text('Food Preferences'),
                            subtitle: Text(
                              profile.foodPreference.isEmpty 
                                ? 'No preferences set' 
                                : profile.foodPreference,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                String rawPreferences = profile.foodPreference.trim(); 
                                List<String> preferencesList = rawPreferences
                                    .split(',') 
                                    .map((preference) => preference.trim()) 
                                    .where((preference) => preference.isNotEmpty)
                                    .toList();
                                _showEditPreferencesDialog(context, profile.userID, preferencesList);
                              },
                            ),
                          ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigasi ke halaman forum
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForumPage(
                              forumPosts: profile.forumPosts, // Now List<ForumPost>
                              username: profile.username,
                            ),
                        ),
                        );
                      },
                      child: const Text('Go to Forum'), 
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


