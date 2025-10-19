// auth_check_wrapper.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/components/bottom_navbar.dart';

class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  void _checkLoginStatusAndNavigate() async {
    // 1. Load the persisted user status
    final isAuthenticated = await AuthManager.loadCurrentUser();

    // 2. Determine the next screen
    Widget nextScreen;

    if (isAuthenticated) {
      final Users? user = AuthManager.currentUser;
      if (user != null) {
        // Navigate to HomeHolder
        // This is the main shell for the logged-in user.
        nextScreen = HomeHolder(
          currentUser: user, // Pass the loaded user to the Bottom Nav
        );
      } else {
        // Fallback if AuthManager.currentUser is somehow null
        nextScreen = const SelectionPage();
      }
    } else {
      // Not Logged In: Navigate to the login/selection screen
      nextScreen = const SelectionPage();
    }

    // Use pushAndRemoveUntil when navigating from the AuthCheckWrapper
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => nextScreen),
        (Route<dynamic> route) => false, // Clears the entire stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This wrapper is a temporary loading screen while the async check runs.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
