
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
  Future<AuthUserModel?>? _userFuture;
  late String docId;

  @override
  void initState() {
    super.initState();

    int tabLength = 2;
    if (widget.user?.role?.toLowerCase() == "exhibiter" ||
        widget.user?.role?.toLowerCase() == "sponsor") {
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
        // 🔹 Profile + TabBar ek hi background ke andar
        Container(
          color: const Color(0xFFF3F8FE),
          child: Column(
            children: [
              // Profile info
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
                            user.name.isNotEmpty ? user.name : "No Name",
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
                            "User ID: ${user.id}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: false, // 🔹 tabs evenly space honge
                indicatorColor: const Color(0xFF535D97),
                indicatorWeight: 3, // 🔹 thickness of indicator
                indicatorSize: TabBarIndicatorSize.tab, // 🔹 full tab ke niche chalega
                labelColor: const Color(0xFF535D97),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  const Tab(text: "Profile Detail"),
                  if (user.role?.toLowerCase() == "exhibitor" ||
                      user.role?.toLowerCase() == "sponsor")
                    const Tab(text: "Posts"),
                  const Tab(text: "Connections"),
                ],
              ),

            ],
          ),
        ),

        // 🔹 TabBarView with same background
        Expanded(
          child: Container(
            color: const Color(0xFFF3F8FE),
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // Profile Detail
                SingleChildScrollView(
                  child: Column(
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
                ),

                // Posts tab (only for exhibiter/sponsor)
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
                                  fontSize: 18, fontWeight: FontWeight.bold),
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

                // Connections
                const Center(child: Text("Connections")),
              ],
            ),
          ),
        ),
      ],
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
