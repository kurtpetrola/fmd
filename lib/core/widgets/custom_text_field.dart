// custom_text_field.dart

import 'package:flutter/material.dart';

/// A customizable text input field with optional icons and validation.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final bool alignLabelWithHint;
  final bool readOnly;
  final Color? fillColor;
  final Color? iconColor;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.alignLabelWithHint = false,
    this.readOnly = false,
    this.fillColor,
    this.iconColor,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        alignLabelWithHint: alignLabelWithHint,
        filled: true,
        fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
              )
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
