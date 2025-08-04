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
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

    Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),

  Exhibiter(name: 'Gtpl',
      Imageurl:"https://www.clipartmax.com/png/middle/192-1924552_gtpl-saathi-apk-download-install-for-android-dekstop-gtpl.png",
      badge: 'p1 Category',
      catogory: "Platinum"),




];

class _ExhibiterScreenState extends State<ExhibiterScreen> {

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:Colors.white,
      appBar:AppBar(
        title:Text("Exhibiters List",style:TextStyle(fontSize:18),),
        backgroundColor:Colors.white,
      ),
      body:
      GridView.builder(
          itemCount:exhibiterList.length,
          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:2,
              crossAxisSpacing:2,
              mainAxisSpacing:2,
              childAspectRatio:0.85),
          itemBuilder:(context,index){
            return ExhibiterWidgets(exhibiter:exhibiterList[index],);
          }),
    );
  }
}
