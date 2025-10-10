import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';



class FloorPlanPage extends StatefulWidget {
  const FloorPlanPage({super.key});

  @override
  State<FloorPlanPage> createState() => _FloorPlanPageState();
}

class _FloorPlanPageState extends State<FloorPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Appcolor.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Floor Plans",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor:Appcolor.backgroundDark,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("floorplan")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Lottie.asset(
                      'assets/lottieanimation/locationanimation.json',
                      height: 280,
                      width: 280,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Floor Plan Awailable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }
          final floorPlans = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: floorPlans.length,
            itemBuilder: (context, index) {
              final data = floorPlans[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? "Untitled";
              final description = data['description'] ?? "";
              final imageUrl = data['imageUrl'] ?? "";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FloorPlanDetailView(
                        title: title,
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white, // card background white
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Floorplan Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          Uri.decodeFull(imageUrl),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey, size: 60),
                              ),
                        )
                            : Container(
                          height: 180,
                          color:Colors.white,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
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

class FloorPlanDetailView extends StatelessWidget {
  final String title;
  final String imageUrl;

  const FloorPlanDetailView({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: imageUrl.isNotEmpty
              ? Image.network(
            Uri.decodeFull(imageUrl),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  "Failed to load floor plan",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          )
              : const Center(
            child: Text(
              "No image available",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
