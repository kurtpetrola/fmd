// selection_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/widgets/buttons/login_button.dart';
import 'package:findmydorm/widgets/buttons/register_button.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  // Define the primary color for consistent styling
  final Color primaryAmber = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // REMOVED: Center and SingleChildScrollView wrappers here
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            // THIS IS CRITICAL: Make the Column fill the available vertical space
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // LOGO
              Center(
                child: Image.asset(
                  'assets/images/logo1.png',
                  height: 150,
                ),
              ),
              const SizedBox(height: 10),

              // BRAND TEXT
              const Text(
                'Find My Dorm',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 60),

              // BUTTONS
              const LoginButton(),
              const SizedBox(height: 15),
              const RegisterButton(),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
