// login_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';
import 'package:findmydorm/core/widgets/custom_password_field.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

// ===================================
// LOGIN PAGE WIDGET
// ===================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  // ===================================
  // STATE & CONTROLLERS
  // ===================================

  // Text Controllers
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  // State Variables
  bool showErrorMessage = false;
  String errorMessage = "Username or password is incorrect";

  // Database and Form Key
  final db = DatabaseHelper.instance;
  final formKey = GlobalKey<FormState>();

  // Theme Constants
  final Color primaryAmber = Colors.amber.shade700;
  // ===================================
  // LIFECYCLE METHODS
  // ===================================

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===================================
  // CORE LOGIC
  // ===================================

  // Handles the main login process and navigation
  login() async {
    // 1. Reset error state at the start of login attempt
    setState(() {
      showErrorMessage = false;
    });

    final enteredIdentifier = identifierController.text.trim();
    final enteredPassword = passwordController.text.trim();

    try {
      // Attempt login verification using the identifier and password
      Users? loggedInUser = await db.login(Users(
        usrName: enteredIdentifier,
        usrEmail: '',
        usrPassword: enteredPassword,
        usrAddress: '',
        usrGender: '',
      ));

      if (loggedInUser != null) {
        if (!mounted) return;

        // Update global state
        await context.read<AuthViewModel>().login(loggedInUser);

        // Navigate to HomeHolder using GoRouter
        if (mounted) {
          context.go('/home', extra: loggedInUser);
        }
      } else {
        // Failed Login (Incorrect credentials)
        _showError(message: "Username or password is incorrect.");
      }
    } catch (e) {
      // Catch any unexpected exceptions during database access
      if (mounted) {
        _showError(message: "An unexpected error occurred. Please try again.");
      }
      debugPrint("Login Exception: ${e.toString()}");
    }
  }

  // Consolidated error display logic (updates state and shows SnackBar)
  void _showError({String message = "Username or password is incorrect"}) {
    setState(() {
      showErrorMessage = true;
      errorMessage = message;
    });
    // Display a SnackBar for quick user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===================================
  // UI BUILD METHOD
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // Logo
                Center(
                  child: Image.asset(
                    "assets/images/logo1.png",
                    height: 150,
                  ),
                ),
                const SizedBox(height: 10),

                // "Find My Dorm" text
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
                const SizedBox(height: 40),

                // Username/Email field
                CustomTextField(
                  controller: identifierController,
                  hintText: 'Username or Email Address',
                  icon: Ionicons.person_outline,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Username or Email is required.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                CustomPasswordField(
                  controller: passwordController,
                  hintText: 'Password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required.";
                    }
                    return null;
                  },
                ),

                // <--- FORGOT PASSWORD LINK (NEW) --->
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: primaryAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // <--- END FORGOT PASSWORD LINK --->

                // STYLED ERROR BANNER
                if (showErrorMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Ionicons.warning_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Lato',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Login button (Styled)
                CustomButton(
                  text: 'LOGIN',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Form fields are valid, attempt login
                      login();
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Sign up button (Styled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account yet?",
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: Text(
                        "Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryAmber,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================
  // UI HELPER FUNCTIONS
  // ===================================

  // UI helpers removed as we're using common widgets
}
