import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/modelClass/mynetwork_model.dart';

class PeopleknowsListWidgets extends StatefulWidget {
  final Mynetwork peopleknows;

  const PeopleknowsListWidgets({super.key, required this.peopleknows});

  @override
  State<PeopleknowsListWidgets> createState() => _PeopleknowsListWidgetsState();
}

class _PeopleknowsListWidgetsState extends State<PeopleknowsListWidgets> {
  bool isFollowed = false;
  bool isLoading = false;

  void handleFollowToggle() async {
    setState(() => isLoading = true);


    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      isFollowed = !isFollowed;
      isLoading = false;
    });


    if (isFollowed) {
      print("Followed ${widget.peopleknows.username}");
    } else {
      print("Unfollowed ${widget.peopleknows.username}");
    }
  }

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
            backgroundImage: widget.peopleknows.ImageUrl != null
                ? NetworkImage(widget.peopleknows.ImageUrl!)
                : null,
            child: widget.peopleknows.ImageUrl == null
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.peopleknows.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  widget.peopleknows.Designnation ?? "No Designation",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),


          ElevatedButton(
            onPressed: isLoading ? null : handleFollowToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              isFollowed ? "Requested" : "Follow",
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
