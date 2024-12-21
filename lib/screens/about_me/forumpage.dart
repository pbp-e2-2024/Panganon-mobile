import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  final int userId; // Menerima userId sebagai parameter

  ForumPage({required this.userId});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<ForumPost> userForumPosts = [];
  String username = ""; // Menyimpan username dari user
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Mengambil data user berdasarkan userId dan forum posts
  Future<void> _fetchUserData() async {
    final response = await http.get(Uri.parse('https://brian-altan-panganon.pbp.cs.ui.ac.id/profile/show_json_all/'));

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      
      // Memfilter data pengguna berdasarkan userId yang diterima
      final user = jsonData.firstWhere((user) => user['userID'] == widget.userId, orElse: () => null);

      if (user != null) {
        setState(() {
          username = user['username']; // Ambil username
          userForumPosts = (user['forum_posts'] as List)
              .map((post) => ForumPost.fromJson(post))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          userForumPosts = [];
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Forum Posts by @$username"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Menampilkan loading jika belum ada data
          : userForumPosts.isEmpty
              ? Center(child: Text("No forum posts available."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: userForumPosts.length,
                        itemBuilder: (context, index) {
                          var post = userForumPosts[index];
                          return ListTile(
                            title: Text(post.threadTitle),
                            subtitle: Text(post.content),
                            onTap: () {
                              // Menambahkan navigasi ke halaman detail post jika diperlukan
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Page 1 of 1"),
                    ),
                  ],
                ),
    );
  }
}

class ForumPost {
  final int postId;
  final String threadTitle;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.postId,
    required this.threadTitle,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      postId: json["post_id"],
      threadTitle: json["thread_title"],
      content: json["content"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}
