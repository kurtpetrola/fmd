// login_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/widgets/navigation/bottom_navbar.dart';
import 'package:ionicons/ionicons.dart';
import 'registration_page.dart';
import 'package:findmydorm/features/auth/forgot_password_page.dart';

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
  bool isVisible = false;
  bool showErrorMessage = false;
  String errorMessage = "Username or password is incorrect";

  // Database and Form Key
  final db = DatabaseHelper.instance;
  final formKey = GlobalKey<FormState>();

  // Theme Constants
  final Color primaryAmber = Colors.amber.shade700;
  final Color inputFillColor = Colors.grey.shade100;

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
      var isAuthenticated = await db.login(Users(
        usrName: enteredIdentifier,
        usrEmail: '',
        usrPassword: enteredPassword,
        usrAddress: '',
        usrGender: '',
      ));

      if (isAuthenticated == true) {
        // Successful authentication
        Users? loggedInUser =
            await db.getUserByUsernameOrEmail(enteredIdentifier);

        if (!mounted) return;

        if (loggedInUser != null) {
          // Navigate to HomeHolder and clear ALL previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeHolder(currentUser: loggedInUser),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Fallback error if user data couldn't be fetched
          _showError(
              message:
                  "User data not found after successful login. Please contact support.");
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
      print("Login Exception: ${e.toString()}");
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
                TextFormField(
                  controller: identifierController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Username or Email is required.";
                    }
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hintText: 'Username or Email Address',
                    icon: Ionicons.person_outline,
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required.";
                    }
                    return null;
                  },
                  obscureText: !isVisible,
                  decoration: _buildInputDecoration(
                    hintText: 'Password',
                    icon: Ionicons.lock_closed_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                      icon: Icon(
                        isVisible
                            ? Ionicons.eye_off_outline
                            : Ionicons.eye_outline,
                        color: primaryAmber,
                      ),
                    ),
                  ),
                ),

                // <--- FORGOT PASSWORD LINK (NEW) --->
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ForgotPasswordScreen(), // Navigate to new screen
                        ),
                      );
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
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: primaryAmber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Form fields are valid, attempt login
                        login();
                      }
                    },
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                  ),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
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

  // Helper function for consistent decoration style
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    const borderRadius = BorderRadius.all(Radius.circular(15.0));
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: inputFillColor,
      prefixIcon: Icon(icon, color: primaryAmber),
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      border: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: primaryAmber, width: 2.0),
      ),
    );
  }
}
