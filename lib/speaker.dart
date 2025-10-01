import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';
class Speaker extends StatefulWidget {
  const Speaker({super.key});

  @override
  State<Speaker> createState() => _SpeakerState();
}

class _SpeakerState extends State<Speaker> {
  // Launch URL
  void launchLink(String url) async {
    if (url.isEmpty) return;
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  // Build Social Icon
  Widget buildSocialIcon(String url, IconData icon, Color color) {
    if (url.isEmpty) return const SizedBox();
    return IconButton(
      icon: FaIcon(icon, color: color, size: 20),
      onPressed: () => launchLink(url),
    );
  }

  // Speaker Card
  Widget buildSpeakerCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    List<String> links = List<String>.from(data["socialLinks"] ?? []);
    String? bio = data["bio"]; // Bio field

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker Image
            CircleAvatar(
              radius: 50,
              backgroundImage: data["imageUrl"] != null && data["imageUrl"] != ""
                  ? NetworkImage(data["imageUrl"])
                  : null,
              backgroundColor: Colors.white,
              child: (data["imageUrl"] == null || data["imageUrl"] == "")
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 20),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["name"] ?? "",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(data["occupation"] ?? "",
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(data["organization"] ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.black)),
                  Text("${data["city"] ?? ""}, ${data["country"] ?? ""}",
                      style: const TextStyle(fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(data["email"] ?? "",
                              style:
                              const TextStyle(fontSize: 14, color: Colors.black))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bio (display only if exists)
                  if (bio != null && bio.isNotEmpty) ...[
                    Text(bio,
                        style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (links.isNotEmpty)
                        buildSocialIcon(links[0], FontAwesomeIcons.facebook, Colors.black),
                      if (links.length > 1)
                        buildSocialIcon(links[1], FontAwesomeIcons.linkedin, Colors.black),
                      if (links.length > 2)
                        buildSocialIcon(links[2], FontAwesomeIcons.twitter, Colors.black),
                      if (links.length > 3)
                        buildSocialIcon(links[3], FontAwesomeIcons.instagram, Colors.black),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Appcolor.backgroundLight,
      appBar: AppBar(title: const Text("Speakers"),
      backgroundColor:Appcolor.backgroundDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("speakers")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No speakers found"));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return buildSpeakerCard(docs[index]);
            },
          );
        },
      ),
    );
  }
}
