import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/widgets/postcard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  final List<Map<String, dynamic>> posts = List.generate(5, (index) => {
    'companyName': 'AppsRow Solutions LLP',
    'boothInfo': 'Booth S-11 | Meet the Best Webflow Agency.',
    'timeAgo': '${index + 1} months ago',
    'postText':
    '🎉 Fly to Win: A Contest Full of Excitement! 🎉\nThe Fly to Win Contest at our booth brought fun and engagement.',
    'imageUrl': [
      'https://images.unsplash.com/photo-1603791440384-56cd371ee9a7',
      'https://images.unsplash.com/photo-1522199755839-a2bacb67c546',
      'https://images.unsplash.com/photo-1522199755839-a2bacb67c546',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d',
      'https://images.unsplash.com/photo-1531482615713-2afd69097998',
    ][index],
    'likes': 20 + index,
    'comments': 2 + index,
    'shares': 5 + index,
  });

  double safeFontSize(double size, double min, double max) {
    return size.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      drawer: Drawer(
        backgroundColor:Color(0xFFF0F4FD),
        child: SafeArea(
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
                      "Chavda Mohit",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: safeFontSize(
                            MediaQuery.of(context).size.width * 0.080, 18, 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                 Text(
                      "Co-Founder of Sarda Dairy Farm",
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
                Divider(
                  thickness:2,
                  indent:20,
                  endIndent:20,
                ),
              // Navigation Items
              ListTile(
                leading: const Icon(Icons.home,size:28,),
                title: const Text('Home',style:TextStyle(fontSize:18),),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person,size:28),
                title: const Text('Profile',style:TextStyle(fontSize:18)),
                onTap: () => Navigator.pop(context),
              ),

              ListTile(
                leading: const Icon(Icons.people_alt_outlined,size:28),
                title: const Text('Meeting',style:TextStyle(fontSize:18)),
                onTap: () => Navigator.pop(context),
              ),

              ListTile(
                leading: const Icon(Icons.settings,size:28),
                title: const Text('Settings',style:TextStyle(fontSize:18)),
                onTap: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
          child: Column(
            children: posts.map((post) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical:0),
                child: LinkedInPostCard(
                  companyName: post['companyName'],
                  boothInfo: post['boothInfo'],
                  timeAgo: post['timeAgo'],
                  postText: post['postText'],
                  imageUrl: post['imageUrl'],
                  likes: post['likes'],
                  comments: post['comments'],
                  shares: post['shares'],
                ),
              );
            }).toList(),
          ),
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
