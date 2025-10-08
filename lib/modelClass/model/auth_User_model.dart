import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUserModel {
  final String id;
  final String name;
  final String mobile;
  final String? role;
  final String? countrycode;
  final String? designation;
  final String? city;
  final String? email;
  final String? organization;
  final String? aboutme;
  final String? photoUrl;


  AuthUserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.role,
    this.organization,
    this.countrycode,
    this.designation,
    this.city,
    this.email,
    this.photoUrl,
    this.aboutme

  });

  // ✅ Firestore se direct object banane ke liye
  factory AuthUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthUserModel(
      id: doc.id,
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      role: data['role'] ?? '',
      countrycode: data['countrycode'] ?? '',
      designation: data['designation'] ?? '',
      city: data['city']??'',
      email:data['email']?? '',
      photoUrl:data['photoUrl']?? '',
      organization: data['organization']?? '',
      aboutme:data['aboutme']?? '',

    );
  }

  // ✅ Agar API/JSON se parse karna ho
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? '',
      countrycode: json['countrycode'] ?? '',
      designation: json['designation']?? '',
      email:json['email']?? '',
      city: json['city']?? '',
      photoUrl:json['photoUrl']?? '',
      organization: json['orgenigation']?? '',
      aboutme:json['aboutme']?? '',
    );
  }

  // ✅ Firestore/JSON ke liye object ko map me convert karna
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "mobile": mobile,
      "role": role,
      "countrycode": countrycode,
      "designation": designation,
      "city":city,
      "email":email,
      "orgenigation":organization,
      'aboutme':aboutme,
      'photoUrl':photoUrl,
    };
  }
}
