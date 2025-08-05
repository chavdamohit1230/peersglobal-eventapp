import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/mynetwork_model.dart';

class MyNetworkWidget extends StatelessWidget {
  final Mynetwork mynetwork;

  const MyNetworkWidget({super.key, required this.mynetwork});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // 👈 No rounded corners
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Avatar
              mynetwork.ImageUrl != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(mynetwork.ImageUrl),
                radius: 25,
              )
                  : const CircleAvatar(
                child: Icon(Icons.person),
                radius: 25,
              ),

              const SizedBox(width: 12),

              // Name and Designation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mynetwork.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(mynetwork.Designnation ?? "No Designation"),
                  ],
                ),
              ),

              // Action icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mynetwork.reject != null)
                    IconButton(
                      icon: Icon(mynetwork.reject, size: 21),
                      onPressed: () {},
                    ),
                  if (mynetwork.accept != null)
                    IconButton(
                      icon: Icon(mynetwork.accept, size: 21),
                      onPressed: () {},
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
