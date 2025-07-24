import 'package:flutter/material.dart';

class FormDropdownField extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const FormDropdownField({
    Key? key,
    required this.labelText,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
