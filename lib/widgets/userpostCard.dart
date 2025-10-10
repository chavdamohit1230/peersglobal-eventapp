import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peersglobleeventapp/modelClass/user_PostModel.dart';

class Userpostcard extends StatefulWidget {
  final UserPostModel post;
  final String currentUserId;

  const Userpostcard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<Userpostcard> createState() => _UserpostcardState();
}

class _UserpostcardState extends State<Userpostcard> {
  VideoPlayerController? _videoController;
  int _currentImageIndex = 0;
  final Map<String, double> _imageAspectRatios = {};
  final Set<String> _loadingAspectRatio = {};

  @override
  void initState() {
    super.initState();
    if (widget.post.videos.isNotEmpty) {
      _initVideo(widget.post.videos.first);
    }
    for (final url in widget.post.imageUrls) {
      _fetchImageAspectRatio(url);
    }
  }

  void _initVideo(String url) {
    _videoController = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.file(File(url));
    _videoController!.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return "";
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCommentsDialog(List<dynamic> comments) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Comments"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
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
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Add a comment",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("userposts")
                    .doc(widget.post.id)
                    .update({'comments': FieldValue.arrayUnion([comment])});
              }
              Navigator.pop(context);
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  void _fetchImageAspectRatio(String url) {
    if (_imageAspectRatios.containsKey(url) || _loadingAspectRatio.contains(url)) return;
    _loadingAspectRatio.add(url);
    final ImageProvider provider = url.startsWith('http')
        ? NetworkImage(url)
        : FileImage(File(url)) as ImageProvider;
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      final double aspect = info.image.width / info.image.height;
      _imageAspectRatios[url] = aspect.toDouble();
      _loadingAspectRatio.remove(url);
      if (mounted) setState(() {});
      stream.removeListener(listener);
    }, onError: (dynamic _, __) {
      _imageAspectRatios[url] = 1.0;
      _loadingAspectRatio.remove(url);
      if (mounted) setState(() {});
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }

  void _openFullScreenGallery(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            custom_carousel.CarouselSlider(
              items: widget.post.imageUrls.map((url) {
                final provider = url.startsWith('http')
                    ? NetworkImage(url)
                    : FileImage(File(url)) as ImageProvider<Object>;
                return Center(
                  child: InteractiveViewer(
                    child: Image(
                      image: provider,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              }).toList(),
              options: custom_carousel.CarouselOptions(
                initialPage: initialIndex,
                enableInfiniteScroll: false,
                viewportFraction: 1.0,
                height: MediaQuery.of(context).size.height,
                onPageChanged: (idx, _) => setState(() => _currentImageIndex = idx),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 46,
              right: 24,
              child: Text(
                "${_currentImageIndex + 1}/${widget.post.imageUrls.length}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.01),
      child: Container(
        color: const Color(0xFFF0F4FD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: sw * 0.06,
                  backgroundImage: (widget.post.profileImageUrl.startsWith('http')
                      ? NetworkImage(widget.post.profileImageUrl)
                      : FileImage(File(widget.post.profileImageUrl)))
                  as ImageProvider<Object>,
                ),
                title: Text(
                  widget.post.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: sw * 0.045),
                ),
                subtitle: Text(
                  _getTimeAgo(widget.post.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: sw * 0.034),
                ),
                trailing: const Icon(Icons.more_horiz),
              ),
            ),

            // Caption
            if (widget.post.caption.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.006),
                child: Text(
                  widget.post.caption,
                  style: TextStyle(fontSize: sw * 0.04, color: Colors.black),
                ),
              ),

            // Media (images or videos)
            if (widget.post.imageUrls.isNotEmpty)
              _buildLinkedInImageGrid(widget.post.imageUrls, sw, sh)
            else if (widget.post.videos.isNotEmpty)
              _buildVideoPlayer(sh),

            // Like & Comment Section
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("userposts")
                  .doc(widget.post.id)
                  .snapshots(),
              builder: (context, snapshot) {
                List<dynamic> likes = [];
                List<dynamic> comments = [];
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  likes = (data['likes'] ?? []) as List<dynamic>;
                  comments = (data['comments'] ?? []) as List<dynamic>;
                }
                final isLiked = likes.contains(widget.currentUserId);

                return Padding(
                  padding: EdgeInsets.only(top: sh * 0.006),
                  child: Row(
                    children: [
                      _buildActionButtons(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.black,
                        text: "Like  ${likes.length}",
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
                      ),
                      _buildActionButtons(
                        icon: Icons.comment_outlined,
                        color: Colors.black,
                        text: "Comment  ${comments.length}",
                        onTap: () => _showCommentsDialog(comments),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 4),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  // LinkedIn Grid Layout (Adaptive)
  Widget _buildLinkedInImageGrid(List<String> images, double sw, double sh) {
    final count = images.length;
    if (count == 1) {
      final url = images.first;
      final aspect = _imageAspectRatios[url];
      final maxH = sh * 0.75;
      final height = (aspect != null ? (sw / aspect) : sh * 0.45)
          .clamp(100, maxH)
          .toDouble();

      return GestureDetector(
        onTap: () => _openFullScreenGallery(0),
        child: Container(
          width: double.infinity,
          height: height,
          color: Colors.grey.shade200,
          child: _imageWidget(url, BoxFit.cover), // <-- CHANGED
        ),
      );
    }

    // 2 or more
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count > 4 ? 4 : count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final url = images[index];
        final showOverlay = index == 3 && count > 4;
        return GestureDetector(
          onTap: () => _openFullScreenGallery(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _imageWidget(url, BoxFit.cover),
              if (showOverlay)
                Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: Text(
                    "+${count - 4}",
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _imageWidget(String url, BoxFit fit) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, _, __) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    } else {
      return Image.file(
        File(url),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, _, __) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    }
  }

  Widget _buildVideoPlayer(double sh) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return SizedBox(height: sh * 0.4, child: const Center(child: CircularProgressIndicator()));
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