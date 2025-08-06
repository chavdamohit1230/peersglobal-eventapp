import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/mynetwork_model.dart';

class ConnectionListWidget extends StatelessWidget {
  final Mynetwork connection;

  const ConnectionListWidget({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F8FE),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 👤 Profile Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: connection.ImageUrl != null
                ? NetworkImage(connection.ImageUrl!)
                : null,
            child: connection.ImageUrl == null
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          const SizedBox(width: 12),

          // Name & Designation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  connection.Designnation ?? "No Designation",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // 👉 You can add your connection logic here
              print("Connect button clicked for ${connection.username}");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              "Message  ",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
