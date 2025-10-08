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
import 'package:url_launcher/url_launcher_string.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

// Helper function to capitalize the first letter of each word
String capitalizeWords(String text) {
  if (text.isEmpty) {
    return '';
  }
  return text.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// Model class for network connections
class Mynetwork {
  final String id;
  final String username;
  final String Designation;
  final String mobile;
  final String email;
  final String companywebsite;
  final String businessLocation;
  final String industry;
  final String contry;
  final String city;
  final String photoUrl;
  final String? organization;


  Mynetwork({
    required this.id,
    required this.username,
    required this.Designation,
    required this.mobile,
    required this.email,
    required this.companywebsite,
    required this.businessLocation,
    required this.industry,
    required this.contry,
    required this.city,
    required this.photoUrl,
    this.organization

  });
}

// -------------------- UserprofileScreen --------------------
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
  late AuthUserModel _currentUser;

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
      _currentUser = AuthUserModel(
        id: docId,
        name: widget.user?.name ?? "",
        mobile: widget.user?.mobile ?? "",
        email: widget.user?.email,
        role: widget.user?.role,
        city: widget.user?.city,
        designation: widget.user?.designation ?? "",
        organization: widget.user?.organization ?? "",
        aboutme: widget.user?.aboutme ?? "",
        photoUrl: widget.user?.photoUrl ?? "",
      );
    }
  }

  Future<AuthUserModel?> fetchUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("userregister")
          .doc(userId)
          .get();
      if (doc.exists) {
        _currentUser = AuthUserModel.fromFirestore(doc);
        return _currentUser;
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
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildProfileUI(_currentUser, screenHeight, screenWidth),
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
          _currentUser = snapshot.data!;
          return _buildProfileUI(_currentUser, screenHeight, screenWidth);
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
          onPressed: () {
            _showEditProfileModal(context, _currentUser);
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  void _showEditProfileModal(BuildContext context, AuthUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return _EditProfileModal(
          user: user,
          onProfileUpdated: () {
            setState(() {
              // Refresh the screen after updating
              _userFuture = fetchUser(docId);
            });
          },
        );
      },
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
                          : const AssetImage(
                          "assets/images/default_avatar.png")
                      as ImageProvider,
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
                _buildConnectionsTab(user),
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
            icon: Icons.email,
            title: "Email",
            value: user.email ?? "Not Provided",
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
              if (posts.isEmpty) return const Center(child: Text("No posts yet"));
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
                        borderRadius: BorderRadius.circular(16)),
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
                                          fontSize: 12, color: Colors.grey),
                                    ),
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

  // -------------------- Connections Tab Method --------------------
  Widget _buildConnectionsTab(AuthUserModel user) {
    final cleanedCurrentUserId = docId;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _connectionsStream(cleanedCurrentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No connections yet"));
        }

        final docs = snapshot.data!;
        final connectedUserIds = docs.map((doc) {
          String fromId = _getIdFromPath(doc['from']);
          String toId = _getIdFromPath(doc['to']);
          return fromId == cleanedCurrentUserId ? toId : fromId;
        }).toSet().toList();

        return FutureBuilder<List<Mynetwork>>(
          future: _fetchUsersDetails(connectedUserIds),
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!usersSnapshot.hasData || usersSnapshot.data!.isEmpty) {
              return const Center(child: Text("No connections yet"));
            }

            final users = usersSnapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final connectedUser = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: Appcolor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                        (connectedUser.photoUrl.isNotEmpty)
                            ? NetworkImage(connectedUser.photoUrl)
                            : const AssetImage("assets/images/default_avatar.png")
                        as ImageProvider,
                      ),
                      title: Text(
                        capitalizeWords(connectedUser.username),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(connectedUser.Designation),
                          Text('Company: ${connectedUser.companywebsite}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          Text('Location: ${connectedUser.businessLocation}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          Text('Industry: ${connectedUser.industry}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MynetworkDetailView(user: connectedUser),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getIdFromPath(String path) {
    if (path.contains('/documents/')) {
      return path.split('/').last;
    }
    return path;
  }

  Stream<List<QueryDocumentSnapshot>> _connectionsStream(String cleanedUserId) {
    final requestsStream =
    FirebaseFirestore.instance.collection('requests').snapshots();

    return requestsStream.map((snapshot) {
      return snapshot.docs.where((doc) {
        final fromId = _getIdFromPath(doc['from']);
        final toId = _getIdFromPath(doc['to']);
        return doc['status'] == 'approved' &&
            (fromId == cleanedUserId || toId == cleanedUserId);
      }).toList();
    });
  }

  Future<List<Mynetwork>> _fetchUsersDetails(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }

    final userDocs = await FirebaseFirestore.instance
        .collection('userregister')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return userDocs.docs.map((doc) {
      final data = doc.data();
      return Mynetwork(
        id: doc.id,
        username: (data['name'] as String?) ?? "N/A",
        Designation: (data['designation'] as String?) ?? "N/A",
        mobile: (data['mobile'] as String?) ?? "N/A",
        email: (data['email'] as String?) ?? "N/A",
        companywebsite: (data['companywebsite'] as String?) ?? "N/A",
        businessLocation: (data['businessLocation'] as String?) ?? "N/A",
        industry: (data['industry'] as String?) ?? "N/A",
        contry: (data['country'] as String?) ?? "N/A",
        city: (data['city'] as String?) ?? "N/A",
        photoUrl: (data['photoUrl'] as String?) ?? "https://via.placeholder.com/150",
      );
    }).toList();
  }
}

