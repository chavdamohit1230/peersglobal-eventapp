import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shimmer/shimmer.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

// Helper function to capitalize the first letter of each word
String capitalizeWords(String text) {
  if (text.isEmpty) return '';
  return text.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class Meeting extends StatefulWidget {
  final String currentUserId;
  const Meeting({super.key, required this.currentUserId});

  @override
  State<Meeting> createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> with SingleTickerProviderStateMixin {
  late final String _cleanedCurrentUserId;
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cleanedCurrentUserId = _getIdFromPath(widget.currentUserId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔹 Helper: Extract last part of Firestore path (userId)
  String _getIdFromPath(String fullPath) {
    if (fullPath.contains("/")) {
      return fullPath.split("/").last;
    }
    return fullPath;
  }

  // 🔹 Fetch approved connections and their details
  Stream<List<Map<String, dynamic>>> _getConnectionsStream() {
    return _firestore
        .collection("requests")
        .where("status", isEqualTo: "approved")
        .snapshots()
        .asyncMap((snapshot) async {
      final connectedUserIds = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final fromId = _getIdFromPath(data["from"]);
        final toId = _getIdFromPath(data["to"]);

        if (fromId == _cleanedCurrentUserId || toId == _cleanedCurrentUserId) {
          connectedUserIds.add(fromId == _cleanedCurrentUserId ? toId : fromId);
        }
      }

      if (connectedUserIds.isEmpty) return [];

      final userDocs = await _firestore
          .collection("userregister")
          .where(FieldPath.documentId, whereIn: connectedUserIds.toList())
          .get();

      return userDocs.docs.map((doc) {
        final userData = doc.data();
        return {
          "id": doc.id,
          "name": (userData["name"] as String?) ?? "",
          "designation": (userData["designation"] as String?) ?? "",
          "photoUrl": (userData["photoUrl"] as String?) ?? "",
        };
      }).toList();
    });
  }

  // 🔹 Fetch meetings for current user (with user names)
  Stream<List<Map<String, dynamic>>> _getMeetingsStream() {
    return _firestore
        .collection("usermeetings")
        .snapshots()
        .asyncMap((snapshot) async {
      final relevantMeetingDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final hostId = _getIdFromPath(data["host_id"]);
        final participantId = _getIdFromPath(data["participant_id"]);
        return hostId == _cleanedCurrentUserId || participantId == _cleanedCurrentUserId;
      }).toList();

      if (relevantMeetingDocs.isEmpty) return [];

      final allUserIds = <String>{};
      for (var doc in relevantMeetingDocs) {
        final data = doc.data();
        allUserIds.add(_getIdFromPath(data["host_id"]));
        allUserIds.add(_getIdFromPath(data["participant_id"]));
      }

      final userDocs = await _firestore
          .collection("userregister")
          .where(FieldPath.documentId, whereIn: allUserIds.toList())
          .get();

      final usersMap = {for (var doc in userDocs.docs) doc.id: doc.data()};

      return relevantMeetingDocs.map((doc) {
        final data = doc.data();
        final hostId = _getIdFromPath(data["host_id"]);
        final participantId = _getIdFromPath(data["participant_id"]);

        return {
          "id": doc.id,
          "hostId": hostId,
          "hostName": (usersMap[hostId]?["name"] as String?) ?? "Unknown",
          "participantId": participantId,
          "participantName": (usersMap[participantId]?["name"] as String?) ?? "Unknown",
          "status": (data["status"] as String?) ?? "pending",
          "meeting_date": (data["meeting_date"] as String?) ?? "",
          "meeting_time": (data["meeting_time"] as String?) ?? "",
          "purpose": (data["purpose"] as String?) ?? "",
          "meeting_link": (data["meeting_link"] as String?) ?? "",
          "timestamp": data["timestamp"] ?? Timestamp.now(),
        };
      }).toList();
    });
  }

  // 🔹 Open schedule dialog with a professional look
  void _openScheduleDialog(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ScheduleMeetingBottomSheet(
          user: user,
          currentUserId: _cleanedCurrentUserId,
        );
      },
    );
  }

  // 🔹 Update meeting status (Approve / Reject)
  void _updateMeetingStatus(String meetingId, String status) async {
    try {
      await _firestore.collection("usermeetings").doc(meetingId).update({
        "status": status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Meeting request $status."),
          backgroundColor: status == "approved" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
        ),
      );
    }
  }

  // 🔹 Cancel a meeting
  void _cancelMeeting(String meetingId) async {
    try {
      await _firestore.collection("usermeetings").doc(meetingId).update({
        "status": "cancelled",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Meeting cancelled."),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to cancel meeting: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Appcolor.backgroundLight,
      appBar: AppBar(
        title: const Text("Meetings"),
        backgroundColor:Appcolor.backgroundLight,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Connections"),
            Tab(text: "Meetings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsTab(),
          _buildMeetingsTab(),
        ],
      ),
    );
  }

  Widget _buildConnectionsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getConnectionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildConnectionsShimmer();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottieanimation/mentalTherapy.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No Connections Found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        final connections = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: connections.length,
          itemBuilder: (context, index) {
            final user = connections[index];
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildMeetingsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getMeetingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildMeetingsShimmer();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottieanimation/editedsuccess.json', // Path to your animation file
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No Meetings Scheduled",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

// ... the rest of your code ...

        final meetings = snapshot.data!;
        return ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meet = meetings[index];
            final isHost = meet["hostId"] == _cleanedCurrentUserId;
            final otherPerson = isHost ? meet["participantName"] : meet["hostName"];
            final statusColor = _getStatusColor(meet["status"]);
            final showCancelButton = meet["status"] == "pending" || meet["status"] == "approved";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text("With: ${capitalizeWords(otherPerson)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Purpose: ${meet["purpose"]}"),
                      Text("Date: ${meet["meeting_date"]} | Time: ${meet["meeting_time"]}"),
                      Row(
                        children: [
                          const Text("Status: "),
                          Text(
                            capitalizeWords(meet["status"]),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (meet["status"] == "approved" && meet["meeting_link"].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () => launchUrlString(meet["meeting_link"]),
                            icon: const Icon(Icons.link, size: 18),
                            label: const Text("Join Meeting"),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show Approve/Reject buttons only if current user is participant and status is pending
                      if (!isHost && meet["status"] == "pending")
                        ...[
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateMeetingStatus(meet["id"], "approved"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _updateMeetingStatus(meet["id"], "rejected"),
                          ),
                        ],
                      // Show Cancel button if status is pending or approved
                      if (showCancelButton)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () => _cancelMeeting(meet["id"]),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "cancelled":
        return Colors.grey;
      case "pending":
      default:
        return Colors.orange;
    }
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openScheduleDialog(user),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFF0F4FD), Colors.white], // Using colors from your design
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: user["photoUrl"].isNotEmpty
                      ? NetworkImage(user["photoUrl"])
                      : const AssetImage("assets/placeholder.png") as ImageProvider,
                ),
                Text(
                  capitalizeWords(user["name"]),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  capitalizeWords(user["designation"]),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                ElevatedButton(
                  onPressed: () => _openScheduleDialog(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    "Schedule",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer effect for connections grid
  Widget _buildConnectionsShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                    ),
                    Container(height: 10, width: 80, color: Colors.white),
                    Container(height: 10, width: 60, color: Colors.white),
                    Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Shimmer effect for meetings list
  Widget _buildMeetingsShimmer() {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Container(height: 12, width: 150, color: Colors.white),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(height: 10, width: 200, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 10, width: 180, color: Colors.white),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(height: 10, width: 50, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 10, width: 50, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------- Schedule Meeting Bottom Sheet --------------------
class ScheduleMeetingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUserId;

  const ScheduleMeetingBottomSheet({
    super.key,
    required this.user,
    required this.currentUserId,
  });

  @override
  _ScheduleMeetingBottomSheetState createState() => _ScheduleMeetingBottomSheetState();
}

class _ScheduleMeetingBottomSheetState extends State<ScheduleMeetingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String purpose = "";
  String meetingLink = "";
  bool isSendingRequest = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Schedule a Meeting with ${capitalizeWords(widget.user["name"])}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(selectedDate!)
                      : "Select Date",
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : "Select Time",
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              const Divider(),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Purpose / Note",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                onChanged: (value) => purpose = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Meeting Link (Optional)",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (value) => meetingLink = value,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedDate != null && selectedTime != null && !isSendingRequest)
                      ? _sendRequest
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSendingRequest
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Send Request",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSendingRequest = true);
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance.collection("usermeetings").add({
        "host_id": widget.currentUserId,
        "participant_id": widget.user["id"],
        "status": "pending",
        "meeting_date": formattedDate,
        "meeting_time": formattedTime,
        "purpose": purpose,
        "meeting_link": meetingLink,
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent ✅")),
        );
      }
    }
  }
}