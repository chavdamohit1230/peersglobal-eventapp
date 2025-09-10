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
    return Scaffold(
      appBar: AppBar(title: const Text("Invitations")),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .where("to", isEqualTo: widget.currentUserId)
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final fromUserId = req['from'];
              final docId = req.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("userregister")
                    .doc(fromUserId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  final userData = userSnap.data!;
                  final profileImage = userData['profileImage'] ??
                      "https://via.placeholder.com/150";

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    title: Text(userData['name'] ?? "No Name"),
                    subtitle: Text(userData['designation'] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("requests")
                                .doc(docId)
                                .update({"status": "approved"});
                          },
                          child: const Text("Accept"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("requests")
                                .doc(docId)
                                .update({"status": "rejected"});
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
