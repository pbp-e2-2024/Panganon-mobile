import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:panganon_mobile/models/forum_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ThreadDetailPage extends StatefulWidget {
  final Thread thread;
  const ThreadDetailPage({Key? key, required this.thread}) : super(key: key);

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  late Future<Map<String, dynamic>> _threadDetailFuture;
  int? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId();
    _threadDetailFuture = fetchThreadDetail();
  }

  Future<void> _fetchLoggedInUserId() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/forum/view/');
    setState(() {
      loggedInUserId = response['user_id'];
    });
  }

  void _refreshThreadDetail() {
    setState(() {
      _threadDetailFuture = fetchThreadDetail();
    });
  }

  Future<Map<String, dynamic>> fetchThreadDetail() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/forum/thread/${widget.thread.id}/'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load thread details');
    }
  }

  Future<void> _addPost(String content) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/thread/${widget.thread.id}/add_post_flutter/',
        {'content': content},
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post added successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add post')),
        );
      }
    } catch (e) {}
  }

  Future<void> _addComment(int postId, String content, {int? parentId}) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/post/comment_flutter/',
        {
          'post_id': postId.toString(),
          'content': content,
          if (parentId != null) 'parent_id': parentId.toString(),
        },
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    } catch (e) {}
  }

  void _showAddPostDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Post'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your post content here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String content = textController.text.trim();
                if (content.isNotEmpty) {
                  _addPost(content);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post content cannot be empty')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add Post'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(int postId, {int? parentId}) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your comment here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String content = textController.text.trim();
                if (content.isNotEmpty) {
                  _addComment(postId, content, parentId: parentId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment content cannot be empty')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add Comment'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPost(int postId, String newContent) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/post_edit_flutter/',
        {
          'post_id': postId.toString(),
          'content': newContent,
        },
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update post')),
        );
      }
    } catch (e) {}
  }

  Future<void> _editComment(int commentId, String newContent) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/comment_edit_flutter/',
        {
          'comment_id': commentId.toString(),
          'content': newContent,
        },
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment updated successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update comment')),
        );
      }
    } catch (e) {}
  }

  void _showDeletePostConfirmation(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePost(postId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentConfirmation(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteComment(commentId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(int postId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/delete_post_flutter/',
        {'post_id': postId.toString()},
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    } catch (e) {}
  }

  Future<void> _deleteComment(int commentId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/delete_comment_flutter/',
        {'comment_id': commentId.toString()},
      );

      if (response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully!')),
        );
        _refreshThreadDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    } catch (e) {}
  }

  void _showEditPostDialog(BuildContext context, String currentContent, int postId) {
    final TextEditingController textController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your updated post here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newContent = textController.text.trim();
                if (newContent.isNotEmpty) {
                  _editPost(postId, newContent);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post content cannot be empty')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommentDialog(BuildContext context, String currentContent, int commentId) {
    final TextEditingController textController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your updated comment here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newContent = textController.text.trim();
                if (newContent.isNotEmpty) {
                  _editComment(commentId, newContent);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment content cannot be empty')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> buildCommentTree(List<Map<String, dynamic>> comments) {
    final List<Map<String, dynamic>> commentCopies =
        comments.map((comment) => Map<String, dynamic>.from(comment)).toList();

    final Map<int, Map<String, dynamic>> commentMap = {
      for (var comment in commentCopies) comment['id']: comment
    };

    final List<Map<String, dynamic>> rootComments = [];

    for (var comment in commentCopies) {
      if (comment['parent'] == null) {
        rootComments.add(comment);
      } else {
        final parent = commentMap[comment['parent']];
        if (parent != null) {
          parent['children'] = parent['children'] ?? [];
          parent['children'].add(comment);
        }
      }
    }

    return rootComments;
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toUtc().add(const Duration(hours: 7));
      return DateFormat('MMM. d, yyyy, h:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget buildCommentWidget(Map<String, dynamic> comment, {double indent = 16.0, required int postId}) {
    final isOwner = loggedInUserId == comment['created_by']['id'];

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              comment['created_by']['profile_picture'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(comment['created_by']['profile_picture']),
                      radius: 16,
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.person, size: 16),
                      radius: 16,
                    ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment['created_by']['username'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF4500),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        formatDate(comment['created_at']),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '|__',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  comment['content'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _showAddCommentDialog(postId, parentId: comment['id']);
                },
                child: const Text('Reply'),
              ),
              if (isOwner)
                TextButton(
                  onPressed: () {
                    _showEditCommentDialog(context, comment['content'], comment['id']);
                  },
                  child: const Text('Edit Comment'),
                ),
              if (isOwner)
                TextButton(
                  onPressed: () {
                    _showDeleteCommentConfirmation(comment['id']);
                  },
                  child: const Text('Delete Comment'),
                ),
            ],
          ),
          if (comment['children'] != null)
            ...comment['children']
                .map<Widget>(
                  (child) => buildCommentWidget(child, indent: indent + 32.0, postId: postId),
                )
                .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thread.title),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddPostDialog,
            child: const Text('Add Post'),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _threadDetailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No thread data available'));
                }

                final threadData = snapshot.data!['thread'];
                final posts = threadData['posts'] as List;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final isOwner = loggedInUserId == post['created_by']['id'];
                    final comments = post['comments'] as List;
                    final commentTree = buildCommentTree(comments.cast<Map<String, dynamic>>());

                    return Card(
                      color: Colors.grey[200],
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: post['created_by']['profile_picture'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(post['created_by']['profile_picture']),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        post['created_by']['username'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFFF4500),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        formatDate(post['created_at']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                post['content'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _showAddCommentDialog(post['id']);
                                  },
                                  child: const Text('Reply'),
                                ),
                                if (isOwner)
                                  TextButton(
                                    onPressed: () {
                                      _showEditPostDialog(context, post['content'], post['id']);
                                    },
                                    child: const Text('Edit Post'),
                                  ),
                                if (isOwner)
                                  TextButton(
                                    onPressed: () {
                                      _showDeletePostConfirmation(post['id']);
                                    },
                                    child: const Text('Delete Post'),
                                  ),
                              ],
                            ),
                          ),
                          if (commentTree.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                              child: Text(
                                'Comments:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: commentTree
                                    .map((comment) => buildCommentWidget(comment, postId: post['id']))
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}