import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Meeting extends StatefulWidget {
  final String currentUserId;
  const Meeting({super.key, required this.currentUserId});

  @override
  State<Meeting> createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Fetch approved connections
  Stream<List<Map<String, dynamic>>> getConnectionsStream() async* {
    await for (var requestSnap in _firestore
        .collection("requests")
        .where("status", isEqualTo: "approved")
        .snapshots()) {
      List<Map<String, dynamic>> connections = [];
      for (var doc in requestSnap.docs) {
        final data = doc.data();
        String friendId = "";
        if (data["from"] == widget.currentUserId) {
          friendId = data["to"];
        } else if (data["to"] == widget.currentUserId) {
          friendId = data["from"];
        } else {
          continue;
        }

        final userDoc =
        await _firestore.collection("userregister").doc(friendId).get();
        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
        connections.add({
          "id": friendId,
          "name": userData["name"] ?? "",
          "designation": userData["designation"] ?? "",
          "photoUrl": userData["photoUrl"] ?? "",
        });
      }
      yield connections;
    }
  }

  // 🔹 Fetch meetings for current user
  Stream<List<Map<String, dynamic>>> getMeetingsStream() async* {
    await for (var snap in _firestore.collection("meetings").snapshots()) {
      List<Map<String, dynamic>> meetings = [];
      for (var doc in snap.docs) {
        final data = doc.data();
        if (data["hostId"] == widget.currentUserId ||
            data["participantId"] == widget.currentUserId) {
          meetings.add({
            "id": doc.id,
            "hostId": data["hostId"],
            "participantId": data["participantId"],
            "status": data["status"] ?? "pending",
            "date": data["date"] ?? "",
            "time": data["time"] ?? "",
            "purpose": data["purpose"] ?? "",
            "timestamp": data["timestamp"] ?? Timestamp.now(),
          });
        }
      }
      yield meetings;
    }
  }

  // 🔹 Open schedule dialog
  void openScheduleDialog(Map<String, dynamic> user) {
    final _formKey = GlobalKey<FormState>();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String purpose = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Schedule Meeting with ${user["name"]}"),
        content: StatefulBuilder(builder: (context, setState) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    selectedDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDate!)
                        : "Select Date",
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : "Select Time",
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null) setState(() => selectedTime = time);
                  },
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: "Purpose / Note"),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
                  onChanged: (value) => purpose = value,
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: (selectedDate != null && selectedTime != null)
                ? () async {
              if (_formKey.currentState!.validate()) {
                final formattedDate =
                DateFormat('yyyy-MM-dd').format(selectedDate!);
                final formattedTime =
                    "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                await _firestore.collection("meetings").add({
                  "hostId": widget.currentUserId,
                  "participantId": user["id"],
                  "status": "pending",
                  "date": formattedDate,
                  "time": formattedTime,
                  "purpose": purpose,
                  "timestamp": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Request Sent ✅")));
              }
            }
                : null, // disabled if date/time null
            child: const Text("Send Request"),
          )
        ],
      ),
    );
  }

  // 🔹 Accept / Reject meeting
  void updateMeetingStatus(String meetingId, String status) async {
    await _firestore.collection("meetings").doc(meetingId).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meetings")),
      body: Column(
        children: [
          // Connections List
          Expanded(
            flex: 2,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getConnectionsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("❌ No Connections Found"));
                }
                final connections = snapshot.data!;
                return ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final user = connections[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user["photoUrl"].isNotEmpty
                              ? NetworkImage(user["photoUrl"])
                              : null,
                          child: user["photoUrl"].isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user["name"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(user["designation"],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                        trailing: ElevatedButton(
                          onPressed: () => openScheduleDialog(user),
                          child: const Text("Schedule"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Meetings List
          Expanded(
            flex: 2,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMeetingsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Meetings Scheduled"));
                }
                final meetings = snapshot.data!;
                return ListView.builder(
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meet = meetings[index];
                    bool isHost =
                    meet["hostId"] == widget.currentUserId ? true : false;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                            "With: ${isHost ? meet["participantId"] : meet["hostId"]}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Status: ${meet["status"]} | ${meet["date"]} ${meet["time"]}"),
                            Text("Purpose: ${meet["purpose"]}"),
                          ],
                        ),
                        trailing: !isHost && meet["status"] == "pending"
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () => updateMeetingStatus(
                                    meet["id"], "approved")),
                            IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () => updateMeetingStatus(
                                    meet["id"], "rejected")),
                          ],
                        )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
