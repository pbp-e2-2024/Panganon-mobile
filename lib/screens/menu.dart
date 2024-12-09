import 'package:flutter/material.dart';
import 'package:panganon_mobile/widgets/leftdrawer.dart';


class MenuPage extends StatelessWidget {
  final String username;
  final String profileImageUrl;

  const MenuPage({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      // Menambahkan Drawer dengan argumen wajib
      drawer: LeftDrawer(
        username: username,
        profileImageUrl: profileImageUrl,
      ),
      body: const Center(
        child: Text('Menu Page'),
      ),
    );
  }
}
