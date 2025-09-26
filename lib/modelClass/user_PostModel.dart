import 'package:cloud_firestore/cloud_firestore.dart';

class UserPostModel {
  final String id;
  final String username;
  final String profileImageUrl;
  final String caption;
  final List<String> imageUrls;
  final List<String> videos;
  final int likes;
  final int comments;
  final DateTime? timestamp;

  UserPostModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.caption,
    required this.imageUrls,
    required this.videos,
    required this.likes,
    required this.comments,
    this.timestamp,
  });

  factory UserPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Images
    List<String> images = [];
    if (data['images'] != null) {
      if (data['images'] is String) {
        images = [data['images']];
      } else if (data['images'] is List) {
        images = (data['images'] as List)
            .map((e) => e?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // Videos
    List<String> videos = [];
    if (data['videos'] != null) {
      if (data['videos'] is String) {
        videos = [data['videos']];
      } else if (data['videos'] is List) {
        videos = (data['videos'] as List)
            .map((e) => e?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // Likes (always int)
    int likesCount = 0;
    final likesValue = data['likes'];
    if (likesValue != null) {
      if (likesValue is int) {
        likesCount = likesValue;
      } else if (likesValue is double) {
        likesCount = likesValue.toInt();
      }
    }

    // Comments count (length of list)
    int commentsCount = 0;
    final commentsValue = data['comments'];
    if (commentsValue != null && commentsValue is List) {
      commentsCount = commentsValue.length;
    }

    // Timestamp
    DateTime? ts;
    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
      ts = (data['timestamp'] as Timestamp).toDate();
    }

    return UserPostModel(
      id: doc.id,
      username: data['userName']?.toString() ?? "Unknown",
      profileImageUrl: data['profileImageUrl']?.toString() ?? "",
      caption: data['content']?.toString() ?? "",
      imageUrls: images,
      videos: videos,
      likes: likesCount,
      comments: commentsCount,
      timestamp: ts,
    );
  }
}
