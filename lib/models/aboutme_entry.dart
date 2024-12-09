// To parse this JSON data, do
//
//     final aboutMeModels = aboutMeModelsFromJson(jsonString);

import 'dart:convert';

List<AboutMeModels> aboutMeModelsFromJson(String str) => List<AboutMeModels>.from(json.decode(str).map((x) => AboutMeModels.fromJson(x)));

String aboutMeModelsToJson(List<AboutMeModels> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AboutMeModels {
    int userId;
    String username;
    String? bio;
    List<String> foodPreferences;
    List<ForumPost> forumPosts;

    AboutMeModels({
        required this.userId,
        required this.username,
        required this.bio,
        required this.foodPreferences,
        required this.forumPosts,
    });

    factory AboutMeModels.fromJson(Map<String, dynamic> json) => AboutMeModels(
        userId: json["userID"],
        username: json["username"],
        bio: json["bio"],
        foodPreferences: List<String>.from(json["food_preferences"].map((x) => x)),
        forumPosts: List<ForumPost>.from(json["forum_posts"].map((x) => ForumPost.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "userID": userId,
        "username": username,
        "bio": bio,
        "food_preferences": List<dynamic>.from(foodPreferences.map((x) => x)),
        "forum_posts": List<dynamic>.from(forumPosts.map((x) => x.toJson())),
    };
}

class ForumPost {
    int postId;
    String threadTitle;
    String content;
    DateTime createdAt;
    DateTime updatedAt;

    ForumPost({
        required this.postId,
        required this.threadTitle,
        required this.content,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        postId: json["post_id"],
        threadTitle: json["thread_title"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "post_id": postId,
        "thread_title": threadTitle,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
