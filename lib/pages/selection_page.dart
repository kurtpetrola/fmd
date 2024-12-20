import 'package:flutter/material.dart';
import 'package:findmydorm/components/login_button.dart';
import 'package:findmydorm/components/register_button.dart';
import 'package:findmydorm/components/main_header.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 100),
                const MainHeader(),
                const SizedBox(height: 20),
                const Text(
                  'Find My Dorm',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 50),
                LoginButton(onPressed: _onLoginTap),
                const SizedBox(height: 10),
                RegisterButton(onPressed: _onRegisterTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginTap() {
    // Handle login button tap
  }

  void _onRegisterTap() {
    // Handle register button tap
  }
}
