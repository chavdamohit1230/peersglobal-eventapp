import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Recentnotification extends StatefulWidget {
  const Recentnotification({super.key});

  @override
  State<Recentnotification> createState() => _RecentnotificationState();
}

class _RecentnotificationState extends State<Recentnotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No announcements available."));
          }

          final announcements = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return AnnouncementCard(
                title: announcement['title'] ?? '',
                description: announcement['description'] ?? '',
                date: announcement['date'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
  });

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) {
      return '';
    }

    final notificationDate = DateTime.parse(isoDate);
    final now = DateTime.now();

    if (now.difference(notificationDate).inDays < 1) {
      // If the announcement is from today, show time (e.g., "10:30 AM")
      return DateFormat('h:mm a').format(notificationDate);
    } else {
      // Otherwise, show full date (e.g., "14 October 2025")
      return DateFormat('dd MMMM yyyy').format(notificationDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}