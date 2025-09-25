
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
import 'package:peersglobleeventapp/eventagenda.dart';


class HomePage extends StatefulWidget {
  final String? userId;
  final UserRegister?  user;
  const HomePage({super.key,this.userId,this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  Map<String, dynamic>? userData;
  AuthUserModel? user;
  bool isLoading = true;


  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 4) {
        // Modal Bottom Sheet for "More"
        showModalBottomSheet(
          context: context,
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

            return Container(
              color:const Color(0xFFF0F4FD),
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
                  const Divider(
                    height: 40,
                    thickness: 1,
                    endIndent: 50,
                    indent: 50,
                  ),
                  SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => context.push(''),
                        child: buildAction("My Briefcase", Icons.work_outline, () {}),
                      ),
                      InkWell(
                        onTap: () => context.push(''),
                        child: buildAction("My Favorite", Icons.star_border_outlined, () {}),
                      ),
                      InkWell(
                        onTap: () =>context.push('/floorplan'),
                        child: buildAction("Floor Plan", Icons.grid_on, () {}),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () =>context.push(''),
                        child: buildAction("Sponsors\n& Partners", Icons.handshake_outlined, () {}),
                      ),
                      InkWell(
                        onTap: () => context.push(''),
                        child: buildAction("Selfie Plan", Icons.photo_camera_front_outlined, () {}),
                      ),
                      InkWell(
                        onTap: () => context.push('/eventagenda'),
                        child: buildAction("Agenda", Icons.event_note_outlined, () {}),
                      ),
                    ],
                  ),

                ],
              ),
            );
          },
        );
      } else {
        selectedIndex = index;
      }
    });
  }


  final List<userPostModel> UserPost =[
    userPostModel(username: "Demo",
        profileImageUrl:"https://randomuser.me/api/portraits/men/1.jpg",
        caption:"Exploring the Mountain",
        ImageUrls:[
          "https://images.pexels.com/photos/1264210/pexels-photo-1264210.jpeg?cs=srgb&dl=pexels-andre-furtado-43594-1264210.jpg&fm=jpg",
          "https://images.ctfassets.net/pdf29us7flmy/1FLfD1FtKSVGDyi0G0BQSE/d3a75ce5609c1f021f276e91c29942ca/GettyImages-928146626__1_.jpg",
          "https://photonify.com/wp-content/uploads/2019/02/freelance-photography-1000x750.jpg",
        ],
        likes:20,
        comments:21,
        timeago:"46"),

        userPostModel(username: "Demo",
        profileImageUrl:"https://randomuser.me/api/portraits/men/1.jpg",
        caption:"Exploring the Mountain",
        ImageUrls:[
          "https://dims.apnews.com/dims4/default/1aa9da3/2147483647/strip/true/crop/5116x7670%2B0%2B0/resize/400x599%21/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2F8b%2F85%2F1166c1719950dc708f2d7509dbc5%2Fcf5a0955241c467da04267618a81e301",
          "https://assets.bwbx.io/images/users/iqjWHBFdfxIU/i.RUss7Xshmc/v0/-1x-1.webp",
          "https://ew.com/thmb/c-MquAfpllKftCsFwcfla1E3PUc%3D/1500x0/filters%3Ano_upscale%28%29%3Amax_bytes%28150000%29%3Astrip_icc%28%29/000248610hr-2000-76a3cf6dd8054f76bb8dbf9011acbcf0.jpg",
          "https://ew.com/thmb/c-MquAfpllKftCsFwcfla1E3PUc%3D/1500x0/filters%3Ano_upscale%28%29%3Amax_bytes%28150000%29%3Astrip_icc%28%29/000248610hr-2000-76a3cf6dd8054f76bb8dbf9011acbcf0.jpg",

        ],
        likes:20,
        comments:21,
        timeago:"46"),
    userPostModel(username: "Demo",
        profileImageUrl:"https://randomuser.me/api/portraits/men/1.jpg",
        caption:"Exploring the Mountain",
        ImageUrls:[
          "https://images.pexels.com/photos/1264210/pexels-photo-1264210.jpeg?cs=srgb&dl=pexels-andre-furtado-43594-1264210.jpg&fm=jpg",
          "https://images.ctfassets.net/pdf29us7flmy/1FLfD1FtKSVGDyi0G0BQSE/d3a75ce5609c1f021f276e91c29942ca/GettyImages-928146626__1_.jpg",
          "https://photonify.com/wp-content/uploads/2019/02/freelance-photography-1000x750.jpg",
        ],
        likes:20,
        comments:21,
        timeago:"46"),

  ];

  double safeFontSize(double size, double min, double max) {
    return size.clamp(min, max);
  }
  Future<void> fetchUserData() async {
    try {
      if (widget.userId == null || widget.userId!.isEmpty) {
        print("⚠️ userId is null or empty");
        setState(() => isLoading = false);
        return;
      }

      // Sirf doc ID extract karna (agar userId pura path hua ho)
      String docId = widget.userId!.contains("/")
          ? widget.userId!.split("/").last
          : widget.userId!;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("userregister")
          .doc(docId)
          .get();

      if (snapshot.exists) {
        setState(() {
          user = AuthUserModel.fromJson(snapshot.data() as Map<String, dynamic>);
          isLoading = false;
        });

        print("✅ User data fetched: ${user?.toJson()}");
      } else {
        setState(() => isLoading = false);
        print("❌ User not found with id: $docId");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("⚠️ Error fetching user data: $e");
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
        designation: widget.user!.designation?? "",

        // agar role bhi hai
      );
      isLoading = false;
    } else {
      // login case me Firestore se fetch karna hai
      fetchUserData();
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                    // Custom flexible header
                    Container(
                      color: const Color(0xFFF0F4FD),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundImage: AssetImage('assets/peersgloblelogo.png'),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user!=null ?
                                user!.name :widget.user?.name?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: safeFontSize(
                                MediaQuery.of(context).size.width * 0.080, 18, 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(user!=null ?
                          (user!.designation?? ''):(widget.user?.designation?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: safeFontSize(
                                  MediaQuery.of(context).size.width * 0.030, 11, 15),
                            ),
                          ),
                          Text(
                            "Attendee : Business Information",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: safeFontSize(
                                  MediaQuery.of(context).size.width * 0.040, 13, 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    // Navigation Items
                    ListTile(
                      leading: const Icon(Icons.home, size: 28),
                      title: const Text('Home', style: TextStyle(fontSize: 18)),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, size: 28),
                      title: const Text('Profile', style: TextStyle(fontSize: 18)),
                      onTap: () => context.push(
                        '/userProfile_screen',
                        extra:{
                          'userId':widget.userId,
                          'user':widget.user
                        }
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_alt_outlined, size: 28),
                      title: const Text('Meeting', style: TextStyle(fontSize: 18)),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_outline, size: 28),
                      title: const Text('People You May Know', style: TextStyle(fontSize: 18)),
                      onTap: () {
                        // Determine current userId: login se ya register se
                        String currentUserId = widget.userId ?? user?.id ?? "";

                        context.push(
                          '/people_knows',
                          extra: {
                            'currentUserId': currentUserId,
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add_alt_1, size: 28),
                      title: const Text('Invitation', style: TextStyle(fontSize: 18)),
                      onTap: () {
                        // Determine current userId: login se ya register se
                        String currentUserId = widget.userId ?? user?.id ?? "";

                        context.push(
                          '/invitaion',
                          extra: {
                            'currentUserId': currentUserId,
                          },
                        );
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
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                onTap: () async {
                  // 🔹 Firebase logout (agar Firebase Auth use kar rahe ho)
                  await FirebaseAuth.instance.signOut();

                  // 🔹 SharedPreferences clear karo
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('isLoggedIn');
                  await prefs.remove('userId');
                  // ya fir puri clear karna ho to: await prefs.clear();

                  // 🔹 Login screen pe redirect
                  if (context.mounted) {
                    context.go('/loginscreen');
                  }
                },
              ),

            ],
          ),
        ),
      ),

      //  AppBar with Drawer Menu
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
                  child: Icon(Icons.menu,
                      color: Colors.black87, size: screenHeight * 0.03),
                ),
                SizedBox(width: screenWidth * 0.025),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.055,
                    padding:
                    EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: Colors.grey.shade800,
                            size: screenHeight * 0.025),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Search here",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: screenHeight * 0.016),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Icon(Icons.groups_outlined,
                    color: Colors.black87, size: screenHeight * 0.030),
                SizedBox(width: screenWidth * 0.02),
                Icon(Icons.notifications_none_rounded,

                    color: Colors.black87, size: screenHeight * 0.028),
              ],
            ),
          ),
        ),
      ),

      //  Scrollable Body Content
      body: IndexedStack(
        index: selectedIndex == 4 ? 0 : selectedIndex,
        children: [
          // 0: Home Screen
          SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                    itemCount:UserPost.length,
                    itemBuilder:(context, index){
                     return Userpostcard(post: UserPost[index]) ;
                    },)
              ],

            ),
          ),

          // 1: My Network
          MyNetwork(currentUserId:(widget.userId !=null && widget.userId!.isNotEmpty)
              ?widget.userId!:user?.id??""),

          // 2: QR Scanner
          QrScanner(),
          // 3: Exhibitors Page
           ExhibiterScreen(),

          // 4: (More) — ignore because modal bottom sheet handle karega
          Container(),
        ],
      ),

      //  Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF3F8FE),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF535D97),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'My Network',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF2E356A),
              radius: 18,
              child: Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            label: 'Exhibitors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
