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
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // Build Social Icon
  Widget buildSocialIcon(String url, IconData icon, Color color) {
    if (url.isEmpty) return const SizedBox();
    return InkWell(
      onTap: () => launchLink(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FaIcon(icon, color: color, size: 18),
      ),
    );
  }

  // Speaker Card
  Widget buildSpeakerCard(DocumentSnapshot doc, BoxConstraints constraints) {
    var data = doc.data() as Map<String, dynamic>;
    List<String> links = List<String>.from(data["socialLinks"] ?? []);
    String? bio = data["bio"];

    bool isWide = constraints.maxWidth > 700; // Tablet/Web responsive

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker Image (rectangular for pro look)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data["imageUrl"] ?? "",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person,
                      size: 60, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(child: buildSpeakerInfo(data, bio, links)),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data["imageUrl"] ?? "",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person,
                      size: 60, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildSpeakerInfo(data, bio, links),
          ],
        ),
      ),
    );
  }

  Widget buildSpeakerInfo(
      Map<String, dynamic> data, String? bio, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["name"] ?? "",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          data["occupation"] ?? "",
          style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                data["organization"] ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${data["city"] ?? ""}, ${data["country"] ?? ""}",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.email, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Expanded(
                child: Text(data["email"] ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800))),
          ],
        ),
        const SizedBox(height: 10),
        if (bio != null && bio.isNotEmpty) ...[
          ExpandableBio(bio: bio),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            if (links.isNotEmpty)
              buildSocialIcon(links[0], FontAwesomeIcons.facebook, Colors.blue),
            if (links.length > 1)
              buildSocialIcon(
                  links[1], FontAwesomeIcons.linkedin, Colors.blueAccent),
            if (links.length > 2)
              buildSocialIcon(links[2], FontAwesomeIcons.twitter, Colors.blue),
            if (links.length > 3)
              buildSocialIcon(
                  links[3], FontAwesomeIcons.instagram, Colors.purple),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.backgroundLight,
      appBar: AppBar(
        title: const Text("Speakers"),
        backgroundColor: Appcolor.backgroundDark,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder<QuerySnapshot>(
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
                  return buildSpeakerCard(docs[index], constraints);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Collapsible Bio Widget
class ExpandableBio extends StatefulWidget {
  final String bio;
  const ExpandableBio({super.key, required this.bio});

  @override
  State<ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<ExpandableBio> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.bio,
          maxLines: expanded ? null : 3,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? "Show less" : "Read more",
            style: TextStyle(
                fontSize: 13,
                color: Appcolor.backgroundDark,
                fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
