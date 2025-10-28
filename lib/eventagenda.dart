import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:peersglobleeventapp/color/colorfile.dart'; // Assuming this provides Appcolor.backgroundDark

// Updated Professional Color Palette
class Appcolor {
  static const Color backgroundDark = Color(0xFFEFEFEF); // Light Gray Background
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost Black
  static const Color textSecondary = Color(0xFF757575); // Medium Gray
  static const Color accent = Color(0xFF0D47A1); // Deep Blue Accent
  static const Color cardBackground = Colors.white;
  static const Color dividerColor = Color(0xFFDCDCDC);
}

class Eventagenda extends StatefulWidget {
  const Eventagenda({super.key});

  @override
  State<Eventagenda> createState() => _EventagendaState();
}

class _EventagendaState extends State<Eventagenda> {
  final Color primaryColor = Appcolor.backgroundDark;

  Stream<QuerySnapshot> _fetchFullAgendaStream() {
    return FirebaseFirestore.instance
        .collection('eventagenda')
        .orderBy('day')
        .orderBy('timeStart')
        .snapshots();
  }

  // --- UI for each session card (PREMIUM TIMELINE DESIGN) ---
  Widget buildSessionCard(Map<String, dynamic> data) {
    final List speakers = data['speakers'] ?? [];
    final List images = data['images'] ?? [];
    final String timeStart = data['timeStart'] ?? '';
    final String timeEnd = data['timeEnd'] ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStart,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.accent,
                  ),
                ),
                Text(
                  timeEnd,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Appcolor.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 2,
                  height: 50,
                  color: Appcolor.dividerColor,
                ),
              ],
            ),
          ),

          // Timeline separator line and dot
          Column(
            children: [

              Expanded(
                child: Container(width: 2, color: Appcolor.dividerColor),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Appcolor.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Appcolor.backgroundDark, width: 2),
                ),
              ),

              Expanded(
                child: Container(width: 2, color: Appcolor.dividerColor),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Appcolor.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Appcolor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (data['description'] != null)
                    Text(
                      data['description'],
                      style: const TextStyle(fontSize: 14, color: Appcolor.textSecondary),
                    ),

                  if (images.isNotEmpty || speakers.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Appcolor.dividerColor, height: 1),
                    ),

                  // Images Section (Compact)
                  if (images.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Visuals:",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Appcolor.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    images[index],
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Speakers Section
                  if (speakers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Speakers/Facilitators:",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Appcolor.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        ...speakers.map(
                              (speaker) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: (speaker['image'] != null &&
                                      speaker['image'].toString().isNotEmpty)
                                      ? NetworkImage(speaker['image'])
                                      : null,
                                  radius: 20,
                                  backgroundColor: Appcolor.backgroundDark,
                                  child: (speaker['image'] == null ||
                                      speaker['image'].toString().isEmpty)
                                      ? const Icon(Icons.person, size: 22, color: Appcolor.textSecondary)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        speaker['name'] ?? 'Unknown Speaker',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Appcolor.textPrimary),
                                      ),
                                      if (speaker['occupation'] != null &&
                                          speaker['occupation'] != "")
                                        Text(
                                          speaker['occupation'],
                                          style: const TextStyle(fontSize: 12, color: Appcolor.accent),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDaySessionsList(List<Map<String, dynamic>> sessionsForDay) {
    if (sessionsForDay.isEmpty) {
      return const Center(child: Text("No sessions available for this day"));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      children: sessionsForDay.map((s) => buildSessionCard(s)).toList(),
    );
  }


  // --- Main UI (Dynamic Tab Logic) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchFullAgendaStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 1. Data Grouping Logic (Same robust logic as before)
          final Map<int, List<Map<String, dynamic>>> sessionsByDay = {};
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final day = data['day'] as int? ?? 0;
              if (day > 0) {
                if (!sessionsByDay.containsKey(day)) {
                  sessionsByDay[day] = [];
                }
                sessionsByDay[day]!.add(data);
              }
            }
          }

          final sortedDays = sessionsByDay.keys.toList()..sort();
          final tabCount = sortedDays.length;

          // 2. No Data UI (Same logic)
          if (tabCount == 0) {
            return Scaffold(
              backgroundColor: primaryColor,
              appBar: AppBar(
                title: const Text(
                  "Event Agenda",
                  style: TextStyle(color: Appcolor.textPrimary, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Appcolor.cardBackground,
                elevation: 1,
              ),
              body: const Center(
                child: Text(
                  "No event agenda available yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Appcolor.textSecondary),
                ),
              ),
            );
          }

          // 3. Dynamic Tabs UI
          final tabs = sortedDays.map((day) => Tab(text: "Day $day")).toList();
          final tabViews = sortedDays.map((day) {
            return buildDaySessionsList(sessionsByDay[day]!);
          }).toList();


          return DefaultTabController(
            length: tabCount,
            child: Scaffold(
              backgroundColor: primaryColor,
              appBar: AppBar(
                title: const Text(
                  "Event Agenda",
                  style: TextStyle(color: Appcolor.textPrimary, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Appcolor.cardBackground,
                elevation: 1,
                foregroundColor: Appcolor.textPrimary,

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: Container(
                    // TabBar के नीचे एक साफ लाइन
                    decoration: const BoxDecoration(
                      color: Appcolor.cardBackground,
                      border: Border(
                        bottom: BorderSide(color: Appcolor.dividerColor, width: 1.0),
                      ),
                    ),
                    child: TabBar(
                      isScrollable: tabCount > 3,
                      indicatorColor: Appcolor.accent,
                      labelColor: Appcolor.accent,
                      unselectedLabelColor: Appcolor.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      tabs: tabs,
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: tabViews,
              ),
            ),
          );
        },
      ),
    );
  }
}