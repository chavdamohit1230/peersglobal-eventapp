import 'package:flutter/material.dart';

class Mynetwork{

  final String username;
  final String Designnation;
  final String ImageUrl;
  final IconData? reject;
  final IconData? accept;

  Mynetwork({

    required this.username,
    required this.Designnation,
    required this.ImageUrl,
     this.reject,
    this.accept,

});

}