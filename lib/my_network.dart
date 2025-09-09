import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:peersglobleeventapp/widgets/ConnectionListWidget.dart';
import 'package:peersglobleeventapp/widgets/Peopleknows_list_widgets.dart';
import 'package:peersglobleeventapp/widgets/my_network_widget.dart';
import 'modelClass/mynetwork_model.dart';

class MyNetwork extends StatefulWidget {
  final String currentUserId;
  const MyNetwork({super.key, required this.currentUserId});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  final List<Mynetwork> networklist = [
    Mynetwork(
      id: "1",
      username: "ABC",
      Designnation: "Flutter Dev",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "2",
      username: "XYZ",
      Designnation: "Flutter Dev",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "3",
      username: "Demo",
      Designnation: "Flutter Dev",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
  ];

  final List<Mynetwork> connection = [
    Mynetwork(
      id: "4",
      username: "Aman",
      Designnation: "Flutter Dev",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "5",
      username: "Ravi",
      Designnation: "Backend Dev",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "6",
      username: "Pooja",
      Designnation: "Designer",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
    Mynetwork(
      id: "7",
      username: "Sneha",
      Designnation: "Tester",
      ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Invitations
            _buildSection(
              context,
              title: "Invitations",
              list: networklist,
              itemBuilder: (m) => GestureDetector(
                onTap: () => _openUserDetail(m),
                child: MyNetworkWidget(mynetwork: m),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // 🔹 People You May Know (Firestore)
            _buildFirestoreSection(context, title: "People You May Know"),
            SizedBox(height: screenHeight * 0.01),

            // 🔹 Connections
            _buildSection(
              context,
              title: "Connections",
              list: connection,
              itemBuilder: (m) => GestureDetector(
                onTap: () => _openUserDetail(m),
                child: ConnectionListWidget(connection: m),
              ),
            ),
          ],
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

  // 🔹 Firestore Section with Shimmer
  Widget _buildFirestoreSection(BuildContext context, {required String title}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("userregister").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerPlaceholder();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No users found", style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        // 🔹 Remove current user
        final docs = snapshot.data!.docs.where((doc) => doc.id != widget.currentUserId).toList();

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No other users found", style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        return Container(
          width: double.infinity,
          color: const Color(0xFFF3F8FE),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (docs.length > 3)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewAllFirestoreScreen(title: title, docs: docs),
                          ),
                        );
                      },
                      child: const Text("View All", style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length > 3 ? 3 : docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final user = Mynetwork(
                    id: docs[index].id,
                    username: data["name"] ?? "N/A",
                    aboutme: data["aboutme"] ?? "N/A",
                    Designnation: data["designation"] ?? "N/A",
                    email: data["email"] ?? "N/A",
                    mobile: data["mobile"] ?? "N/A",
                    businessLocation: data["businessLocation"] ?? "N/A",
                    industry: data["industry"] ?? "N/A",
                    organization: data["organization"] ?? "N/A",
                    companywebsite: data["companywebsite"] ?? "N/A",
                    purposeOfAttending: data["purposeOfAttending"] ?? "N/A",
                    ImageUrl: data["imageurl"] ??
                        "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
                  );
                  return GestureDetector(
                    onTap: () => _openUserDetail(user),
                    child: PeopleknowsListWidgets(peopleknows: user),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F8FE),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(width: 150, height: 20, color: Colors.white),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Row(
                  children: [
                    CircleAvatar(radius: 25, backgroundColor: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(height: 12, width: 100, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dummy Section Widget
  Widget _buildSection(BuildContext context,
      {required String title, required List<Mynetwork> list, required Widget Function(Mynetwork) itemBuilder}) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F8FE),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (list.length > 3)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAllScreen(title: title, profiles: list, itemBuilder: itemBuilder),
                    ),
                  );
                },
                child: const Text("View All", style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
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

// 🔹 User Detail Screen with Request Button
class UserDetailScreen extends StatelessWidget {
  final Mynetwork mynetwork;
  final String currentUserId;
  const UserDetailScreen({super.key, required this.mynetwork, required this.currentUserId});

  Future<void> _sendRequest(BuildContext context) async {
    try {
      // check already sent or not
      final check = await FirebaseFirestore.instance
          .collection("requests")
          .where("fromUserId", isEqualTo: currentUserId)
          .where("toUserId", isEqualTo: mynetwork.id)
          .get();

      if (check.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request already sent!"), backgroundColor: Colors.orange),
        );
        return;
      }

      await FirebaseFirestore.instance.collection("requests").add({
        "fromUserId": currentUserId,
        "toUserId": mynetwork.id,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection request sent!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(mynetwork.username,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
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
                    backgroundImage: NetworkImage(
                      mynetwork.ImageUrl.isNotEmpty ? mynetwork.ImageUrl : "https://via.placeholder.com/150",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(mynetwork.username,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(mynetwork.Designnation,
                      style: const TextStyle(fontSize: 16, color: Colors.black54, fontStyle: FontStyle.italic)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, "Name", mynetwork.username),
                  const Divider(),
                  _buildInfoRow(Icons.work_outline, "Designation", mynetwork.Designnation),
                  const Divider(),
                  _buildInfoRow(Icons.info_outline, "About Me", mynetwork.aboutme ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.email_outlined, "Email", mynetwork.email ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.phone, "Mobile", mynetwork.mobile ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.apartment, "Organization", mynetwork.organization ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.location_on_outlined, "Business Location", mynetwork.businessLocation ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.language, "Website", mynetwork.companywebsite ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.category_outlined, "Industry", mynetwork.industry ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.flag_outlined, "Purpose", mynetwork.purposeOfAttending ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendRequest(context),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text("Connect"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
          child: Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87))),
      ]),
    );
  }
}

// 🔹 View All Firestore
class ViewAllFirestoreScreen extends StatelessWidget {
  final String title;
  final List<QueryDocumentSnapshot> docs;

  const ViewAllFirestoreScreen({super.key, required this.title, required this.docs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final user = Mynetwork(
            id: docs[index].id,
            username: data["name"] ?? "N/A",
            Designnation: data["designation"] ?? "N/A",
            ImageUrl: data["imageurl"] ?? "https://via.placeholder.com/150",
          );
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailScreen(mynetwork: user, currentUserId: "CURRENT_USER_ID"),
                ),
              );
            },
            child: PeopleknowsListWidgets(peopleknows: user),
          );
        },
      ),
    );
  }
}

// 🔹 View All Dummy
class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Mynetwork> profiles;
  final Widget Function(Mynetwork) itemBuilder;

  const ViewAllScreen({super.key, required this.title, required this.profiles, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(itemCount: profiles.length, itemBuilder: (context, index) => itemBuilder(profiles[index])),
    );
  }
}
