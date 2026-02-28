// register_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Used a different widget for visual hierarchy
    return OutlinedButton(
      onPressed: () {
        context.push('/register');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        side: BorderSide(
          color: Colors.amber.shade700,
          width: 2,
        ),
      ),
      child: Text(
        "REGISTER",
        style: TextStyle(
          color: Colors.amber.shade700, // Amber text
          fontFamily: 'Lato', // Consistent font family
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}
