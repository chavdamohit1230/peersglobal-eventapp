// HomePage.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peersglobleeventapp/exhibiter_screen.dart';
import 'package:peersglobleeventapp/modelClass/model/userregister_model.dart';
import 'package:peersglobleeventapp/modelClass/user_PostModel.dart';
import 'package:peersglobleeventapp/my_network.dart';
import 'package:peersglobleeventapp/qr_Scanner.dart';
import 'package:peersglobleeventapp/widgets/userpostCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peersglobleeventapp/modelClass/model/auth_User_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  final UserRegister? user;
  const HomePage({super.key, this.userId, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool isBottomSheetOpen = false; // Kept for 'More' tab logic
  AuthUserModel? user;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  double safeFontSize(double size, double min, double max) {
    return size.clamp(min, max);
  }

  Future<void> fetchUserData() async {
    try {
      if (widget.userId == null || widget.userId!.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      String docId = widget.userId!.contains("/") ? widget.userId!.split("/").last : widget.userId!;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("userregister")
          .doc(docId)
          .get();

      if (snapshot.exists) {
        setState(() {
          user = AuthUserModel.fromJson(snapshot.data() as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      user = AuthUserModel(
        id: widget.userId ?? "",
        role: widget.user!.role ?? "",
        name: widget.user!.name ?? "",
        mobile: widget.user!.mobile ?? "",
        organization: widget.user!.organization,
        designation: widget.user!.designation ?? "",
        photoUrl: widget.user!.photoUrl ?? "",
      );
      isLoading = false;
    } else {
      fetchUserData();
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    if (index == 2) {
      return;
    }

    if (index == 4) {
      setState(() => isBottomSheetOpen = true);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          double iconSize = MediaQuery.of(context).size.width * 0.08;
          double fontSize = MediaQuery.of(context).size.width * 0.035;
          double spacing = MediaQuery.of(context).size.height * 0.01;

          Widget buildAction(String label, IconData icon, VoidCallback onTap) {
            return GestureDetector(
              onTap: onTap,
              child: SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Icon(icon, size: iconSize, color: Colors.black),
                    SizedBox(height: spacing),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: fontSize, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }

          return StatefulBuilder(builder: (context, setStateModal) {
            return Container(
              color: const Color(0xFFF0F4FD),
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  Text(
                    "Peers Global",
                    style: TextStyle(
                      fontSize: fontSize + 5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF535D97),
                    ),
                  ),
                  Text(
                    "The Community Of Collaboration",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(0xFF535D97),
                    ),
                  ),
                  const Divider(height: 40, thickness: 1, endIndent: 50, indent: 50),
                  SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildAction("Event Profile", Icons.work_outline, () => context.push('/eventprofile')),
                      buildAction("Speakers", Icons.account_circle_outlined, () => context.push('/speaker')),
                      buildAction("Floor Plan", Icons.grid_on, () => context.push('/floorplan')),
                    ],
                  ),
                  SizedBox(height: spacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildAction("Sponsors\n& Partners", Icons.handshake_outlined, () => context.push('/sponsor')),
                      buildAction("Selfie Plan", Icons.photo_camera_front_outlined, () {}),
                      buildAction("Agenda", Icons.event_note_outlined, () => context.push('/eventagenda')),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ).whenComplete(() {
        // Sheet closed
        setState(() => isBottomSheetOpen = false);
      });
    } else {
      setState(() => selectedIndex = index);
    }
  }

  // --- START: Back button handler (Only Bottom Navigation Index Logic) ---
  Future<bool> _onWillPop() async {
    // If not on the Home tab (index 0), switch to Home tab.
    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
      return false; // Prevent app from exiting
    }

    // If on Home tab, allow the app to exit.
    return true;
  }
  // --- END: Back button handler (Only Bottom Navigation Index Logic) ---


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop, // 👈 Uses the logic to switch to index 0
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FD),
        drawer: Drawer(
          backgroundColor: const Color(0xFFF0F4FD),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        color: const Color(0xFFF0F4FD),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: (user != null && user!.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                  ? NetworkImage(user!.photoUrl!)
                                  : (widget.user != null && widget.user!.photoUrl != null && widget.user!.photoUrl!.isNotEmpty)
                                  ? NetworkImage(widget.user!.photoUrl!)
                                  : const AssetImage('assets/peersgloblelogo.png') as ImageProvider,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user != null ? user!.name : widget.user?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: safeFontSize(screenWidth * 0.08, 18, 24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user != null ? (user!.designation ?? '') : (widget.user?.designation ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis, // Corrected here
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: safeFontSize(screenWidth * 0.03, 11, 15),
                              ),
                            ),
                            Text(
                              "Attendee : Business Information",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis, // Corrected here
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: safeFontSize(screenWidth * 0.04, 13, 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 2, indent: 20, endIndent: 20),
                      ListTile(
                        leading: const Icon(Icons.home, size: 28),
                        title: const Text('Home', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to Home tab (index 0)
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.person, size: 28),
                        title: const Text('Profile', style: TextStyle(fontSize: 18)),
                        onTap: () => context.push('/userProfile_screen', extra: {
                          'userId': widget.userId,
                          'user': widget.user,
                        }),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_alt_outlined, size: 28),
                        title: const Text('Meeting', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          String currentUserId = widget.userId ?? user?.id ?? "";
                          context.push('/meeting', extra: {'currentUserId': currentUserId});
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_outline, size: 28),
                        title: const Text('People You May Know', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          String currentUserId = widget.userId ?? user?.id ?? "";
                          context.push('/people_knows', extra: {'currentUserId': currentUserId});
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add_alt_1, size: 28),
                        title: const Text('Invitation', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          String currentUserId = widget.userId ?? user?.id ?? "";
                          context.push('/invitaion', extra: {'currentUserId': currentUserId});
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings, size: 28),
                        title: const Text('Settings', style: TextStyle(fontSize: 18)),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 2),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red, size: 28),
                  title: const Text('Logout', style: TextStyle(fontSize: 18, color: Colors.red)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('isLoggedIn');
                    await prefs.remove('userId');
                    if (context.mounted) context.go('/loginscreen');
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF3F8FE),
          elevation: 2,
          shadowColor: Colors.grey.shade300,
          toolbarHeight: screenHeight * 0.10,
          titleSpacing: 0,
          title: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Icon(Icons.menu, color: Colors.black87, size: screenHeight * 0.03),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.055,
                      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade800, size: screenHeight * 0.025),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(hintText: "Search here", border: InputBorder.none, isDense: true),
                              style: TextStyle(fontSize: screenHeight * 0.016),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  // ----- START: Notification Icon with Dynamic Badge -----
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('notifications').where('isRead', isEqualTo: false).snapshots(),
                    builder: (context, snapshot) {
                      int notificationCount = 0;
                      if (snapshot.hasData) {
                        notificationCount = snapshot.data!.docs.length;
                      }

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: Colors.black87,
                              size: screenHeight * 0.03,
                            ),
                            onPressed: () {
                              context.push('/recentnotification');
                            },
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 5,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  // ----- END: Notification Icon with Dynamic Badge -----
                ],
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: selectedIndex == 4 ? 0 : selectedIndex,
          children: [
            SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("userposts")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts available"));
                  }

                  final filteredPosts = snapshot.data!.docs.where((doc) {
                    final post = UserPostModel.fromFirestore(doc);
                    return post.username!.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return const Center(child: Text("No posts found for this search"));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final doc = filteredPosts[index];
                      final post = UserPostModel.fromFirestore(doc);
                      return Userpostcard(
                        post: post,
                        currentUserId: widget.userId ?? user?.id ?? "",
                      );
                    },
                  );
                },
              ),
            ),
            MyNetwork(currentUserId: widget.userId ?? user?.id ?? ""),
            QrScanner(),
            ExhibiterScreen(),
            Container(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFF3F8FE),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF535D97),
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'My Network'),
            BottomNavigationBarItem(
              icon: const CircleAvatar(
                backgroundColor:Appcolor.backgroundLight,
                radius: 28,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Image(
                    image: AssetImage('assets/peersgloblelogo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.apartment_outlined), label: 'Exhibitors'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
          ],
        ),
      ),
    );
  }
}