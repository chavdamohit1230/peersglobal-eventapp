import 'dart:developer';

import 'package:flutter/material.dart';
import 'modelClass/exhibiter_model.dart';
import 'package:peersglobleeventapp/widgets/Exhibiter_widgets.dart';

class ExhibiterScreen extends StatefulWidget {


  ExhibiterScreen({super.key});

  @override
  State<ExhibiterScreen> createState() => _ExhibiterScreenState();
}
final List<Exhibiter>exhibiterList=[

  Exhibiter(name: 'Gtpl',
      Imageurl: "https://via.placeholder.com/100",
      badge: 'p1 Category',
      catogory: "Platinum"),

];

class _ExhibiterScreenState extends State<ExhibiterScreen> {

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar:AppBar(
        title:Text("Exhibiters List",style:TextStyle(fontSize:18),),
        backgroundColor:Colors.white,
      ),
      body:
      GridView.builder(
          itemCount:exhibiterList.length,
          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:2,
              crossAxisSpacing:12,
              mainAxisSpacing:12,
              childAspectRatio:0.85),
          itemBuilder:(context,index){
            return ExhibiterWidgets(exhibiter:exhibiterList[index],);
          }),
    );
  }
}
