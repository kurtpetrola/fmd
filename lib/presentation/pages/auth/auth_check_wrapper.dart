// auth_check_wrapper.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/data/services/auth_manager.dart';
import 'package:go_router/go_router.dart';

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

    // 2. Navigate based on authentication status
    if (mounted) {
      if (isAuthenticated && AuthManager.currentUser != null) {
        // Navigate to HomeHolder
        context.go('/home', extra: AuthManager.currentUser);
      } else {
        // Not Logged In or user is null: Navigate to the selection screen
        context.go('/selection');
      }
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
