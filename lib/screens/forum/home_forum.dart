import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganon_mobile/models/forum_entry.dart';
import 'package:panganon_mobile/screens/forum/thread_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumPage extends StatefulWidget {
  final String username;
  final String profileImageUrl;

  const ForumPage({
    Key? key,
    required this.username,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late Future<List<Thread>> threadsFuture;
  int? loggedInUserId;
  bool _isCreating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    threadsFuture = fetchThreads();
    _fetchLoggedInUserId();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchLoggedInUserId() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://127.0.0.1:8000/forum/view/');
      setState(() {
        loggedInUserId = response['user_id'];
      });
    } catch (e) {}
  }

  Future<List<Thread>> fetchThreads() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/forum/'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['threads'];
      return data.map((json) => Thread.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load threads');
    }
  }

  Future<void> _createThread(String title) async {
    final request = context.read<CookieRequest>();
    try {
      setState(() {
        _isCreating = true;
      });
      final response = await request.post(
        'http://127.0.0.1:8000/forum/create_thread_flutter/',
        {'title': title},
      );
      if (response['statusCode'] == 201) {
        setState(() {
          threadsFuture = fetchThreads();
        });
        _showSnackBar('Thread created successfully');
      } else {
        _showSnackBar(response['error'] ?? 'Failed to create thread');
      }
    } catch (e) {
      _showSnackBar('An error occurred while creating the thread');
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  Future<void> _deleteThread(int threadId) async {
    final request = context.read<CookieRequest>();
    try {
      setState(() {
        _isDeleting = true;
      });
      final response = await request.post(
        'http://127.0.0.1:8000/forum/delete_thread_flutter/',
        {'thread_id': threadId.toString()},
      );
      if (response['statusCode'] == 201) {
        setState(() {
          threadsFuture = fetchThreads();
        });
        _showSnackBar('Thread deleted successfully');
      } else {
        _showSnackBar(response['error'] ?? 'Failed to delete thread');
      }
    } catch (e) {
      _showSnackBar('An error occurred while deleting the thread');
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _showAddThreadDialog() {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Thread'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Enter thread title'),
            maxLength: 100,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isCreating
                  ? null
                  : () async {
                      if (titleController.text.trim().isNotEmpty) {
                        Navigator.of(context).pop();
                        await _createThread(titleController.text.trim());
                      } else {
                        _showSnackBar('Please enter a title');
                      }
                    },
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Threads'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddThreadDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Thread',
      ),
      body: FutureBuilder<List<Thread>>(
        future: threadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No threads available'));
          } else {
            final threads = snapshot.data!;
            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: thread.createdBy.profilePicture != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(thread.createdBy.profilePicture!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(thread.title),
                    subtitle: Text('Started by ${thread.createdBy.username}'),
                    trailing: loggedInUserId == thread.createdBy.id
                        ? _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Thread'),
                                      content: const Text('Are you sure you want to delete this thread?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteThread(thread.id);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreadDetailPage(thread: thread),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}