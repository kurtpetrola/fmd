// login_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.push('/login');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.amber.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      // Content container and margins removed, let stretch handle the width
      child: const Text(
        "LOGIN",
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Lato', // Consistent font family
          fontWeight: FontWeight.w700,
          fontSize: 18, // Adjusted font size
        ),
      ),
    );
  }
}
