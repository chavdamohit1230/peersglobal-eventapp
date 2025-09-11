import 'package:flutter/material.dart';

class Mynetwork{

  final String username;
  final String? id;
  final String Designnation;
  final String ImageUrl;
  final String? organization;
  final IconData? reject;
  final IconData? accept;
  final String? aboutme;
  final String? email;
  final String? mobile;
  final String? businessLocation;
  final String? companywebsite;
  final String? contry;
  final String? city;
   final String? industry;
   final String? purposeOfAttending;

  Mynetwork({

    required this.username,
    required this.Designnation,
    required this.ImageUrl,
    this.id,
     this.reject,
    this.accept,
    this.aboutme,
    this.organization,
    this.email,
    this.mobile,
    this.purposeOfAttending,
    this.industry,
    this.companywebsite,
    this.contry,
    this.city,
    this.businessLocation

});

}