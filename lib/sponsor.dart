import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

class Sponsor extends StatefulWidget {
  const Sponsor({super.key});

  @override
  State<Sponsor> createState() => _SponsorState();
}

class _SponsorState extends State<Sponsor> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith("http") ? url : "https://$url");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Appcolor.backgroundLight,
      appBar: AppBar(
        title: const Text("Our Sponsors",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor:Appcolor.backgroundDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("userregister")
            .where("role", isEqualTo: "sponsor")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Sponsors Found"));
          }

          var sponsors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sponsors.length,
            itemBuilder: (context, index) {
              var data = sponsors[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SponsorDetailScreen(data: data),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          data["photoUrl"] ?? "",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              data["name"] ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["brandName"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
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

class SponsorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const SponsorDetailScreen({super.key, required this.data});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith("http") ? url : "https://$url");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _infoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String? url, Color color) {
    bool hasLink = url != null && url.isNotEmpty;
    return InkWell(
      onTap: hasLink ? () => _launchUrl(url!) : null,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: hasLink ? color : Colors.grey.shade400,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Appcolor.backgroundLight,
      appBar: AppBar(
        title: Text(data["name"] ?? "Sponsor"),
        backgroundColor:Appcolor.backgroundDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                data["photoUrl"] ?? "",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Info Rows
            _infoRow(Icons.business, "Organization", data["organization"]),
            _infoRow(Icons.work, "Designation", data["designation"]),
            _infoRow(Icons.email, "Email", data["email"]),
            _infoRow(Icons.location_on, "Location", data["businessLocation"]),
            _infoRow(Icons.star, "Sponsor Type", data["sponsorType"]),
            _infoRow(Icons.info, "Other Info", data["otherInfo"]),

            const SizedBox(height: 20),

            if (data["companywebsite"] != null &&
                data["companywebsite"].toString().isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _launchUrl(data["companywebsite"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.language),
                label: const Text("Visit Website"),
              ),

            const SizedBox(height: 30),

            // Social Icons Row
            const Text(
              "Follow us on",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _socialIcon(FontAwesomeIcons.facebookF, data["facebook"], Colors.blue),
                _socialIcon(FontAwesomeIcons.instagram, data["instagram"], Colors.pink),
                _socialIcon(FontAwesomeIcons.linkedinIn, data["linkedin"], Colors.blueAccent),
                _socialIcon(FontAwesomeIcons.twitter, data["twitter"], Colors.lightBlue),
                _socialIcon(FontAwesomeIcons.youtube, data["youtube"], Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }
}
