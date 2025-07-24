import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF0F4FD),
              ),
              child:Row(
                crossAxisAlignment:CrossAxisAlignment.start ,
                children: [
                  CircleAvatar(
                    radius:45,
                    backgroundImage:AssetImage('assets/peersgloblelogo.png'),
                  ),
                  Text("Mr.chavda")
                  
                ],
              )
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
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
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: List.generate(
              15,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: Text('Item ${index + 1}')),
                ),
              ),
            ),
          ),
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
