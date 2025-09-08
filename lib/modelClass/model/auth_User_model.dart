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


  AuthUserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.role,
    this.countrycode,
    this.designation,
    this.city,
    this.email,

  });

  // ✅ Firestore se direct object banane ke liye
  factory AuthUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthUserModel(
      id: doc.id, // 🔑 sirf document.id lena hoga
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      role: data['role'] ?? '',
      countrycode: data['countrycode'] ?? '',
      designation: data['designnation']?? '',
      city: data['city']??'',
      email:data['email']?? '',

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
      city: json['city']?? ''
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
      "designnation":designation,
      "city":city,
      "email":email
    };
  }
}
