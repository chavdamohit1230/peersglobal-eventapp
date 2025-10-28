import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: Assuming UserPostModel supports the new comment structure or is adapted elsewhere.
import 'package:peersglobleeventapp/modelClass/user_PostModel.dart';
import 'package:shimmer/shimmer.dart';

// --- Comment Model (Internal to the Widget for clarity) ---
class Comment {
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String text;
  final Timestamp timestamp;

  Comment({
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Unknown User',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
// -----------------------------------------------------------


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

  // Caching current user details to use when posting a new comment
  String _currentUsername = 'You';
  String _currentUserPhotoUrl = '';

  // 🔄 HELPER FUNCTION: Fetch user details from 'userregister'
  Future<Map<String, dynamic>> _fetchCommentUserDetails(String fullUserIdPath) async {
    String userIdToFetch = fullUserIdPath;

    // Path से असली यूजर ID निकालें
    if (userIdToFetch.contains('userregister/')) {
      userIdToFetch = userIdToFetch.split('userregister/').last;
    } else if (userIdToFetch.contains('/users/')) {
      userIdToFetch = userIdToFetch.split('/users/').last;
    }

    // 'userregister' कलेक्शन से फेच करें
    final userDoc = await FirebaseFirestore.instance.collection('userregister').doc(userIdToFetch).get();
    final userData = userDoc.data();

    if (userData != null) {
      return {
        'username': userData['name'] ?? 'Unknown User',
        'userPhotoUrl': userData['photoUrl'] ?? '',
      };
    }
    return {
      'username': 'Unknown User',
      'userPhotoUrl': '',
    };
  }


  @override
  void initState() {
    super.initState();
    if (widget.post.videos.isNotEmpty) {
      _initVideo(widget.post.videos.first);
    }
    for (final url in widget.post.imageUrls) {
      _fetchImageAspectRatio(url);
    }
    _fetchCurrentUserDetails();
  }

  void _fetchCurrentUserDetails() async {
    String userIdToFetch = widget.currentUserId;

    // ➡️ वर्तमान यूजर ID को साफ करना
    if (userIdToFetch.contains('userregister/')) {
      userIdToFetch = userIdToFetch.split('userregister/').last;
    } else if (userIdToFetch.contains('/users/')) {
      userIdToFetch = userIdToFetch.split('/users/').last;
    }

    // ➡️ वर्तमान यूजर की डिटेल्स को 'userregister' से फेच करना
    final userDoc = await FirebaseFirestore.instance.collection('userregister').doc(userIdToFetch).get();
    final userData = userDoc.data();

    if (userData != null && mounted) {
      setState(() {
        // Firestore फ़ील्ड 'name' और 'photoUrl' का उपयोग करें
        _currentUsername = userData['name'] ?? 'You';
        _currentUserPhotoUrl = userData['photoUrl'] ?? '';
      });
      print('Current User Username Fetched: $_currentUsername');
    } else {
      print('Error: Could not find current user document for ID: $userIdToFetch in "userregister" collection.');
    }
  }

  // --- UPDATED: Edit Comment Functionality (Fixes Pop-up Closing) ---
  void _editComment(Comment comment) {
    TextEditingController editController = TextEditingController(text: comment.text);

    showDialog(
      context: context,
      builder: (context) {
        // लोडिंग स्टेट को लोकल रूप से हैंडल करने के लिए StatefulBuilder का उपयोग करें
        return StatefulBuilder(
          builder: (context, setLocalState) {
            bool isLoading = false;

            return AlertDialog(
              title: const Text("Edit Comment"),
              content: TextField(
                controller: editController,
                decoration: const InputDecoration(hintText: "Enter your updated comment"),
                autofocus: true,
                enabled: !isLoading, // लोडिंग के दौरान डिसेबल
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context), // लोडिंग के दौरान डिसेबल
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isLoading ? null : () async {
                    final updatedText = editController.text.trim();
                    if (updatedText.isNotEmpty) {

                      // 🟢 Step 1: लोडिंग शुरू करें
                      setLocalState(() {
                        isLoading = true;
                      });

                      final postRef = FirebaseFirestore.instance.collection("userposts").doc(widget.post.id);
                      bool updateSuccess = false;

                      try {
                        await FirebaseFirestore.instance.runTransaction((transaction) async {
                          final postSnapshot = await transaction.get(postRef);
                          if (!postSnapshot.exists) return;

                          List comments = postSnapshot.data()?['comments'] ?? [];

                          final index = comments.indexWhere((map) =>
                          map['userId'] == comment.userId &&
                              map['timestamp'] == comment.timestamp
                          );

                          if (index != -1) {
                            comments[index]['text'] = updatedText;
                            transaction.update(postRef, {'comments': comments});
                            updateSuccess = true;
                          }
                        });
                      } catch (e) {
                        print("Error updating comment: $e");
                        // यदि कोई एरर हो तो भी लोडिंग खत्म करें
                        setLocalState(() => isLoading = false);
                        return;
                      }

                      // 🟢 Step 2: ट्रांजेक्शन सफल होने पर पॉप-अप बंद करें
                      // pop-up को बंद करने से पहले stream को अपडेट होने का मौका न दें
                      if (updateSuccess) {
                        if(mounted) Navigator.pop(context);
                      } else {
                        // यदि अपडेट सफल न हो, तो भी लोडिंग खत्म करें
                        setLocalState(() => isLoading = false);
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)
                  )
                      : const Text("Update"), // 'Update' या लोडिंग इंडिकेटर दिखाएं
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Delete Comment Functionality ---
  void _deleteComment(Comment comment) async {
    // यह comment object को array से हटाता है
    final Map<String, dynamic> commentToDelete = {
      'userId': comment.userId,
      'username': comment.username,
      'userPhotoUrl': comment.userPhotoUrl,
      'text': comment.text,
      'timestamp': comment.timestamp,
    };

    await FirebaseFirestore.instance
        .collection("userposts")
        .doc(widget.post.id)
        .update({
      'comments': FieldValue.arrayRemove([commentToDelete])
    });
  }

  // --- Comment Menu Widget ---
  Widget _buildCommentMenu(Comment comment) {
    // केवल वही यूजर एडिट/डिलीट कर सकता है जिसने कमेंट पोस्ट किया है।
    final bool canModify = comment.userId.contains(widget.currentUserId);

    if (!canModify) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'edit':
            _editComment(comment);
            break;
          case 'delete':
            _deleteComment(comment);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      splashRadius: 18,
    );
  }

  void _initVideo(String url) {
    _videoController = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.file(File(url));
    _videoController!.initialize().then((_) => setState(() {}));
    _videoController!.setLooping(true); // Added for a better video experience
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

  // --- UPDATED: Show comments as a Bottom Modal Sheet ---
  void _showCommentsBottomSheet(List<dynamic> commentMaps) {
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("userposts").doc(widget.post.id).snapshots(),
          builder: (context, snapshot) {

            List<dynamic> latestCommentMaps = [];
            if (snapshot.hasData && snapshot.data!.exists) {
              latestCommentMaps = (snapshot.data!.data() as Map<String, dynamic>?)?['comments'] ?? [];
            }

            final List<Comment> comments = latestCommentMaps
                .map((map) => Comment.fromMap(map as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8, // Take 80% of the screen height
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title and Close Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Comments",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Comments List
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          return FutureBuilder<Map<String, dynamic>>(
                            // हर कमेंट के लिए Firestore से डिटेल्स फेच करना
                            future: _fetchCommentUserDetails(comment.userId),
                            builder: (context, userSnapshot) {

                              String displayUsername = comment.username;
                              String displayPhotoUrl = comment.userPhotoUrl;

                              if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                                // अगर सफलतापूर्वक फेच हो गया और कमेंट में 'You' या खाली नाम है, तो फेच किए गए डेटा का उपयोग करें
                                if (comment.username == 'You' || comment.username.isEmpty) {
                                  displayUsername = userSnapshot.data!['username'] ?? 'Unknown User';
                                }
                                if (comment.userPhotoUrl.isEmpty) {
                                  displayPhotoUrl = userSnapshot.data!['userPhotoUrl'] ?? '';
                                }
                              } else if (userSnapshot.connectionState == ConnectionState.waiting) {
                                // लोडिंग की स्थिति में Shimmer दिखाएं
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(children: [
                                      const CircleAvatar(radius: 18),
                                      const SizedBox(width: 8),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Container(width: 100, height: 10, color: Colors.white),
                                        const SizedBox(height: 4),
                                        Container(width: 200, height: 10, color: Colors.white),
                                      ])
                                    ]),
                                  ),
                                );
                              }

                              // *** USERNAME AND IMAGE DISPLAY ***
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      // backgroundImage null हैंडलिंग के साथ सेट करना
                                      backgroundImage: displayPhotoUrl.isNotEmpty
                                          ? (displayPhotoUrl.startsWith('http')
                                          ? NetworkImage(displayPhotoUrl)
                                          : FileImage(File(displayPhotoUrl))
                                      ) as ImageProvider<Object>?
                                          : null,

                                      // Fallback child: Show person icon if no photoUrl is available
                                      child: displayPhotoUrl.isEmpty ? const Icon(Icons.person, size: 20) : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  // 👤 फेच किया गया या स्टोर्ड username का उपयोग
                                                  text: '${displayUsername} ',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: comment.text,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getTimeAgo(comment.timestamp.toDate()),
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🟢 Comment Menu (Edit/Delete)
                                    _buildCommentMenu(comment),

                                  ],
                                ),
                              );
                              // *** END USERNAME AND IMAGE DISPLAY ***
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Comment Input Field
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: () async {
                              final commentText = commentController.text.trim();
                              if (commentText.isNotEmpty) {

                                // Use the cached user details
                                final newComment = Comment(
                                  userId: widget.currentUserId,
                                  username: _currentUsername,
                                  userPhotoUrl: _currentUserPhotoUrl,
                                  text: commentText,
                                  timestamp: Timestamp.now(),
                                );

                                await FirebaseFirestore.instance
                                    .collection("userposts")
                                    .doc(widget.post.id)
                                    .update({'comments': FieldValue.arrayUnion([newComment.toMap()])});

                                commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- END UPDATED: Show comments as a Bottom Modal Sheet ---

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
    // Re-implemented to correctly handle the initial image index for the full-screen view.
    setState(() => _currentImageIndex = initialIndex);

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
                onPageChanged: (idx, _) {
                  setState(() => _currentImageIndex = idx);
                },
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

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("userposts")
          .doc(widget.post.id)
          .snapshots(),
      builder: (context, snapshot) {
        String username = widget.post.username;
        String profileImageUrl = widget.post.profileImageUrl;
        List<dynamic> likes = [];
        List<dynamic> comments = []; // Now stores a list of maps (the comment structure)

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          username = data['username'] ?? widget.post.username;
          profileImageUrl = data['userPhotoUrl'] ?? widget.post.profileImageUrl;
          likes = (data['likes'] ?? []) as List<dynamic>;
          comments = (data['comments'] ?? []) as List<dynamic>;
        }

        final isLiked = likes.contains(widget.currentUserId);

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
                      backgroundImage: (profileImageUrl.startsWith('http')
                          ? NetworkImage(profileImageUrl)
                          : FileImage(File(profileImageUrl)))
                      as ImageProvider<Object>,
                      onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person),
                    ),
                    title: Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sw * 0.045),
                    ),
                    subtitle: Text(
                      _getTimeAgo(widget.post.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: sw * 0.034),
                    ),
                    trailing: const Icon(Icons.more_horiz),
                  ),
                ),

                // Media (images or videos)
                if (widget.post.imageUrls.isNotEmpty)
                  _buildLinkedInImageGrid(widget.post.imageUrls, sw, sh)
                else if (widget.post.videos.isNotEmpty)
                  _buildVideoPlayer(sh),

                // Like & Comment Section
                Padding(
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
                        onTap: () => _showCommentsBottomSheet(comments),
                      ),
                    ],
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
              ],
            ),
          ),
        );
      },
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
          .clamp(100.0, maxH) // Use 100.0 for double
          .toDouble();

      return GestureDetector(
        onTap: () => _openFullScreenGallery(0),
        child: Container(
          width: double.infinity,
          height: height,
          color: Colors.grey.shade200,
          child: _imageWidget(url, BoxFit.cover),
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
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, _, __) => const Center(child: Icon(Icons.broken_image, size: 40)),
      );
    } else {
      // Local files don't need a loading indicator since they load instantly
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (!_videoController!.value.isPlaying)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
        ],
      ),
    );
  }
}