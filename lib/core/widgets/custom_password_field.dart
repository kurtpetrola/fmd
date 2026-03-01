import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'custom_text_field.dart';

/// A custom text field specifically designed for passwords with a visibility toggle.
class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAmber = Colors.amber.shade700;

    return CustomTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      icon: Ionicons.lock_closed_outline,
      validator: widget.validator,
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        onPressed: _togglePasswordVisibility,
        icon: Icon(
          _isPasswordVisible ? Ionicons.eye_off_outline : Ionicons.eye_outline,
          color: primaryAmber,
        ),
      ),
    );
  }
}
