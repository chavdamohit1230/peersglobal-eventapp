import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/widgets/ConnectionListWidget.dart';
import 'package:peersglobleeventapp/widgets/Peopleknows_list_widgets.dart';
import 'package:peersglobleeventapp/widgets/my_network_widget.dart';
import 'modelClass/mynetwork_model.dart';

class MyNetwork extends StatefulWidget {
  const MyNetwork({super.key});

  @override
  State<MyNetwork> createState() => _MyNetworkState();
}

class _MyNetworkState extends State<MyNetwork> {
  final List<Mynetwork> networklist = [
    Mynetwork(username: "ABC", Designnation: "Flutter Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "XYZ", Designnation: "Flutter Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Demo", Designnation: "Flutter Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Extra", Designnation: "Backend Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
  ];

  final List<Mynetwork> peopleknows = [
    Mynetwork(username: "Mohit", Designnation: "Flutter Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Raj", Designnation: "Backend Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Sam", Designnation: "Designer", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "John", Designnation: "Tester", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
  ];

  final List<Mynetwork> connection = [
    Mynetwork(username: "Aman", Designnation: "Flutter Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Ravi", Designnation: "Backend Dev", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Pooja", Designnation: "Designer", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
    Mynetwork(username: "Sneha", Designnation: "Tester", ImageUrl: "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"),
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
            // Invitations
            _buildSection(
              context,
              title: "Invitations",
              list: networklist,
              itemBuilder: (m) => MyNetworkWidget(mynetwork: m),
            ),

            SizedBox(height: screenHeight * 0.01),

            // People You May Know
            _buildSection(
              context,
              title: "People You May Know",
              list: peopleknows,
              itemBuilder: (m) => PeopleknowsListWidgets(peopleknows: m),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Connections
            _buildSection(
              context,
              title: "Connections",
              list: connection,
              itemBuilder: (m) => ConnectionListWidget(connection: m),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Section Widget
  Widget _buildSection(BuildContext context,
      {required String title,
        required List<Mynetwork> list,
        required Widget Function(Mynetwork) itemBuilder}) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F8FE),
      padding: EdgeInsets.symmetric(
        horizontal: screenwidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (list.length > 3)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewAllScreen(title: title, profiles: list, itemBuilder: itemBuilder),
                      ),
                    );
                  },
                  child: const Text("View All", style: TextStyle(fontSize: 16, color: Colors.blue)),
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.010),

          // Show max 3 items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length > 3 ? 3 : list.length,
            itemBuilder: (context, index) => itemBuilder(list[index]),
          ),
        ],
      ),
    );
  }
}

// 🔹 Common View All Screen
class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Mynetwork> profiles;
  final Widget Function(Mynetwork) itemBuilder;

  const ViewAllScreen({
    super.key,
    required this.title,
    required this.profiles,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) => itemBuilder(profiles[index]),
      ),
    );
  }
}
