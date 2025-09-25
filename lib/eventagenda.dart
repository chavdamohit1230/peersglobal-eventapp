import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peersglobleeventapp/color/colorfile.dart';

class Eventagenda extends StatefulWidget {
  const Eventagenda({super.key});

  @override
  State<Eventagenda> createState() => _EventagendaState();
}

class _EventagendaState extends State<Eventagenda>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFFDCEAF4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// ---------- UI for each session card ----------
  Widget buildSessionCard(Map<String, dynamic> data) {
    final List speakers = data['speakers'] ?? [];
    final List images = data['images'] ?? [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${data['timeStart'] ?? ''} - ${data['timeEnd'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (data['description'] != null)
              Text(
                data['description'],
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 12),

            // Images (if available)
            if (images.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (images.isNotEmpty) const SizedBox(height: 12),

            // Speakers (if available)
            if (speakers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: speakers
                    .map(
                      (speaker) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: (speaker['image'] != null &&
                              speaker['image'].toString().isNotEmpty)
                              ? NetworkImage(speaker['image'])
                              : null,
                          radius: 30,
                          child: (speaker['image'] == null ||
                              speaker['image'].toString().isEmpty)
                              ? const Icon(Icons.person, size: 36)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                speaker['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (speaker['occupation'] != null &&
                                  speaker['occupation'] != "")
                                Text(
                                  speaker['occupation'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              if (speaker['bio'] != null &&
                                  speaker['bio'] != "")
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    "Bio: ${speaker['bio']}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// ---------- Firestore data fetch ----------
  Widget buildDaySessions(int day) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventagenda')
          .where('day', isEqualTo: day)
          .orderBy('timeStart')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No sessions available"));
        }

        final sessions = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return ListView(
          children: sessions.map((s) => buildSessionCard(s)).toList(),
        );
      },
    );
  }

  /// ---------- Main UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Event Agenda",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Appcolor.backgroundDark,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Day 1"),
            Tab(text: "Day 2"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildDaySessions(1),
          buildDaySessions(2),
        ],
      ),
    );
  }
}
