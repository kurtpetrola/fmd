// register_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

/// A widget that provides a styled button for navigating to the registration page.
class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Used a different widget for visual hierarchy
    return CustomButton(
      text: "REGISTER",
      onPressed: () {
        context.push('/register');
      },
      backgroundColor: Colors.transparent,
      textColor: Colors.amber.shade700,
      elevation: 0,
      border: BorderSide(
        color: Colors.amber.shade700,
        width: 2,
      ),
    );
  }
}
