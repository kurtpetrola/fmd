import 'package:flutter/material.dart';

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
    final Color primaryAmber = Colors.amber.shade700;
    final Color inputFillColor = Colors.grey.shade100;
    const borderRadius = BorderRadius.all(Radius.circular(15.0));

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
        fillColor: fillColor ?? inputFillColor,
        hintStyle: const TextStyle(fontFamily: 'Lato', color: Colors.grey),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: iconColor ?? primaryAmber,
              )
            : null,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        border: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: primaryAmber, width: 2.0),
        ),
      ),
    );
  }
}
