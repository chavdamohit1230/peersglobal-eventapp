import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peersglobleeventapp/widgets/ConnectionListWidget.dart';
import 'modelClass/mynetwork_model.dart';

class MyNetwork extends StatefulWidget {
  final String currentUserId;
  const MyNetwork({super.key, required this.currentUserId});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  List<Mynetwork> connections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConnections();
  }

  Future<void> fetchConnections() async {
    try {
      // ✅ Get approved requests
      final snapshot = await FirebaseFirestore.instance
          .collection("requests")
          .where("status", isEqualTo: "approved")
          .where("from", isEqualTo: widget.currentUserId)
          .get();

      final snapshot2 = await FirebaseFirestore.instance
          .collection("requests")
          .where("status", isEqualTo: "approved")
          .where("to", isEqualTo: widget.currentUserId)
          .get();

      List<String> connectedUserIds = [];

      // Collect "to" users where I am the sender
      connectedUserIds.addAll(snapshot.docs.map((doc) => doc['to'] as String));

      // Collect "from" users where I am the receiver
      connectedUserIds.addAll(snapshot2.docs.map((doc) => doc['from'] as String));

      // ✅ Now fetch user details
      List<Mynetwork> fetchedConnections = [];
      for (String userId in connectedUserIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection("userregister")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          fetchedConnections.add(Mynetwork(
            id: userDoc.id,
            username: data['name'] ?? "N/A",
            Designnation: data['designation'] ?? "N/A",
            mobile:data['mobile']?? "N/A",
            email:data['email']?? "N/A",
            companywebsite:data['companywebsite']?? "N/A",
            businessLocation:data['businessLocation']?? "N/A",
            industry:data['industry']?? "N/A",
            contry:data['country']?? "N/A",
            city:data['city']?? "N/A",
            ImageUrl: data['profileImage'] ?? "https://via.placeholder.com/150",
          ));
        }
      }

      setState(() {
        connections = fetchedConnections;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching connections: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("My Connections"),backgroundColor:Color(0xFFF0F4FD),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : connections.isEmpty
          ? const Center(child: Text("No connections yet"))
          : ListView.builder(
        itemCount: connections.length,
        itemBuilder: (context, index) {
          final user = connections[index];
          return GestureDetector(
            onTap: () => _openUserDetail(user),
            child: ConnectionListWidget(connection: user),
          );
        },
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
}

// 🔹 User Detail Screen (Same as before)
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
                  _buildInfoRow(Icons.work_outline, "Designation",
                      mynetwork.Designnation),
                  const Divider(),
                  _buildInfoRow(Icons.call, "Mobile",
                      mynetwork.mobile ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.email_outlined, "Email",
                      mynetwork.email ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.language, "CompanyUrl",
                      mynetwork.companywebsite ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.location_history, "BusinessLocation",
                      mynetwork.businessLocation ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.business, "Industry",
                      mynetwork.industry?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.map, "Country",
                      mynetwork.contry?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.location_city_sharp, "City",
                      mynetwork.city?? "N/A"),
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
