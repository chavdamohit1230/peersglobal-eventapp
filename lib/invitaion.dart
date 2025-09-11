import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invitaion extends StatefulWidget {
  final String currentUserId;
  const Invitaion({super.key, required this.currentUserId});

  @override
  State<Invitaion> createState() => _InvitaionState();
}

class _InvitaionState extends State<Invitaion> {
  @override
  Widget build(BuildContext context) {
    print("📌 CurrentUserId => ${widget.currentUserId}");

    return Scaffold(
      appBar: AppBar(title: const Text("Invitations")),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .where("to", isEqualTo: widget.currentUserId.split("/").last)
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          print("📌 Total Requests Found => ${snapshot.data?.docs.length}");

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final fromUserId = req['from'].toString().split("/").last;
              final docId = req.id;

              print("📌 Request $index => ${req.data()} | fromUserId: $fromUserId");

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("userregister")
                    .doc(fromUserId)
                    .get(),
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading user..."),
                    );
                  }

                  if (!userSnap.hasData || !(userSnap.data?.exists ?? false)) {
                    return const ListTile(
                      title: Text("User not found ❌"),
                    );
                  }

                  // ✅ Safe null handling
                  final doc = userSnap.data;
                  final data = doc?.data() as Map<String, dynamic>? ?? {};

                  final profileImage =
                      data['profileImage'] ?? "https://via.placeholder.com/150";
                  final name = data['name'] ?? "No Name";
                  final designation = data['designation'] ?? "";

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    title: Text(name),
                    subtitle: Text(designation),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("requests")
                                .doc(docId)
                                .update({"status": "approved"});
                            print("✅ Request $docId approved");
                          },
                          child: const Text("Accept"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("requests")
                                .doc(docId)
                                .update({"status": "rejected"});
                            print("❌ Request $docId rejected");
                          },
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
