import 'package:flutter/material.dart';

class userPostModel{

  final String username;
  final String profileImageUrl;
  final String? caption;
  final List<String>? ImageUrls;
  final String? videoUrl;
  final int likes;
  final int comments;
  final String timeago;

  userPostModel({

  required this.username,
  required this.profileImageUrl,
    this.caption,
    this.ImageUrls,
    this.videoUrl,
    required this.likes,
    required this.comments,
    required this.timeago

});
  
}