import 'package:flutter/material.dart';
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

  // ---------- Dummy Data ----------
  final List<Map<String, dynamic>> day1Sessions = [
    {
      "id": "1",
      "title": "Opening Ceremony",
      "timeStart": "10:00 AM",
      "timeEnd": "10:45 AM",
      "description":
      "Welcome speech and event introduction. A detailed introduction about the event, sponsors, and upcoming sessions.",
      "speakers": [
        {
          "name": "Mr. John Doe",
          "designation": "CEO of ABC Ltd.",
          "image": null,
          "bio": "John Doe is a seasoned entrepreneur with 20 years of experience."
        }
      ]
    },
    {
      "id": "2",
      "title": "Tech Innovations",
      "timeStart": "11:30 AM",
      "timeEnd": "12:30 PM",
      "description":
      "This session covers AI, ML, Blockchain and their real-world applications.",
      "speakers": [
        {
          "name": "Ms. Jane Smith",
          "designation": "CTO of XYZ Tech",
          "image": null,
          "bio": "Jane Smith has been leading tech innovations for the past decade."
        },
        {
          "name": "Mr. Alex Ray",
          "designation": "AI Researcher at PQR Labs",
          "image": null,
          "bio":
          "Alex has been contributing in AI/ML research and published 30+ papers."
        }
      ]
    },
  ];

  final List<Map<String, dynamic>> day2Sessions = [
    {
      "id": "3",
      "title": "Business Networking",
      "timeStart": "10:00 AM",
      "timeEnd": "11:30 AM",
      "description":
      "Opportunity to connect with industry experts, investors and entrepreneurs.",
      "speakers": [
        {
          "name": "Panel of Industry Experts",
          "designation": "",
          "image": null,
          "bio": null
        }
      ]
    },
    {
      "id": "4",
      "title": "Closing Ceremony",
      "timeStart": "04:00 PM",
      "timeEnd": "05:00 PM",
      "description": "Vote of thanks and announcement of future events.",
      "speakers": [
        {
          "name": "Organizing Committee",
          "designation": "",
          "image": null,
          "bio": null
        }
      ]
    },
  ];
  // --------------------------------

  Widget buildSessionCard(Map<String, dynamic> data) {
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

            // Full Description
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Multiple Speakers
            if (data['speakers'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (data['speakers'] as List)
                    .map(
                      (speaker) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: speaker['image'] != null
                              ? NetworkImage(speaker['image'])
                              : null,
                          radius: 30,
                          child: speaker['image'] == null
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
                              if (speaker['designation'] != null &&
                                  speaker['designation'] != "")
                                Text(
                                  speaker['designation'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              if (speaker['bio'] != null)
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

  Widget buildDaySessions(List<Map<String, dynamic>> sessions) {
    return ListView(
      children: sessions.map((s) => buildSessionCard(s)).toList(),
    );
  }

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
          buildDaySessions(day1Sessions),
          buildDaySessions(day2Sessions),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
}
