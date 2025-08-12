import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/user_PostModel.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;

class Userpostcard extends StatefulWidget {
  final userPostModel post;

  const Userpostcard({super.key, required this.post});

  @override
  State<Userpostcard> createState() => _PostCardState();
}

class _PostCardState extends State<Userpostcard> {
  VideoPlayerController? _videoController;
  int _currentImageIndex = 0; // For image counter

  @override
  void initState() {
    super.initState();
    if (widget.post.videoUrl != null) {
      if (widget.post.videoUrl!.startsWith("http")) {
        _videoController = VideoPlayerController.network(widget.post.videoUrl!)
          ..initialize().then((_) => setState(() {}));
      } else {
        _videoController = VideoPlayerController.file(File(widget.post.videoUrl!))
          ..initialize().then((_) => setState(() {}));
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
          /// Header
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
              widget.post.timeago,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            trailing: Icon(Icons.more_vert, size: screenWidth * 0.06),
          ),

          /// Media
          if (widget.post.ImageUrls != null && widget.post.ImageUrls!.isNotEmpty)
            _buildImageCarousel(widget.post.ImageUrls!, screenHeight, screenWidth)
          else if (widget.post.videoUrl != null)
            _buildVideoPlayer(screenHeight),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.008,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: screenWidth * 0.07),
                      const SizedBox(width: 4),
                      const Text("Like"),
                      const SizedBox(width: 4),
                      Text("${widget.post.likes}"),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: screenWidth * 0.065),
                      const SizedBox(width: 4),
                      const Text("Comment"),
                      const SizedBox(width: 4),
                      Text("${widget.post.comments}"),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: screenWidth * 0.065),
                      const SizedBox(width: 4),
                      const Text("Share"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
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

          /// Comments
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenHeight * 0.005,
            ),
            child: Text(
              "View all ${widget.post.comments} comments",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: screenWidth * 0.038,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images, double screenHeight, double screenWidth) {
    return Stack(
      children: [
        custom_carousel.CarouselSlider(
          options: custom_carousel.CarouselOptions(
            height: screenHeight * 0.5,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: images.map((url) {
            return url.startsWith("http")
                ? Image.network(url, fit: BoxFit.cover, width: double.infinity)
                : Image.file(File(url), fit: BoxFit.cover, width: double.infinity);
          }).toList(),
        ),

        /// Top-Right Counter
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
