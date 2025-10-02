import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peersglobleeventapp/modelClass/mynetwork_model.dart';

class PeopleKnows extends StatefulWidget {
  final String currentUserId;
  const PeopleKnows({super.key, required this.currentUserId});

  @override
  State<PeopleKnows> createState() => _PeopleKnowsState();
}

class _PeopleKnowsState extends State<PeopleKnows> {
  Map<String, String> requestStatus = {}; // userId => status
  bool isLoading = true;
  List<Mynetwork> users = [];

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    listenToRequests(); // ✅ real-time listener
  }

  Future<void> fetchUsers() async {
    try {
      final currentUserDocId = widget.currentUserId.contains("/")
          ? widget.currentUserId.split("/").last
          : widget.currentUserId;

      final snapshot =
      await FirebaseFirestore.instance.collection("userregister").get();

      final fetchedUsers = snapshot.docs
          .where((doc) => doc.id != currentUserDocId)
          .map((doc) {
        final data = doc.data();
        return Mynetwork(
          id: doc.id,
          username: data['name'] ?? '',
          Designnation: data['designation'] ?? '',
          ImageUrl: data['photoUrl'] ?? "https://via.placeholder.com/150",
          email: data['email'] ?? '',
          mobile: data['mobile'] ?? '',
          organization: data['organization'] ?? 'N/A',
          businessLocation: data['businessLocation'] ?? '',
          companywebsite: data['companywebsite'] ?? '',
          industry: data['industry'] ?? '',
          contry: data['country'] ?? '',
          city: data['city'] ?? '',
          aboutme: data['aboutme'] ?? '',
        );
      }).toList();

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  /// ✅ Real-time listener
  void listenToRequests() {
    FirebaseFirestore.instance
        .collection("requests")
        .where("from", isEqualTo: widget.currentUserId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        requestStatus.clear();
        for (var doc in snapshot.docs) {
          String toUserId = doc['to'];
          String status = doc['status'] ?? "pending";
          requestStatus[toUserId] = status;
        }
        // ✅ approved users ko list se turant hata do
        users.removeWhere((u) => requestStatus[u.id] == "approved");
      });
    });
  }

  Future<void> toggleRequest(String targetUserId) async {
    try {
      String status = requestStatus[targetUserId] ?? "none";

      if (status == "pending") {
        // Cancel request
        final snapshot = await FirebaseFirestore.instance
            .collection("requests")
            .where("from", isEqualTo: widget.currentUserId)
            .where("to", isEqualTo: targetUserId)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          requestStatus[targetUserId] = "none";
        });
      } else {
        // Send request
        await FirebaseFirestore.instance.collection("requests").add({
          "from": widget.currentUserId,
          "to": targetUserId,
          "status": "pending",
          "timestamp": FieldValue.serverTimestamp(),
        });

        setState(() {
          requestStatus[targetUserId] = "pending";
        });
      }
    } catch (e) {
      print("Error toggling request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("People You May Know"),
        backgroundColor: const Color(0xFFF0F4FD),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          final status = requestStatus[user.id ?? ""] ?? "none";

          // ✅ Agar approved hai to skip (already remove ho raha hai listener me)
          if (status == "approved") return const SizedBox();

          String buttonText;
          Color buttonColor;

          if (status == "pending") {
            buttonText = "Cancel Request";
            buttonColor = Colors.blue;
          } else {
            buttonText = "Connect";
            buttonColor = Colors.blue;
          }

          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.ImageUrl),
            ),
            title: Text(
              capitalize(user.username),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalize(user.organization),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  capitalize(user.Designnation),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => toggleRequest(user.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style:
                const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailView(
                    user: user,
                    status: status,
                    onRequestToggle: () => toggleRequest(user.id!),
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          );
        },
      ),
    );
  }
}


class UserDetailView extends StatefulWidget {
  final Mynetwork user;
  final String status;
  final Future<void> Function() onRequestToggle;

  const UserDetailView({
    super.key,
    required this.user,
    required this.status,
    required this.onRequestToggle,
  });

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
  }

  Future<void> handleRequestToggle() async {
    await widget.onRequestToggle();
    setState(() {
      currentStatus = (currentStatus == "pending") ? "none" : "pending";
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonText;
    Color buttonColor;

    if (currentStatus == "pending") {
      buttonText = "Cancel Request";
      buttonColor = Colors.blue;
    } else {
      buttonText = "Connect";
      buttonColor = Colors.blue;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(widget.user.username,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    backgroundImage: NetworkImage(widget.user.ImageUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.user.username,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(widget.user.Designnation,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                  _buildInfoRow(Icons.person, "Name", widget.user.username),
                  const Divider(),
                  _buildInfoRow(Icons.work_outline, "Designation",
                      widget.user.Designnation),
                  const Divider(),
                  _buildInfoRow(
                      Icons.phone, "Mobile", widget.user.mobile ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.email_outlined, "Email",
                      widget.user.email ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.language, "CompanyUrl",
                      widget.user.companywebsite ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.location_history, "BusinessLocation",
                      widget.user.businessLocation ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.business_sharp, "Industry",
                      widget.user.industry ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(
                      Icons.map, "Country", widget.user.contry ?? "N/A"),
                  const Divider(),
                  _buildInfoRow(Icons.location_city_sharp, "City",
                      widget.user.city ?? "N/A"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: handleRequestToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
          child: Text("$title:",
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Expanded(
            child: Text(value,
                style:
                const TextStyle(fontSize: 15, color: Colors.black87))),
      ]),
    );
  }
}
