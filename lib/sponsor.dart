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
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolor.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Our Sponsors",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Appcolor.backgroundDark,
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

              return SponsorListCard(
                data: data,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SponsorDetailScreen(data: data),
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

class SponsorListCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const SponsorListCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    data["photoUrl"] ?? "",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.business_center, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["brandName"] ?? "N/A",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data["name"] ?? "N/A",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data["sponsorType"] ?? "N/A",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SponsorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const SponsorDetailScreen({super.key, required this.data});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      // You can show a SnackBar or an alert dialog here to inform the user
      print('An error occurred while launching the URL: $e');
    }
  }

  Widget _infoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String? url, Color color) {
    bool hasLink = url != null && url.isNotEmpty;
    return IconButton(
      icon: FaIcon(icon, color: hasLink ? color : Colors.grey.shade400, size: 28),
      onPressed: hasLink ? () => _launchUrl(url!) : null,
      tooltip: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> socialLinks = data["socialLinks"] ?? {};

    return Scaffold(
      backgroundColor: Appcolor.backgroundLight,
      appBar: AppBar(
        title: Text(data["brandName"] ?? "Sponsor"),
        backgroundColor: Appcolor.backgroundDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.white,
                  child: Image.network(
                    data["photoUrl"] ?? "",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.business_center,
                        color: Colors.grey.shade600,
                        size: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                data["brandName"] ?? "N/A",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                data["name"] ?? "N/A",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Sponsor Details Section
            const Text(
              "Sponsor Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.business, "Organization", data["organization"]),
                    _infoRow(Icons.work, "Designation", data["designation"]),
                    _infoRow(Icons.email, "Email", data["email"]),
                    _infoRow(Icons.location_on, "Location", data["businessLocation"]),
                    _infoRow(Icons.star, "Sponsor Type", data["sponsorType"]),
                    _infoRow(Icons.info, "Other Info", data["otherInfo"]),
                  ],
                ),
              ),
            ),
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.language),
                label: const Text("Visit Website", style: TextStyle(fontSize: 16)),
              ),

            const SizedBox(height: 30),

            // Use a Divider as a separator
            const Divider(height: 1, thickness: 1, color: Colors.grey),

            const SizedBox(height: 30),

            // Social Media Section
            const Text(
              "Follow Us on Social Media",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _socialIcon(FontAwesomeIcons.facebookF, socialLinks["facebook"], Colors.blue.shade700),
                _socialIcon(FontAwesomeIcons.instagram, socialLinks["instagram"], Colors.pink),
                _socialIcon(FontAwesomeIcons.linkedinIn, socialLinks["linkedin"], Colors.blue.shade800),
                _socialIcon(FontAwesomeIcons.twitter, socialLinks["twitter"], Colors.lightBlue.shade500),
                _socialIcon(FontAwesomeIcons.youtube, socialLinks["youtube"], Colors.red.shade700),
              ],
            )
          ],
        ),
      ),
    );
  }
}