// login_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

/// A styled button that navigates the user to the login page.
class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: "LOGIN",
      onPressed: () {
        context.push('/login');
      },
    );
  }
}
