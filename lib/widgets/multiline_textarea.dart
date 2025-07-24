// lib/widgets/multiline_textarea.dart
import 'package:flutter/material.dart';

class MultilineTextarea extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;

  const MultilineTextarea({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
    this.maxLines = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: true,
      ),
    );
  }
}
