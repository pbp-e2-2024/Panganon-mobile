
class AboutMeModels {
  final int userID;
  final String name;
  final String username;
  final String? bio;
  final String foodPreference;
  final List<ForumPost> forumPosts;


  AboutMeModels({
    required this.userID,
    required this.name,
    required this.username,
    this.bio,
    required this.foodPreference,
    required this.forumPosts,
  });

  factory AboutMeModels.fromJson(Map<String, dynamic> json) {
    var postsJson = json['forum_posts'] as List<dynamic>;
    List<ForumPost> forumPostsList = postsJson
        .map((postJson) => ForumPost.fromJson(postJson as Map<String, dynamic>))
        .toList();
    try {
      return AboutMeModels(
        userID: json['userID'] ?? 0, // Default value jika null
        name: json['name'] ?? '',
        username: json['username'] ?? '', // Default value jika null
        bio: json['bio'],
        foodPreference: json['food_preference'] ?? '',
        forumPosts: forumPostsList,
      );
    } catch (e) {
      print('Error parsing JSON: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name' : name,
      'username': username,
      'bio': bio,
      'food_preference': foodPreference,
      'forum_posts': forumPosts,
    };
  }
}

class ForumPost {
  final int postId;
  final String threadTitle;
  final String content;
  final DateTime createdAt;

  ForumPost({
    required this.postId,
    required this.threadTitle,
    required this.content,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      postId: json['post_id'],
      threadTitle: json['thread_title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Optionally, add a toJson method if needed
  Map<String, dynamic> toJson() => {
        'post_id': postId,
        'thread_title': threadTitle,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}

