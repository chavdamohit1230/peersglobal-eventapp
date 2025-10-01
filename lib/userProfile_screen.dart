import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:peersglobleeventapp/modelClass/model/auth_User_model.dart';
import 'package:peersglobleeventapp/modelClass/model/userregister_model.dart';

class UserprofileScreen extends StatefulWidget {
  final String? userId;
  final UserRegister? user;
  const UserprofileScreen({super.key, this.userId, required this.user});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<AuthUserModel?>? _userFuture;
  late String docId;

  @override
  void initState() {
    super.initState();
    int tabLength = 2;
    if (widget.user?.role?.toLowerCase() == "exhibitor" ||
        widget.user?.role?.toLowerCase() == "sponsor" ||
        widget.user?.role?.toLowerCase() == "organizer") {
      tabLength = 3;
    }
    _tabController = TabController(length: tabLength, vsync: this);
    if (widget.user == null && widget.userId != null) {
      docId = widget.userId!.split("/").last;
      _userFuture = fetchUser(docId);
    } else {
      docId = widget.userId ?? "";
    }
  }

  Future<AuthUserModel?> fetchUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("userregister")
          .doc(userId)
          .get();
      if (doc.exists) {
        return AuthUserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print("Firestore error: $e");
      return null;
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isExhibitorOrSponsor(String? role) {
    final r = role?.toLowerCase() ?? "";
    return r == "exhibitor" || r == "sponsor";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.user != null) {
      final localUser = AuthUserModel(
        id: widget.userId ?? "",
        name: widget.user!.name ?? "",
        mobile: widget.user!.mobile ?? "",
        email: widget.user!.email,
        role: widget.user!.role,
        city: widget.user!.city,
        designation: widget.user!.designation ?? "",
        organization: widget.user!.organization?? "",
        aboutme: widget.user!.aboutme?? "",
        photoUrl: widget.user!.photoUrl?? "",
      );
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildProfileUI(localUser, screenHeight, screenWidth),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<AuthUserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }
          return _buildProfileUI(snapshot.data!, screenHeight, screenWidth);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF3F8FE),
      title: const Center(
        child: Text(
          "Profile",
          style: TextStyle(color: Color(0xFF535D97)),
        ),
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _buildProfileUI(
      AuthUserModel user, double screenHeight, double screenWidth) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFF3F8FE),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF3F8FE),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 41,
                      backgroundImage: (user.photoUrl?.isNotEmpty ?? false)
                          ? NetworkImage(user.photoUrl!)
                          : const AssetImage("assets/images/default_avatar.png"),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isNotEmpty ? user.name : "No Name",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.role ?? "Attendee",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7B8BB2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.organization ?? "Company Name",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7B8BB2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF535D97),
                labelColor: const Color(0xFF535D97),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  const Tab(text: "Profile Detail"),
                  if (isExhibitorOrSponsor(user.role)) const Tab(text: "Posts"),
                  const Tab(text: "Connections"),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF3F8FE),
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildProfileDetails(user, screenHeight, screenWidth),
                if (isExhibitorOrSponsor(user.role)) _buildPostsTab(user),
                const Center(child: Text("Connections")),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(
      AuthUserModel user, double screenHeight, double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _simpleInfoRow(
            icon: Icons.person,
            title: "Name",
            value: user.name.isNotEmpty ? user.name : "Not Provided",
          ),
          _simpleInfoRow(
            icon: Icons.email,
            title: "Email",
            value: user.email ?? "Not Provided",
          ),
            _simpleInfoRow(
              icon: Icons.business,
              title: "Organization",
              value: user.organization ?? "Not Provided",
            ),
          _simpleInfoRow(
            icon: Icons.badge,
            title: "Designation",
            value: user.designation ?? "Not Provided",
          ),
          _simpleInfoRow(
            icon: Icons.call,
            title: "Mobile",
            value: user.mobile,
          ),
          _simpleInfoRow(
            icon: Icons.location_city,
            title: "City",
            value: user.city ?? "Not Provided",
          ),
          _simpleInfoRow(
            icon: Icons.accessibility_sharp,
            title: "About Me",
            value: user.aboutme ?? "Not Provided",
          ),
        ],
      ),
    );
  }

  Widget _simpleInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPostsTab(AuthUserModel user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    builder: (context) =>
                        CreatePostModal(userId: user.id, userName: user.name),
                    elevation: 5,
                    backgroundColor: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text("Create Post"),
              )
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("userposts")
                .where("userId", isEqualTo: user.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data!.docs;

              posts.sort((a, b) {
                final t1 =
                    (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
                final t2 =
                    (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
                return t2.compareTo(t1);
              });

              if (posts.isEmpty) {
                return const Center(child: Text("No posts yet"));
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final images = List<String>.from(post["images"] ?? []);
                  final videos = List<String>.from(post["videos"] ?? []);
                  final likes = List<String>.from(post["likes"] ?? []);
                  final content = post["content"] ?? "";
                  final postId = post.id;
                  final timestamp = (post["timestamp"] as Timestamp?)?.toDate();

                  return Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post["userName"] ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  if (timestamp != null)
                                    Text(
                                        DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(timestamp),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              if (post["userId"] == user.id)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("userposts")
                                        .doc(postId)
                                        .delete();
                                  },
                                ),
                            ],
                          ),
                        ),
                        if (images.isNotEmpty)
                          SizedBox(
                            height: 250,
                            child: PageView(
                              children: images
                                  .map((url) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(url,
                                    fit: BoxFit.cover),
                              ))
                                  .toList(),
                            ),
                          ),
                        if (videos.isNotEmpty)
                          SizedBox(
                            height: 250,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: videos
                                  .map((url) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 250,
                                    child: VideoPostWidget(videoUrl: url),
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                        if (content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(content,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite,
                                    color: likes.contains(user.id)
                                        ? Colors.red
                                        : Colors.grey),
                                onPressed: () {
                                  if (likes.contains(user.id)) {
                                    post.reference.update({
                                      "likes": FieldValue.arrayRemove([user.id])
                                    });
                                  } else {
                                    post.reference.update({
                                      "likes": FieldValue.arrayUnion([user.id])
                                    });
                                  }
                                },
                              ),
                              Text("${likes.length} Likes"),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  _openComments(context, postId);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentSection(postId: postId),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required double screenHeight,
    required double screenWidth,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.035, vertical: screenHeight * 0.015),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: screenWidth * 0.031),
              Text(title,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.1),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

