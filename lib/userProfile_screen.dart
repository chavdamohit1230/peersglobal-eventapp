import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

      double screenHeight=MediaQuery.of(context).size.height;
      double screenWidth=MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FE),
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(color: Color(0xFF535D97)),
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(

            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 41,
                  backgroundImage: NetworkImage(
                      "https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg"), // Replace with real image
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Mohit Chavda",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Co-Founder of Sarda dairy from a alau road botad",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "ATTENDEE | Business Attendee",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🧭 TabBar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF535D97),
             unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF535D97),
            tabs: const [
              Tab(text: "Profile Detail"),
              Tab(text: "Posts"),
              Tab(text: "Connections",)
            ],
          ),

          // 📄 TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:  [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:screenWidth*0.035,vertical:screenHeight*0.015),
                      child: Row(
                        children: [
                          Icon(Icons.call),
                          SizedBox(width:screenWidth*0.031,),
                          Text("Mobile Number",style:TextStyle(fontSize:18,color:Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:screenWidth*0.1),
                      child: Row(
                        children: [
                          Text("+9023022212",style:TextStyle(fontSize:16),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:screenWidth*0.035,vertical:screenHeight*0.015),
                      child: Row(
                        children: [
                          Icon(Icons.email_sharp),
                          SizedBox(width:screenWidth*0.031,),
                          Text("Email",style:TextStyle(fontSize:18,color:Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:49),
                      child: Row(
                        children: [
                          Text("mohitchavda1241@gmail.com",style:TextStyle(fontSize:16),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:screenWidth*0.035,vertical:screenHeight*0.015),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_outlined ),
                          SizedBox(width:screenWidth*0.031,),
                          Text("State",style:TextStyle(fontSize:18,color:Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:49),
                      child: Row(
                        children: [
                          Text("Gujarat",style:TextStyle(fontSize:16),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:screenWidth*0.035,vertical:screenHeight*0.015),
                      child: Row(
                        children: [
                          Icon(Icons.area_chart_outlined),
                          SizedBox(width:screenWidth*0.031,),
                          Text("City",style:TextStyle(fontSize:18,color:Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:49),
                      child: Row(
                        children: [
                          Text("Ahmedabad",style:TextStyle(fontSize:16),)
                        ],
                      ),
                    )
                  ],
                ),
                Center(child: Text("Posts")),
                Center(child:Text("Connections"),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
