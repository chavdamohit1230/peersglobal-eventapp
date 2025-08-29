import 'package:flutter/foundation.dart';

class AuthUserModel{

  final String id;
  final String name;
  final String mobile;
  final String? role;
  final String? countrycode;

  AuthUserModel({

    required this.id,
    required this.name,
    required this.mobile,
    this.role,
    this.countrycode
});
  factory AuthUserModel.fromjson(Map<String,dynamic>json){

    return AuthUserModel(
        id:json['id']?? '',
        name:json['name']?? '',
        mobile:json['mobile']?? '',
        role:json['role']?? '',
        countrycode:json['countrycode']?? '');
  }
  Map<String,dynamic> tojson(){
    return{
        "id":id,
        "name":name,
        "mobile":mobile,
        "role":role,
        "countrycode":countrycode,
    };
}
}