import 'package:flutter/material.dart';
import 'package:panganon_mobile/models/aboutme_entry.dart';


class ForumPage extends StatelessWidget {
  final List<ForumPost> forumPosts;
  final String username;

  const ForumPage({
    required this.forumPosts,
    required this.username,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Forum Posts by $username"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: forumPosts.isEmpty
          ? const Center(
              child: Text(
                "No forum posts available.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: forumPosts.length,
                    itemBuilder: (context, index) {
                      final post = forumPosts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.threadTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Posted on ${_formatDate(post.createdAt)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const Divider(height: 32),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    // Format tanggal sesuai kebutuhan Anda
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }
}