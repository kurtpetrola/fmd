// login_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

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
