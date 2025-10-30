import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'modelClass/exhibiter_model.dart';

class ExhibiterScreen extends StatefulWidget {
  const ExhibiterScreen({super.key});

  @override
  State<ExhibiterScreen> createState() => _ExhibiterScreenState();
}

class _ExhibiterScreenState extends State<ExhibiterScreen> {
  // 💡 Real-time Stream Definition
  // यह Stream Firestore से real-time data fetch करेगा।
  final Stream<QuerySnapshot> _exhibitorsStream = FirebaseFirestore.instance
      .collection('userregister')
      .where('role', isEqualTo: 'exhibitor')
      .snapshots(); // 👈 .get() के बजाय .snapshots()

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Exhibiter? selectedExhibitor;

  @override
  void initState() {
    super.initState();
    // ❌ fetchExhibitors() को हटा दिया गया है
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
    });
  }

  // ❌ fetchExhibitors फ़ंक्शन को हटा दिया गया है

  Future<void> _launchWebsite(String url) async {
    String finalUrl = url.startsWith('http') ? url : 'https://$url';
    final Uri uri = Uri.parse(finalUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw Exception("Could not launch $url");
      }
    }
  }

  Color _getBannerColor(int index) {
    List<Color> colors = [
      const Color(0xFF6B7A8F),
      const Color(0xFFC0A183),
      const Color(0xFF5F9E9D),
      const Color(0xFFA15A6B),
      const Color(0xFF8B6B8A),
    ];
    return colors[index % colors.length];
  }

  // Helper function to convert QuerySnapshot to List<Exhibiter>
  List<Exhibiter> _mapSnapshotToExhibitors(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      List<String> social = [];
      if (data['socialLinks'] != null) {
        social = List<String>.from(data['socialLinks']);
      }
      return Exhibiter(
        name: data['name'] ?? '',
        Imageurl: data['photoUrl'] ?? '',
        email: data['email'] ?? '',
        organization: data['organization'] ?? '',
        website: data['companywebsite'] ?? '',
        location: data['city'] ?? '',
        about: data['aboutme'] ?? '',
        country: data['country'] ?? '',
        socialLinks: social,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedExhibitor != null) {
          setState(() {
            selectedExhibitor = null;
          });
          return false;
        } else {
          Navigator.of(context).pop();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          title: Text(
            selectedExhibitor == null ? "Exhibitors" : selectedExhibitor!.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: selectedExhibitor != null
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              setState(() {
                selectedExhibitor = null;
              });
            },
          )
              : null,
        ),
        body: selectedExhibitor != null
            ? _buildExhibitorDetailsPage(context)
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search exhibitors...',
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon:
                  const Icon(Icons.search, color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // 💡 Change 2: Use StreamBuilder for Real-Time Updates
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _exhibitorsStream,
                builder: (context, snapshot) {
                  // 1. Loading State (Shimmer)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoading();
                  }

                  // 2. Error State
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // 3. Data Available
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No exhibitors found."));
                  }

                  // Convert snapshot to Exhibiter list
                  final allExhibitors = _mapSnapshotToExhibitors(snapshot.data!);

                  // Apply search filter (happens instantly due to _searchController)
                  List<Exhibiter> filteredList = allExhibitors.where((exhibitor) {
                    return exhibitor.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase().trim());
                  }).toList();

                  // 4. Display List
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final exhibitor = filteredList[index];
                      return _exhibitorCardDesign(
                          context, exhibitor, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Rest of your existing helper widgets (Shimmer, Card Design, Details Page) ---

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _shimmerCardSkeleton(index);
        },
      ),
    );
  }

  Widget _shimmerCardSkeleton(int index) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _getBannerColor(index).withOpacity(0.5),
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Transform.translate(
                offset: const Offset(20, -30),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0,2),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exhibitorCardDesign(
      BuildContext context, Exhibiter exhibitor, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedExhibitor = exhibitor;
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getBannerColor(index),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(20, -30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        exhibitor.Imageurl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.business,
                                  color: Colors.grey, size: 30),
                            ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibitor.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (exhibitor.organization != null &&
                          exhibitor.organization!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          exhibitor.organization!,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExhibitorDetailsPage(BuildContext context) {
    final exhibitor = selectedExhibitor!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(exhibitor.Imageurl),
                    onBackgroundImageError: (exception, stackTrace) =>
                    const Icon(Icons.person, size: 56, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exhibitor.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  exhibitor.organization ?? '',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  title: "About Us",
                  content: Text(
                    exhibitor.about ?? "No information provided.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                _buildSection(
                  context,
                  title: "Contact Information",
                  content: Column(
                    children: [
                      _infoRow(
                          icon: Icons.email,
                          label: "Email",
                          value: exhibitor.email,
                          isLink: true),
                      _infoRow(
                          icon: Icons.language,
                          label: "Website",
                          value: exhibitor.website,
                          isLink: true),
                      _infoRow(
                          icon: Icons.location_on,
                          label: "Location",
                          value: exhibitor.location),
                      _infoRow(
                          icon: Icons.flag,
                          label: "Country",
                          value: exhibitor.country),
                    ],
                  ),
                ),
                if (exhibitor.socialLinks.isNotEmpty)
                  _buildSection(
                    context,
                    title: "Connect",
                    content: Row(
                      children: [
                        for (var link in exhibitor.socialLinks)
                          _socialIcon(link),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: content,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                isLink
                    ? InkWell(
                  onTap: () => _launchWebsite(value),
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                    : Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String url) {
    IconData icon;
    if (url.contains("facebook")) {
      icon = FontAwesomeIcons.facebook;
    } else if (url.contains("twitter") || url.contains("x.com")) {
      icon = FontAwesomeIcons.xTwitter;
    } else if (url.contains("linkedin")) {
      icon = FontAwesomeIcons.linkedinIn;
    } else if (url.contains("instagram")) {
      icon = FontAwesomeIcons.instagram;
    } else {
      icon = Icons.link;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: Icon(icon, color: Colors.blue[700]),
        iconSize: 30,
        onPressed: () => _launchWebsite(url),
      ),
    );
  }
}