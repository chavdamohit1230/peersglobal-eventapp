import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/mynetwork_model.dart';

class MyNetworkWidget extends StatelessWidget {
  final Mynetwork mynetwork;

  const MyNetworkWidget({super.key, required this.mynetwork});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FE),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0), // light grey border bottom
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: mynetwork.ImageUrl != null
                ? NetworkImage(mynetwork.ImageUrl!)
                : null,
            child: mynetwork.ImageUrl == null
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
                  mynetwork.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  mynetwork.Designnation ?? "No Designation",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Action Icons
          if (mynetwork.reject != null)
            IconButton(
              icon: Icon(mynetwork.reject, size: 42, color: Colors.red),
              onPressed: () {},
            ),
          if (mynetwork.accept != null)
            IconButton(
              icon: Icon(mynetwork.accept, size: 42, color: Colors.green),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
