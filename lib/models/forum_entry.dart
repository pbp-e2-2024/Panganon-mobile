class Thread {
  final int id;
  final String title;
  final String createdAt; // New field for thread creation date
  final User createdBy;
  final List<Post> posts; // Include posts if needed

  Thread({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.createdBy,
    this.posts = const [],
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      title: json['title'],
      createdAt: json['created_at'], // Parse the created_at field
      createdBy: User.fromJson(json['created_by']),
      posts: json['posts'] != null
          ? (json['posts'] as List).map((post) => Post.fromJson(post)).toList()
          : [],
    );
  }
}

class User {
  final int id;
  final String username;
  final String? profilePicture;

  User({required this.id, required this.username, this.profilePicture});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      profilePicture: json['profile_picture'],
    );
  }
}

class Post {
  final int id;
  final String content;
  final String createdAt; // New field for post creation date
  final User createdBy;
  final List<Comment> comments; // Include comments if needed

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'], // Parse the created_at field
      createdBy: User.fromJson(json['created_by']),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => Comment.fromJson(comment))
              .toList()
          : [],
    );
  }
}

class Comment {
  final int id;
  final String content;
  final String createdAt; // New field for comment creation date
  final User createdBy;
  final int? parent; // Parent comment ID (nullable)

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    this.parent,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'], // Parse the created_at field
      createdBy: User.fromJson(json['created_by']),
      parent: json['parent'],
    );
  }
}