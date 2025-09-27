import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'modelClass/exhibiter_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExhibiterScreen extends StatefulWidget {
  const ExhibiterScreen({super.key});

  @override
  State<ExhibiterScreen> createState() => _ExhibiterScreenState();
}

class _ExhibiterScreenState extends State<ExhibiterScreen> {
  String searchQuery = '';
  Exhibiter? selectedExhibitor;
  List<Exhibiter> exhibitorList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchExhibitors();
  }

  Future<void> fetchExhibitors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('userregister')
          .where('role', isEqualTo: 'exhibitor')
          .get();

      final List<Exhibiter> loadedList = snapshot.docs.map((doc) {
        final data = doc.data();
        List<String> social = [];
        if (data['socialLinks'] != null) {
          social = List<String>.from(data['socialLinks']);
        }
        return Exhibiter(
          name: data['name'] ?? '',
          Imageurl: data['profileImage'] ?? '',
          email: data['email'] ?? '',
          organization: data['organization'] ?? '',
          website: data['companywebsite'] ?? '',
          location: data['city'] ?? '',
          about: data['aboutme'] ?? '',
          country: data['country'] ?? '',
          socialLinks: social,
        );
      }).toList();

      setState(() {
        exhibitorList = loadedList;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching exhibitors: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Exhibiter> filteredList = exhibitorList.where((exhibitor) {
      return exhibitor.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        if (selectedExhibitor != null) {
          setState(() {
            selectedExhibitor = null;
          });
          return false;
        } else {
          Navigator.of(context).pushReplacementNamed('/homepage');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            selectedExhibitor == null ? "Exhibitors" : "Exhibitor Details",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: selectedExhibitor != null
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              setState(() {
                selectedExhibitor = null;
              });
            },
          )
              : null,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (selectedExhibitor == null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search exhibitors...',
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            if (selectedExhibitor != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Horizontal banner image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(
                            selectedExhibitor!.Imageurl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      selectedExhibitor!.name,
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    if (selectedExhibitor!.organization !=
                                        null)
                                      Text(
                                        selectedExhibitor!.organization!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _infoRow(
                                  icon: Icons.email,
                                  label: "Email",
                                  value: selectedExhibitor!.email),
                              const Divider(),
                              _infoRow(
                                  icon: Icons.business,
                                  label: "Company",
                                  value: selectedExhibitor!.organization),
                              const Divider(),
                              _infoRow(
                                  icon: Icons.language,
                                  label: "Website",
                                  value: selectedExhibitor!.website,
                                  isLink: true),
                              const Divider(),
                              _infoRow(
                                  icon: Icons.location_on,
                                  label: "Location",
                                  value: selectedExhibitor!.location),
                              const Divider(),
                              _infoRow(
                                  icon: Icons.flag,
                                  label: "Country",
                                  value: selectedExhibitor!.country),
                              const Divider(),
                              if (selectedExhibitor!.about != null) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  "About",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedExhibitor!.about!,
                                  style:
                                  const TextStyle(fontSize: 16),
                                ),
                                const Divider(),
                              ],
                              const SizedBox(height: 16),
                              const Text(
                                "Social Media Links",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (var link
                                  in selectedExhibitor!.socialLinks)
                                    IconButton(
                                      icon: _getSocialIcon(link),
                                      color: Colors.blue,
                                      onPressed: () =>
                                          _launchWebsite(link),
                                    ),
                                  if (selectedExhibitor!.socialLinks.isEmpty)
                                    const Text("Coming Soon..."),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredList.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final exhibitor = filteredList[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedExhibitor = exhibitor;
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage:
                              NetworkImage(exhibitor.Imageurl),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exhibitor.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exhibitor.organization ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      {required IconData icon,
        required String label,
        required String? value,
        bool isLink = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          isLink
              ? InkWell(
            onTap: () => _launchWebsite(value),
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          )
              : Expanded(
            child: Text(
              value,
              style: const TextStyle(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getSocialIcon(String url) {
    if (url.contains("facebook")) return const Icon(FontAwesomeIcons.facebook);
    if (url.contains("twitter")) return const Icon(FontAwesomeIcons.twitter);
    if (url.contains("linkedin")) return const Icon(FontAwesomeIcons.linkedin);
    if (url.contains("instagram")) return const Icon(FontAwesomeIcons.instagram);
    return const Icon(Icons.link);
  }
}
 