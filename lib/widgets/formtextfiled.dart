import 'package:flutter/material.dart';

class Formtextfiled extends StatelessWidget {
  final  TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keybordType;
  const Formtextfiled({
      Key? key,
      required this.controller,
      required this.labelText,
      required this.prefixIcon,
       this.validator,
        this.keybordType
  }):super(key:key);

  @override
  Widget build(BuildContext context) {
    final screenHeight=MediaQuery.of(context).size.height;
    final screenwidth=MediaQuery.of(context).size.width;
    return TextFormField(
      keyboardType:keybordType,
      controller:controller,
      decoration:InputDecoration(
        labelText:labelText,
        prefixIcon:Icon(prefixIcon),
        contentPadding: EdgeInsets.symmetric(vertical:screenHeight*0.013),
        border:OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:validator,
    );
  }
}
