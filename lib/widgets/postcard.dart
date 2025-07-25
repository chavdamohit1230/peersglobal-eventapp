import 'package:flutter/material.dart';

class LinkedInPostCard extends StatelessWidget {
  final String companyName;
  final String boothInfo;
  final String timeAgo;
  final String postText;
  final String imageUrl;
  final int likes;
  final int comments;
  final int shares;

  const LinkedInPostCard({
    super.key,
    required this.companyName,
    required this.boothInfo,
    required this.timeAgo,
    required this.postText,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  // Clamp font size between min and max to avoid huge sizes in landscape
  double safeFontSize(double screenWidth, double fraction, double min, double max) {
    return (screenWidth * fraction).clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/peersgloblelogo.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: safeFontSize(screenWidth, 0.042, 14, 17),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            boothInfo,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: safeFontSize(screenWidth, 0.032, 11, 14),
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: safeFontSize(screenWidth, 0.030, 10, 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  postText,
                  style: TextStyle(
                    fontSize: safeFontSize(screenWidth, 0.035, 12, 14),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: screenWidth * 1,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionItem(Icons.thumb_up_alt_outlined, '$likes Likes'),
                _actionItem(Icons.comment_outlined, '$comments Comments'),
                _actionItem(Icons.share_outlined, '$shares Shares'),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13, // This size is already small and readable
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
