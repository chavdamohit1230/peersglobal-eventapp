import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Future<AuthUserModel?> _userFuture;
  late String docId;

  @override
  void initState() {
    super.initState();

    // Default length 2 (Profile + Connections)
    int tabLength = 2;

    // Agar exhibiter ya sponsor hai to ek extra tab
    if (widget.user?.role?.toLowerCase() == "exhibiter" ||
        widget.user?.role?.toLowerCase() == "sponsor") {
      tabLength = 3;
    }

    _tabController = TabController(length: tabLength, vsync: this);

    if (widget.userId != null && widget.userId!.isNotEmpty) {
      docId = widget.userId!.split("/").last;
    } else {
      docId = "";
    }

    print("✅ Extracted Firestore docId: $docId");
    _userFuture = fetchUser(docId);
  }

  Future<AuthUserModel?> fetchUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("userregister")
          .doc(userId)
          .get();

      if (doc.exists) {
        print("✅ User data: ${doc.data()}");
        return AuthUserModel.fromFirestore(doc);
      } else {
        print("❌ User not found with id: $userId");
        return null;
      }
    } catch (e) {
      print("🔥 Firestore error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: FutureBuilder<AuthUserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final user = snapshot.data!;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 41,
                      backgroundImage: NetworkImage(
                          "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isNotEmpty
                                ? user.name
                                : widget.user?.name ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.role ?? "Attendee",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "User ID: $docId",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🧭 TabBar
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF535D97),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF535D97),
                tabs: [
                  const Tab(text: "Profile Detail"),
                  if (user.role?.toLowerCase() == "exhibiter" ||
                      user.role?.toLowerCase() == "sponsor")
                    const Tab(text: "Posts"),
                  const Tab(text: "Connections"),
                ],
              ),

              // 📄 TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Profile Detail
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          icon: Icons.call,
                          title: "Mobile Number",
                          value: user.mobile,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                        _infoRow(
                          icon: Icons.email_sharp,
                          title: "Email",
                          value: user.email ?? "Not Provided",
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                        _infoRow(
                          icon: Icons.area_chart_outlined,
                          title: "City",
                          value: user.city ?? "Not Provided",
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),

                    // ✅ Posts tab (sirf exhibiter/sponsor ke liye)
                    if (user.role?.toLowerCase() == "exhibiter" ||
                        user.role?.toLowerCase() == "sponsor")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Posts",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Create Post Here"),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          const Expanded(
                            child: Center(child: Text("No posts yet")),
                          ),
                        ],
                      ),

                    // Connections tab
                    const Center(child: Text("Connections")),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.035, vertical: screenHeight * 0.015),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: screenWidth * 0.031),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.1),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
