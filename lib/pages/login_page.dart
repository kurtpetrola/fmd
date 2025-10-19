// login_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/components/bottom_navbar.dart';
import 'package:ionicons/ionicons.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoginTrue = false;
  String errorMessage = "Username or password is incorrect";

  final db = DatabaseHelper.instance;
  final formKey = GlobalKey<FormState>();

  // --- THEME COLOR CONSTANTS ---
  final Color primaryAmber = Colors.amber.shade700;
  final Color inputFillColor = Colors.grey.shade100;

  // --- Core Login Logic ---
  login() async {
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
        // If login is successful, retrieve the full Users object (needed for role and details)
        Users? loggedInUser =
            await db.getUserByUsernameOrEmail(enteredIdentifier);

        // Crucial check before using context or setState
        if (!mounted) return;

        if (loggedInUser != null) {
          // Successful Login
          setState(() {
            isLoginTrue = false; // Clear any previous error messages
          });

          // Navigate and pass the full, correct Users object to HomeHolder
          // Change to pushAndRemoveUntil
          // Navigate to HomeHolder and clear ALL previous routes (LoginPage and SelectionPage)
          Navigator.of(context).pushAndRemoveUntil(
            // <-- CHANGED METHOD
            MaterialPageRoute(
              builder: (context) => HomeHolder(currentUser: loggedInUser),
            ),
            (Route<dynamic> route) => false, // Removes all routes
          );
        } else {
          // Fallback error if authentication passed but user data couldn't be fetched
          _showError(message: "User data not found after successful login.");
        }
      } else {
        // Failed Login (Incorrect credentials)
        _showError(message: "Username or password is incorrect.");
      }
    } catch (e) {
      // Catch any unexpected exceptions during database access
      if (mounted) {
        _showError(message: "An unexpected error occurred: ${e.toString()}");
      }
      // Print to console for debugging purposes
      print("Login Exception: ${e.toString()}");
    }
  }

  void _showError({String message = "Username or password is incorrect"}) {
    setState(() {
      isLoginTrue = true;
      errorMessage = message;
    });
    // Also display a SnackBar for quick user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                    fontSize: 24, // Slightly larger font for prominence
                  ),
                ),
                const SizedBox(height: 40), // More space before input fields

                // Username/Email field (Styled)
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

                // Password field (Styled)
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

                const SizedBox(height: 30),

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
                        setState(() {
                          isLoginTrue = false;
                        });
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

                // Error message display
                if (isLoginTrue)
                  Text(
                    errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER FUNCTIONS ---

  // Helper function for consistent decoration style (Copied from registration_page)
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
