import 'package:flutter/material.dart';
import 'modelClass/mynetwork_model.dart';
import 'package:peersglobleeventapp/widgets/my_network_widget.dart';

class MyNetwork extends StatefulWidget {
  const MyNetwork({super.key});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  final List<Mynetwork> networklist = [
    Mynetwork(
      username: "Mohit",
      Designnation: "Flutter Developer",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
      reject: Icons.cancel_outlined,
    ),
    Mynetwork(
      username: "Mohit",
      Designnation: "Flutter Developer",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
      reject: Icons.cancel_outlined,
    ),
    Mynetwork(
      username: "Riya",
      Designnation: "UI Designer",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
      reject: Icons.cancel_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Top Heading + List
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenwidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Invitations",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.010),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: networklist.length,
                    itemBuilder: (context, index) {
                      return MyNetworkWidget(mynetwork: networklist[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                        indent: 16,
                        endIndent: 16,
                      );
                    },
                  ),

                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // 🔹 Dummy sections below
            Container(
              height: screenHeight * 0.25,
              width: double.infinity,
              color: Colors.blue,
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              height: screenHeight * 0.25,
              width: double.infinity,
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
    );
  }
}
