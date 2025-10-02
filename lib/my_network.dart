import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'modelClass/mynetwork_model.dart';

// -------------------- MyNetwork Screen --------------------
class MyNetwork extends StatefulWidget {
  final String currentUserId;
  const MyNetwork({super.key, required this.currentUserId});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Connections"),
        backgroundColor: const Color(0xFFF0F4FD),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _connectionsStream(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No connections yet"));
          }

          final docs = snapshot.data!;
          final connectedUserIds = docs.map((doc) {
            if (doc['from'] == widget.currentUserId) return doc['to'] as String;
            return doc['from'] as String;
          }).toSet().toList();

          return FutureBuilder<List<Mynetwork>>(
            future: _fetchUsersDetails(connectedUserIds),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!usersSnapshot.hasData || usersSnapshot.data!.isEmpty) {
                return const Center(child: Text("No connections yet"));
              }

              final users = usersSnapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ConnectionListWidget(
                    connection: user,
                    onTap: () => _openUserDetail(context, user),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> _connectionsStream(String currentUserId) {
    final fromStream = FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'approved')
        .where('from', isEqualTo: currentUserId)
        .snapshots();

    final toStream = FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'approved')
        .where('to', isEqualTo: currentUserId)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<QueryDocumentSnapshot>>(
      fromStream,
      toStream,
          (fromSnap, toSnap) => [...fromSnap.docs, ...toSnap.docs],
    );
  }

  Future<List<Mynetwork>> _fetchUsersDetails(List<String> userIds) async {
    List<Mynetwork> users = [];
    for (String userId in userIds) {
      final userDoc =
      await FirebaseFirestore.instance.collection('userregister').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        users.add(Mynetwork(
          id: userDoc.id,
          username: data['name'] ?? "N/A",
          Designnation: data['designation'] ?? "N/A",
          mobile: data['mobile'] ?? "N/A",
          email: data['email'] ?? "N/A",
          companywebsite: data['companywebsite'] ?? "N/A",
          businessLocation: data['businessLocation'] ?? "N/A",
          industry: data['industry'] ?? "N/A",
          contry: data['country'] ?? "N/A",
          city: data['city'] ?? "N/A",
          ImageUrl: data['profileImage'] ?? "https://via.placeholder.com/150",
        ));
      }
    }
    return users;
  }

  void _openUserDetail(BuildContext context, Mynetwork user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(
          mynetwork: user,
          currentUserId: widget.currentUserId,
          onRemove: () async {
            await _removeConnection(user.id!);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _removeConnection(String friendId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'approved')
          .get();

      for (var doc in snapshot.docs) {
        if ((doc['from'] == widget.currentUserId && doc['to'] == friendId) ||
            (doc['from'] == friendId && doc['to'] == widget.currentUserId)) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error removing connection: $e");
    }
  }
}

// -------------------- Connection List Widget --------------------
class ConnectionListWidget extends StatelessWidget {
  final Mynetwork connection;
  final VoidCallback? onTap;

  const ConnectionListWidget({super.key, required this.connection, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity, // full horizontal fill
            color: Colors.white, // no elevation
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    connection.ImageUrl.isNotEmpty
                        ? connection.ImageUrl
                        : "https://via.placeholder.com/150",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        connection.Designnation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.green),
                  onPressed: () =>
                      _openWhatsApp(context, connection.mobile ?? ""),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.grey), // divider
      ],
    );
  }

  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is not available")),
      );
      return;
    }

    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    cleanedNumber = cleanedNumber.replaceFirst(RegExp(r'^0+'), '');
    if (cleanedNumber.length <= 10) cleanedNumber = '91$cleanedNumber';

    final whatsappUrl = "https://wa.me/$cleanedNumber";

    try {
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text("WhatsApp is not installed or number is invalid")),
      );
    }
  }
}

// -------------------- User Detail Screen --------------------
class UserDetailScreen extends StatelessWidget {
  final Mynetwork mynetwork;
  final String currentUserId;
  final Future<void> Function() onRemove;

  const UserDetailScreen({
    super.key,
    required this.mynetwork,
    required this.currentUserId,
    required this.onRemove,
  });

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
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
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
          _buildInfoRow(Icons.call, "Mobile", mynetwork.mobile ?? "N/A"),
          const Divider(),
          _buildInfoRow(Icons.email_outlined, "Email", mynetwork.email ?? "N/A"),
          const Divider(),
          _buildInfoRow(
              Icons.language, "CompanyUrl", mynetwork.companywebsite ?? "N/A"),
          const Divider(),
          _buildInfoRow(Icons.location_history, "BusinessLocation",
              mynetwork.businessLocation ?? "N/A"),
          const Divider(),
          _buildInfoRow(Icons.business, "Industry", mynetwork.industry ?? "N/A"),
          const Divider(),
          _buildInfoRow(Icons.map, "Country", mynetwork.contry ?? "N/A"),
          const Divider(),
          _buildInfoRow(
              Icons.location_city_sharp, "City", mynetwork.city ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Remove Connection
        ElevatedButton(
          onPressed: () async {
            await onRemove();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Connection removed")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Remove Connection",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        // WhatsApp Button
        ElevatedButton(
          onPressed: () => _openWhatsApp(context, mynetwork.mobile ?? ""),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Message",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is not available")),
      );
      return;
    }

    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    cleanedNumber = cleanedNumber.replaceFirst(RegExp(r'^0+'), '');
    if (cleanedNumber.length <= 10) cleanedNumber = '91$cleanedNumber';

    final whatsappUrl = "https://wa.me/$cleanedNumber";

    try {
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text("WhatsApp is not installed or number is invalid")),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child:
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Colors.blueGrey, size: 22),
        const SizedBox(width: 12),
        SizedBox(
            width: 120,
            child: Text("$title:",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15))),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 15, color: Colors.black87))),
      ]),
    );
  }
}
