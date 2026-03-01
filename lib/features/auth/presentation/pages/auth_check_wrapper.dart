// auth_check_wrapper.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'dart:developer';

class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely navigate after the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatusAndNavigate();
    });
  }

  void _checkLoginStatusAndNavigate() {
    // Read the AuthViewModel without listening for changes (we just need the initial state)
    final authVM = context.read<AuthViewModel>();

    // If the provider is still loading the user from SharedPreferences, do nothing yet
    if (authVM.isLoading) return;

    if (authVM.isLoggedIn && authVM.currentUser != null) {
      log("AuthCheckWrapper: User is logged in. Navigating to /home");
      context.go('/home', extra: authVM.currentUser);
    } else {
      log("AuthCheckWrapper: User is NOT logged in. Navigating to /selection");
      context.go('/selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in isLoading. When it turns false, _checkLoginStatusAndNavigate will have been called
    // or we can call it here if we want to be purely declarative.
    // Since we are changing routes, it's safer to handle the routing in a listener or postFrameCallback.

    return Scaffold(
      body: Center(
        child: Consumer<AuthViewModel>(builder: (context, authVM, child) {
          // As a fallback/declarative approach, if the state changes while on this screen:
          if (!authVM.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (authVM.isLoggedIn && authVM.currentUser != null) {
                  context.go('/home', extra: authVM.currentUser);
                } else {
                  context.go('/selection');
                }
              }
            });
          }
          return const CircularProgressIndicator();
        }),
      ),
    );
  }
}
