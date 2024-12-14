import 'package:flutter/material.dart';
import 'package:panganon_mobile/widgets/leftdrawer.dart';

class ForumPage extends StatelessWidget {
  final String username;
  final String profileImageUrl;

  const ForumPage({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      drawer: LeftDrawer(
        username: username,
        profileImageUrl: profileImageUrl,
      ),
      body: const Center(
        child: Text('Forum Page'),
      ),
    );
  }
}