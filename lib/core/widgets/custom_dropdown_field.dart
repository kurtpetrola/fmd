import 'package:flutter/material.dart';

/// A custom, stylized dropdown field used for selecting predefined options.
class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;
  final String? hintText;
  final Color? dropdownColor;
  final Color? iconEnabledColor;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon,
    this.hintText,
    this.dropdownColor,
    this.iconEnabledColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryAmber = Colors.amber.shade700;
    final Color inputFillColor = Colors.grey.shade100;
    const borderRadius = BorderRadius.all(Radius.circular(15.0));

    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      dropdownColor: dropdownColor,
      iconEnabledColor: iconEnabledColor,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: inputFillColor,
        prefixIcon: icon != null ? Icon(icon, color: primaryAmber) : null,
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
      items: items,
      onChanged: onChanged,
    );
  }
}
