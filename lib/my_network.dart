import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/widgets/ConnectionListWidget.dart';
import 'modelClass/mynetwork_model.dart';

class MyNetwork extends StatefulWidget {
  final String currentUserId;
  const MyNetwork({super.key, required this.currentUserId});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  final List<Mynetwork> connection = [
    Mynetwork(
      id: "4",
      username: "Aman",
      Designnation: "Flutter Dev",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "5",
      username: "Ravi",
      Designnation: "Backend Dev",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "6",
      username: "Pooja",
      Designnation: "Designer",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "7",
      username: "Sneha",
      Designnation: "Tester",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: _buildSection(
          context,
          title: "Connections",
          list: connection,
          itemBuilder: (m) => GestureDetector(
            onTap: () => _openUserDetail(m),
            child: ConnectionListWidget(connection: m),
          ),
        ),
      ),
    );
  }

  // 🔹 Open User Detail Screen
  void _openUserDetail(Mynetwork user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(
          mynetwork: user,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  // 🔹 Dummy Section Widget
  Widget _buildSection(BuildContext context,
      {required String title,
        required List<Mynetwork> list,
        required Widget Function(Mynetwork) itemBuilder}) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F8FE),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (list.length > 3)
              const Text("View All",
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
          ]),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length > 3 ? 3 : list.length,
            itemBuilder: (context, index) => itemBuilder(list[index]),
          ),
        ],
      ),
    );
  }
}

// 🔹 User Detail Screen (Same Design)
class UserDetailScreen extends StatelessWidget {
  final Mynetwork mynetwork;
  final String currentUserId;
  const UserDetailScreen(
      {super.key, required this.mynetwork, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(mynetwork.username,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDCEAF4), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      mynetwork.ImageUrl.isNotEmpty
                          ? mynetwork.ImageUrl
                          : "https://via.placeholder.com/150",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(mynetwork.username,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(mynetwork.Designnation,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, "Name", mynetwork.username),
                  const Divider(),
                  _buildInfoRow(
                      Icons.work_outline, "Designation", mynetwork.Designnation),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Colors.blueGrey, size: 22),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text("$title:",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Expanded(
            child: Text(value,
                style:
                const TextStyle(fontSize: 15, color: Colors.black87))),
      ]),
    );
  }
}
