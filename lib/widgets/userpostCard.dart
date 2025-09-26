import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/user_PostModel.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:cloud_firestore/cloud_firestore.dart';

class Userpostcard extends StatefulWidget {
  final UserPostModel post;
  final String currentUserId; // Current logged-in user ID

  const Userpostcard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<Userpostcard> createState() => _PostCardState();
}

class _PostCardState extends State<Userpostcard> {
  VideoPlayerController? _videoController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.videos.isNotEmpty) {
      _initVideo(widget.post.videos.first);
    }
  }

  void _initVideo(String url) {
    _videoController = url.startsWith("http")
        ? VideoPlayerController.network(url)
        : VideoPlayerController.file(File(url));
    _videoController!.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String getTimeAgo(DateTime? date) {
    if (date == null) return "";
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${date.day}/${date.month}/${date.year}";
  }

  // Show comments modal
  void _showCommentsDialog(List<dynamic> comments) {
    TextEditingController _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Comments"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(comments[index].toString()),
                    );
                  },
                ),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(hintText: "Add a comment"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final comment = _commentController.text.trim();
              if (comment.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("userposts")
                    .doc(widget.post.id)
                    .update({
                  'comments': FieldValue.arrayUnion([comment])
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      color: const Color(0xFFF0F4FD),
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundImage: widget.post.profileImageUrl.startsWith("http")
                  ? NetworkImage(widget.post.profileImageUrl)
                  : FileImage(File(widget.post.profileImageUrl)) as ImageProvider,
            ),
            title: Text(
              widget.post.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            subtitle: Text(
              getTimeAgo(widget.post.timestamp),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            trailing: Icon(Icons.more_vert, size: screenWidth * 0.06),
          ),

          // Media
          if (widget.post.imageUrls.isNotEmpty)
            _buildImageCarousel(widget.post.imageUrls, screenHeight, screenWidth)
          else if (widget.post.videos.isNotEmpty)
            _buildVideoPlayer(screenHeight),

          // Realtime Likes & Comments
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("userposts")
                .doc(widget.post.id)
                .snapshots(),
            builder: (context, snapshot) {
              List<dynamic> likesList = [];
              List<dynamic> commentsList = [];

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final l = data['likes'];
                final c = data['comments'];
                if (l != null && l is List) likesList = l;
                if (c != null && c is List) commentsList = c;
              }

              final bool isLiked = likesList.contains(widget.currentUserId);

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.008,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final docRef = FirebaseFirestore.instance
                              .collection("userposts")
                              .doc(widget.post.id);
                          if (isLiked) {
                            await docRef.update({
                              'likes': FieldValue.arrayRemove([widget.currentUserId])
                            });
                          } else {
                            await docRef.update({
                              'likes': FieldValue.arrayUnion([widget.currentUserId])
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.black,
                              size: screenWidth * 0.07,
                            ),
                            const SizedBox(width: 4),
                            const Text("Like"),
                            const SizedBox(width: 4),
                            Text("${likesList.length}"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCommentsDialog(commentsList),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: screenWidth * 0.065),
                            const SizedBox(width: 4),
                            const Text("Comment"),
                            const SizedBox(width: 4),
                            Text("${commentsList.length}"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Caption
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.035,
                vertical: screenHeight * 0.005,
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.040,
                  ),
                  children: [
                    TextSpan(
                      text: widget.post.username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: " ${widget.post.caption}"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Image Carousel
  Widget _buildImageCarousel(
      List<String> images, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        custom_carousel.CarouselSlider(
          options: custom_carousel.CarouselOptions(
            height: screenHeight * 0.45,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: images.map((url) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: url.startsWith("http")
                  ? Image.network(url, fit: BoxFit.cover, width: double.infinity)
                  : Image.file(File(url), fit: BoxFit.cover, width: double.infinity),
            );
          }).toList(),
        ),
        if (images.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_currentImageIndex + 1}/${images.length}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Video Player
  Widget _buildVideoPlayer(double screenHeight) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return SizedBox(
        height: screenHeight * 0.4,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _videoController!.value.isPlaying
              ? _videoController!.pause()
              : _videoController!.play();
        });
      },
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }
}
