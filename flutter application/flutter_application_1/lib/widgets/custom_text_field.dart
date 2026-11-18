import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,

      validator: validator,
      onSaved: onSaved,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(
          prefixIcon,
        ),

        suffixIcon: suffixIcon,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(6),
        ),
      ),
    );
  }
}