// -------------------- New Modal for Editing Profile --------------------
class _EditProfileModal extends StatefulWidget {
  final AuthUserModel user;
  final VoidCallback onProfileUpdated;

  const _EditProfileModal({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _organizationController;
  late TextEditingController _aboutmeController;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _designationController =
        TextEditingController(text: widget.user.designation);
    _organizationController =
        TextEditingController(text: widget.user.organization);
    _aboutmeController = TextEditingController(text: widget.user.aboutme);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _organizationController.dispose();
    _aboutmeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) {
      return widget.user.photoUrl;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${widget.user.id}.jpg');
      await ref.putFile(_pickedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newPhotoUrl = await _uploadImage();

      if (newPhotoUrl == null && _pickedImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed. Please try again.")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('userregister')
          .doc(widget.user.id)
          .update({
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'organization': _organizationController.text.trim(),
        'aboutme': _aboutmeController.text.trim(),
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      widget.onProfileUpdated();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to update profile. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Edit Profile",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (widget.user.photoUrl?.isNotEmpty ?? false)
                          ? NetworkImage(widget.user.photoUrl!)
                          : const AssetImage(
                          "assets/images/default_avatar.png")
                      as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.blue, size: 30),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: "Name",
                      icon: Icons.person,
                    ),
                    _buildTextField(
                      controller: _designationController,
                      label: "Designation",
                      icon: Icons.badge,
                    ),
                    _buildTextField(
                      controller: _organizationController,
                      label: "Organization",
                      icon: Icons.business,
                    ),
                    _buildTextField(
                      controller: _aboutmeController,
                      label: "About Me",
                      icon: Icons.info_outline,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}

// ---------------- VIDEO PLAYER ----------------
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

// ---------------- COMMENT SECTION ----------------
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
        {
          "text": _controller.text.trim(),
          "timestamp": DateTime.now().toIso8601String()
        }
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
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- CREATE POST MODAL ----------------
class CreatePostModal extends StatefulWidget {
  final String userId;
  final String userName;
  const CreatePostModal({super.key, required this.userId, required this.userName});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _contentController = TextEditingController();
  List<File> _images = [];
  List<File> _videos = [];

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked != null) {
      setState(() {
        _images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _pickVideos() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _videos.add(File(picked.path));
      });
    }
  }

  Future<String> _uploadFile(File file, String folder) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("$folder/${DateTime.now().millisecondsSinceEpoch}");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void _createPost() async {
    List<String> imageUrls = [];
    List<String> videoUrls = [];
    for (var img in _images) imageUrls.add(await _uploadFile(img, "post_images"));
    for (var vid in _videos) videoUrls.add(await _uploadFile(vid, "post_videos"));

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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _contentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "What's on your mind?"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("Add Images"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickVideos,
                    child: const Text("Add Video"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _createPost,
                child: const Text("Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MynetworkDetailView extends StatelessWidget {
  final Mynetwork user;

  const MynetworkDetailView({super.key, required this.user});

  Widget _buildInfoRow(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueGrey, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      appBar: AppBar(
        title: const Text("User Details", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDCEAF4), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: (user.photoUrl.isNotEmpty)
                        ? NetworkImage(user.photoUrl)
                        : const AssetImage("assets/images/default_avatar.png")
                    as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    capitalizeWords(user.username),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.Designation,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7B8BB2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color:Appcolor.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      "Contact Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF535D97),
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    Icons.email,
                    "Email",
                    user.email,
                    onTap: () async {
                      if (await canLaunchUrlString("mailto:${user.email}")) {
                        await launchUrlString("mailto:${user.email}");
                      }
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow(
                    Icons.call,
                    "Mobile",
                    user.mobile,
                    onTap: () async {
                      if (await canLaunchUrlString("tel:${user.mobile}")) {
                        await launchUrlString("tel:${user.mobile}");
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color:Appcolor.white,
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      "Business Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF535D97),
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    Icons.business,
                    "Company Website",
                    user.companywebsite,
                    onTap: () async {
                      String url = user.companywebsite.startsWith('http') ? user.companywebsite : 'https://${user.companywebsite}';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow(
                    Icons.location_on,
                    "Business Location",
                    user.businessLocation,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow(
                    Icons.category,
                    "Industry",
                    user.industry,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow(
                    Icons.flag,
                    "Country",
                    user.contry,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow(
                    Icons.location_city,
                    "City",
                    user.city,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}