// --------------------- VIDEO PLAYER WIDGET ---------------------
class VideoPostWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPostWidget({super.key, required this.videoUrl});

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 50,
            color: Colors.white,
          ),
          onPressed: () {
            _isPlaying ? _controller.pause() : _controller.play();
          },
        ),
      ],
    );
  }
}

class CommentSection extends StatefulWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();

  void _addComment() async {
    if (_controller.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection("userposts")
        .doc(widget.postId)
        .update({
      "comments": FieldValue.arrayUnion([
        {"text": _controller.text.trim(), "timestamp": DateTime.now().toIso8601String()}
      ])
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("userposts")
                    .doc(widget.postId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final comments =
                  List<Map<String, dynamic>>.from(snapshot.data!["comments"] ?? []);
                  if (comments.isEmpty) {
                    return const Center(child: Text("No comments yet"));
                  }
                  return ListView(
                    children: comments
                        .map((c) => ListTile(
                      title: Text(c["text"] ?? ""),
                    ))
                        .toList(),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                    const InputDecoration(hintText: "Add a comment"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --------------------- CREATE POST MODAL ---------------------
class CreatePostModal extends StatefulWidget {
  final String userId;
  final String userName;
  const CreatePostModal({super.key, required this.userId, required this.userName});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  XFile? _selectedVideo;
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _selectedVideo = video);
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImages.isEmpty && _selectedVideo == null && _contentController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);

    try {
      List<String> imageUrls = [];
      List<String> videoUrls = [];

      for (var img in _selectedImages) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("postDataImage/${DateTime.now().millisecondsSinceEpoch}_${img.name}");
        await ref.putFile(File(img.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      if (_selectedVideo != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("postDataImage/${DateTime.now().millisecondsSinceEpoch}_${_selectedVideo!.name}");
        await ref.putFile(File(_selectedVideo!.path));
        videoUrls.add(await ref.getDownloadURL());
      }

      await FirebaseFirestore.instance.collection("userposts").add({
        "userId": widget.userId,
        "userName": widget.userName,
        "content": _contentController.text.trim(),
        "images": imageUrls,
        "videos": videoUrls,
        "likes": [],
        "comments": [],
        "timestamp": DateTime.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      print("Upload error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Create Post",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                  hintText: "Write something...", contentPadding: EdgeInsets.all(12)),
            ),
            Wrap(
              children: _selectedImages
                  .map((img) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(File(img.path),
                    width: 80, height: 80, fit: BoxFit.cover),
              ))
                  .toList(),
            ),
            if (_selectedVideo != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Video selected: ${_selectedVideo!.name}"),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text("Add Images")),
                ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text("Add Video")),
              ],
            ),
            const SizedBox(height: 12),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _uploadPost,
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
