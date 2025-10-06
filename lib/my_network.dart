import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

// Helper function to capitalize the first letter of each word
String capitalizeWords(String text) {
  if (text == null || text.isEmpty) {
    return '';
  }
  return text.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class Mynetwork {
  final String id;
  final String username;
  final String Designnation;
  final String mobile;
  final String email;
  final String companywebsite;
  final String businessLocation;
  final String industry;
  final String contry;
  final String city;
  final String photoUrl;

  Mynetwork({
    required this.id,
    required this.username,
    required this.Designnation,
    required this.mobile,
    required this.email,
    required this.companywebsite,
    required this.businessLocation,
    required this.industry,
    required this.contry,
    required this.city,
    required this.photoUrl,
  });
}

// -------------------- MyNetwork Screen --------------------
class MyNetwork extends StatefulWidget {
  final String currentUserId;
  const MyNetwork({super.key, required this.currentUserId});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  late final String _cleanedCurrentUserId;

  @override
  void initState() {
    super.initState();
    _cleanedCurrentUserId = _getIdFromPath(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    print("Original User ID: ${widget.currentUserId}");
    print("Cleaned User ID: $_cleanedCurrentUserId");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Connections"),
        backgroundColor: const Color(0xFFF0F4FD),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _connectionsStream(_cleanedCurrentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No connections yet"));
          }

          final docs = snapshot.data!;
          final connectedUserIds = docs.map((doc) {
            String fromId = _getIdFromPath(doc['from']);
            String toId = _getIdFromPath(doc['to']);
            return fromId == _cleanedCurrentUserId ? toId : fromId;
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
                    onRemoveConnection: () => removeConnection(user.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getIdFromPath(String path) {
    if (path.contains('/documents/')) {
      return path.split('/').last;
    }
    return path;
  }

  Stream<List<QueryDocumentSnapshot>> _connectionsStream(String cleanedUserId) {
    final requestsStream =
    FirebaseFirestore.instance.collection('requests').snapshots();

    return requestsStream.map((snapshot) {
      return snapshot.docs.where((doc) {
        final fromId = _getIdFromPath(doc['from']);
        final toId = _getIdFromPath(doc['to']);
        return doc['status'] == 'approved' &&
            (fromId == cleanedUserId || toId == cleanedUserId);
      }).toList();
    });
  }

  Future<List<Mynetwork>> _fetchUsersDetails(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }

    final userDocs = await FirebaseFirestore.instance
        .collection('userregister')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return userDocs.docs.map((doc) {
      final data = doc.data();
      return Mynetwork(
        id: doc.id,
        username: (data['name'] as String?) ?? "N/A",
        Designnation: (data['designation'] as String?) ?? "N/A",
        mobile: (data['mobile'] as String?) ?? "N/A",
        email: (data['email'] as String?) ?? "N/A",
        companywebsite: (data['companywebsite'] as String?) ?? "N/A",
        businessLocation: (data['businessLocation'] as String?) ?? "N/A",
        industry: (data['industry'] as String?) ?? "N/A",
        contry: (data['country'] as String?) ?? "N/A",
        city: (data['city'] as String?) ?? "N/A",
        photoUrl: (data['photoUrl'] as String?) ?? "https://via.placeholder.com/150",
      );
    }).toList();
  }

  Future<void> removeConnection(String otherUserId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'approved')
          .get();

      final docToDelete = querySnapshot.docs.firstWhere(
            (doc) {
          final fromId = _getIdFromPath(doc['from']);
          final toId = _getIdFromPath(doc['to']);
          return (fromId == _cleanedCurrentUserId && toId == otherUserId) ||
              (fromId == otherUserId && toId == _cleanedCurrentUserId);
        },
        orElse: () => throw Exception("Connection not found."),
      );

      await docToDelete.reference.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection removed successfully.")),
        );
      }
    } catch (e) {
      print("Error removing connection: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove connection.")),
        );
      }
    }
  }
}

// -------------------- Connection List Widget --------------------
class ConnectionListWidget extends StatelessWidget {
  final Mynetwork connection;
  final VoidCallback onRemoveConnection;

  const ConnectionListWidget({
    super.key,
    required this.connection,
    required this.onRemoveConnection,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectionDetailScreen(
              connection: connection,
              onRemoveConnection: onRemoveConnection,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    connection.photoUrl.isNotEmpty
                        ? connection.photoUrl
                        : "https://via.placeholder.com/150",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeWords(connection.username),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        capitalizeWords(connection.industry),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        capitalizeWords(connection.Designnation),
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
                  onPressed: () => _openWhatsApp(context, connection.mobile),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber == "N/A" || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is not available")),
      );
      return;
    }

    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    cleanedNumber = cleanedNumber.replaceFirst(RegExp(r'^0+'), '');
    if (cleanedNumber.length <= 10) {
      cleanedNumber = '91$cleanedNumber';
    }

    final whatsappUrl = "https://wa.me/$cleanedNumber";

    try {
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("WhatsApp is not installed or number is invalid")),
      );
    }
  }
}

// -------------------- Connection Detail Screen --------------------
class ConnectionDetailScreen extends StatelessWidget {
  final Mynetwork connection;
  final VoidCallback onRemoveConnection;

  const ConnectionDetailScreen({
    super.key,
    required this.connection,
    required this.onRemoveConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.backgroundLight,
      appBar: AppBar(
        title: Text(capitalizeWords(connection.username)),
        backgroundColor: Appcolor.backgroundDark,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
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
                    backgroundImage: NetworkImage(connection.photoUrl.isNotEmpty
                        ? connection.photoUrl
                        : "https://via.placeholder.com/150"),
                  ),
                  const SizedBox(height: 12),
                  Text(capitalizeWords(connection.username),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(capitalizeWords(connection.industry),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(capitalizeWords(connection.Designnation),
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
                  _buildInfoRow(
                      Icons.person, "Name", capitalizeWords(connection.username)),
                  const Divider(),
                  _buildInfoRow(Icons.work_outline, "Designation",
                      capitalizeWords(connection.Designnation)),
                  const Divider(),
                  _buildInfoRow(Icons.phone, "Mobile", connection.mobile),
                  const Divider(),
                  _buildInfoRow(Icons.email_outlined, "Email", connection.email),
                  const Divider(),
                  _buildInfoRow(
                      Icons.language, "CompanyUrl", connection.companywebsite),
                  const Divider(),
                  _buildInfoRow(Icons.location_history, "BusinessLocation",
                      connection.businessLocation),
                  const Divider(),
                  _buildInfoRow(Icons.business_sharp, "Industry",
                      capitalizeWords(connection.industry)),
                  const Divider(),
                  _buildInfoRow(Icons.map, "Country", connection.contry),
                  const Divider(),
                  _buildInfoRow(Icons.location_city_sharp, "City", connection.city),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(context, connection.mobile),
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text(
                    "Message",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRemoveConfirmationDialog(context),
                  icon: const Icon(Icons.person_remove, color: Colors.white),
                  label: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    if (value == "N/A" || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber == "N/A" || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is not available")),
      );
      return;
    }

    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    cleanedNumber = cleanedNumber.replaceFirst(RegExp(r'^0+'), '');
    if (cleanedNumber.length <= 10) {
      cleanedNumber = '91$cleanedNumber';
    }

    final whatsappUrl = "https://wa.me/$cleanedNumber";

    try {
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("WhatsApp is not installed or number is invalid")),
      );
    }
  }

  void _showRemoveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Remove Connection?"),
          content: const Text("Are you sure you want to remove this connection?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRemoveConnection();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}