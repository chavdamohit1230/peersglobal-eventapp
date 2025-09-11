import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeopleKnows extends StatefulWidget {
  final String currentUserId;
  const PeopleKnows({super.key, required this.currentUserId});

  @override
  State<PeopleKnows> createState() => _PeopleKnowsState();
}

class _PeopleKnowsState extends State<PeopleKnows> {
  Map<String, String> requestStatus = {}; // userId => status (none/pending/approved/rejected)
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
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
        return {
          "id": doc.id,
          "name": data['name'] ?? '',
          "designation": data['designation'] ?? '',
          "image": data['profileImage'] ?? "https://via.placeholder.com/150",
        };
      }).toList();

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });

      await fetchSentRequests();
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSentRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("requests")
          .where("from", isEqualTo: widget.currentUserId)
          .get();

      for (var doc in snapshot.docs) {
        String toUserId = doc['to'];
        String status = doc['status'] ?? "pending";

        requestStatus[toUserId] = status;

        if (status == "approved") {
          // ✅ remove approved users from list
          users.removeWhere((user) => user["id"] == toUserId);
        }
      }
      setState(() {});
    } catch (e) {
      print("Error fetching sent requests: $e");
    }
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
      appBar: AppBar(title: const Text("People You May Know")),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          final status = requestStatus[user["id"]] ?? "none";

          String buttonText;
          bool isDisabled;

          if (status == "pending") {
            buttonText = "Request Sent";
            isDisabled = true;
          } else if (status == "approved") {
            return const SizedBox.shrink(); // already removed
          } else {
            buttonText = "Connect";
            isDisabled = false;
          }

          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user["image"]),
            ),
            title: Text(
              user["name"],
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            subtitle: Text(
              user["designation"],
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            trailing: ElevatedButton(
              onPressed: isDisabled
                  ? null
                  : () => toggleRequest(user["id"]),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isDisabled ? Colors.grey : Colors.blue,
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
                    userId: user["id"],
                    name: user["name"],
                    designation: user["designation"],
                    imageUrl: user["image"],
                    status: status,
                    onRequestToggle: () => toggleRequest(user["id"]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailView extends StatelessWidget {
  final String userId;
  final String name;
  final String designation;
  final String imageUrl;
  final String status; // none/pending/approved/rejected
  final VoidCallback onRequestToggle;

  const UserDetailView({
    super.key,
    required this.userId,
    required this.name,
    required this.designation,
    required this.imageUrl,
    required this.status,
    required this.onRequestToggle,
  });

  @override
  Widget build(BuildContext context) {
    String currentStatus = status;

    String buttonText;
    bool isDisabled;

    if (currentStatus == "pending") {
      buttonText = "Request Sent";
      isDisabled = true;
    } else if (currentStatus == "approved") {
      buttonText = "Connected";
      isDisabled = true;
    } else {
      buttonText = "Connect";
      isDisabled = false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(name,
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
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(designation,
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
                  _buildInfoRow(Icons.person, "Name", name),
                  const Divider(),
                  _buildInfoRow(Icons.work_outline, "Designation", designation),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isDisabled ? null : onRequestToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isDisabled ? Colors.grey : Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
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
