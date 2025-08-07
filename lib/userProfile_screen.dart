import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Container(

            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 41,
                  backgroundImage: NetworkImage(
                      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"), // Replace with real image
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Mohit Chavda",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Co-Founder of Sarda dairy from a alau road botad",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "ATTENDEE | Business Attendee",
                        style: TextStyle(fontSize: 16),
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
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Posts"),
            ],
          ),

          // 📄 TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: Text("Overview Content")),
                Center(child: Text("Posts Content")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
