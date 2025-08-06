import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/widgets/Peopleknows_list_widgets.dart';
import 'modelClass/mynetwork_model.dart';
import 'package:peersglobleeventapp/widgets/my_network_widget.dart';

class MyNetwork extends StatefulWidget {
  const MyNetwork({super.key});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  final List<Mynetwork> networklist = [
    Mynetwork(username:"ABC",
        Designnation:"flutter Developer",
        ImageUrl:"https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
       ),
      Mynetwork(username:"XYZ",
      Designnation:"flutter Developer",
      ImageUrl:"https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
      ),
      Mynetwork(username:"DEmo",
      Designnation:"flutter Developer",
      ImageUrl:"https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
    )
      ];
  final List<Mynetwork> peopleknows = [
    Mynetwork(
        username: "Mohit",
        Designnation: "Flutter Developer",
        ImageUrl:
        "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
        reject: Icons.person_add_alt,
    ),
    Mynetwork(
        username: "Mohit",
        Designnation: "Flutter Developer",
        ImageUrl:
        "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
        reject: Icons.person_add_alt,
    ),
    Mynetwork(
      username: "Mohit",
      Designnation: "Flutter Developer",
      ImageUrl:
      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg",
      reject: Icons.person_add_alt,
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
              color: const Color(0xFFF3F8FE),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: networklist.length,
                    itemBuilder: (context, index) {
                      return MyNetworkWidget(mynetwork: networklist[index]);
                    },
                  ),


                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // 🔹 Dummy sections below
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F8FE),
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
                        "People You May Know",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.010),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: peopleknows .length,
                    itemBuilder: (context, index) {
                      return PeopleknowsListWidgets(peopleknows: peopleknows[index]);
                    },
                  ),


                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F8FE),
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
                        "Connections",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.010),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: networklist.length,
                    itemBuilder: (context, index) {
                      return MyNetworkWidget(mynetwork: networklist[index]);
                    },
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
