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
    return IconButton(
      icon: FaIcon(icon, color: color, size: 20),
      onPressed: () => launchLink(url),
      splashRadius: 24,
      tooltip: url,
    );
  }

  // Speaker Card with Gradient
  Widget buildSpeakerCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    List<String> links = List<String>.from(data["socialLinks"] ?? []);
    String? bio = data["bio"];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        // === GRADIENT CHANGE ===
        // Re-adding the gradient for a professional look
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Appcolor.backgroundLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Vertically center content
          children: [
            // Speaker Image (Left Side)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.network(
                    data["imageUrl"] ?? "",
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Speaker Details (Right Side)
            Expanded(
              child: buildSpeakerInfo(data, bio, links),
            ),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data["occupation"] ?? "",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data["organization"] ?? "",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${data["city"] ?? ""}, ${data["country"] ?? ""}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.email_outlined, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data["email"] ?? "",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
        if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          ExpandableBio(bio: bio),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            if (links.isNotEmpty)
              buildSocialIcon(links[0], FontAwesomeIcons.facebook, Colors.blue.shade700),
            if (links.length > 1)
              buildSocialIcon(links[1], FontAwesomeIcons.linkedin, Colors.blue.shade800),
            if (links.length > 2)
              buildSocialIcon(links[2], FontAwesomeIcons.twitter, Colors.blue.shade400),
            if (links.length > 3)
              buildSocialIcon(links[3], FontAwesomeIcons.instagram, Colors.purple.shade700),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("speakers")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No speakers found."));
          }

          final docs = snapshot.data!.docs;
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? "Show less" : "Read more",
            style: TextStyle(
              fontSize: 14,
              color: Appcolor.backgroundDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}