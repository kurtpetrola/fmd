// registration_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:ionicons/ionicons.dart';

// ===================================
// SIGN UP WIDGET
// ===================================

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ===================================
  // STATE & CONTROLLERS
  // ===================================

  // Text Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  // State Variables
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _isPasswordVisible = false;

  // Error State Variables
  bool _showDBError = false;
  String _dbErrorMessage = '';

  // Database and Form Key
  final db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  // Theme Constants
  final Color primaryAmber = Colors.amber.shade700;
  final Color inputFillColor = Colors.grey.shade100;

  // ===================================
  // LIFECYCLE METHODS
  // ===================================

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ===================================
  // CORE LOGIC
  // ===================================

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Consolidated error display logic (updates state and shows SnackBar)
  void _showError(String message) {
    setState(() {
      _showDBError = true;
      _dbErrorMessage = message;
    });
    // Display a SnackBar for quick user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _hideError() {
    setState(() {
      _showDBError = false;
      _dbErrorMessage = '';
    });
  }

  // Handles the main registration attempt
  Future<void> _attemptRegistration() async {
    _hideError(); // Clear previous error

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if gender is selected (additional safety check)
    if (_selectedGender == null) {
      _showError("Please select your gender before registering.");
      return;
    }

    // --- Registration Attempt ---
    try {
      await db.signup(
        Users(
          usrName: _usernameController.text.trim(),
          usrEmail: _emailController.text.trim(),
          usrPassword: _passwordController.text,
          usrAddress: _addressController.text.trim(),
          usrGender: _selectedGender!,
        ),
      );

      if (!mounted) return;

      // Successful registration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Registration successful! Please log in."),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to Login page
      context.go('/login');
    } catch (e) {
      // This catches database errors, most commonly a UNIQUE constraint violation.
      if (mounted) {
        _showError(
            "Registration failed. That Username or Email may already exist. Please try different credentials.");
      }
      debugPrint("Registration error: $e");
    }
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Center(
                  child: Image.asset(
                    "assets/images/logo1.png",
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),

                // "Find My Dorm" brand text
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
                const SizedBox(height: 35),

                // 1. FULL NAME FIELD (Letters, spaces, and dots only)
                _buildStyledTextField(
                  controller: _usernameController,
                  hintText: 'Full Name', // Updated hint
                  icon: Ionicons.person_outline,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your full name.";
                    }
                    // REGEX: Allows letters (a-z, A-Z), spaces (\s), and dots (.).
                    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value)) {
                      return "Name can only contain letters, spaces, and dots (.).";
                    }
                    // Check length after removing possible leading/trailing spaces
                    if (value.trim().length < 3) {
                      return "Name must be at least 3 characters.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 2. GENDER
                _buildGenderDropdown(),
                const SizedBox(height: 15),

                // 3. ADDRESS (Simple non-empty check for flexibility)
                _buildStyledTextField(
                  controller: _addressController,
                  hintText: 'Address',
                  icon: Ionicons.location_outline,
                  validator: (value) {
                    // Keeping validation simple to accommodate international addresses
                    if (value!.isEmpty) {
                      return "Please enter your address.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 4. EMAIL ADDRESS
                _buildStyledTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  icon: Ionicons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email address is required.";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 5. PASSWORD (Updated with stronger security requirements)
                _buildStyledPasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters long";
                    }

                    // Check for complexity: At least one uppercase letter
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                      return "Must contain at least one uppercase letter";
                    }

                    // Check for complexity: At least one lowercase letter
                    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                      return "Must contain at least one lowercase letter";
                    }

                    // Check for complexity: At least one digit
                    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                      return "Must contain at least one digit (0-9)";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 6. CONFIRM PASSWORD
                _buildStyledPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password confirmation is required";
                    } else if (_passwordController.text != value) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // DATABASE ERROR BANNER (for uniqueness or other DB errors)
                if (_showDBError)
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
                              _dbErrorMessage,
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

                // REGISTER BUTTON
                _buildRegisterButton(context),
                const SizedBox(height: 20),

                // LOGIN BUTTON
                _buildLoginButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================
  // UI HELPER WIDGETS
  // ===================================

  // Reusable function to create stylish input fields
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(hintText: hintText, icon: icon),
    );
  }

  // Reusable function to create stylish password fields
  Widget _buildStyledPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: !_isPasswordVisible,
      decoration: _buildInputDecoration(
        hintText: hintText,
        icon: Ionicons.lock_closed_outline,
        suffixIcon: IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(
            _isPasswordVisible
                ? Ionicons.eye_off_outline
                : Ionicons.eye_outline,
            color: primaryAmber,
          ),
        ),
      ),
    );
  }

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

  // Improved Gender Dropdown
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _buildInputDecoration(
        hintText: 'Select Gender',
        icon: Ionicons.people_outline,
      ),
      initialValue: _selectedGender,
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select your gender.';
        }
        return null;
      },
      dropdownColor: Colors.white,
      iconEnabledColor: primaryAmber,
    );
  }

  // Improved Register Button
  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Text color
          backgroundColor: primaryAmber, // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5, // Added subtle elevation
        ),
        onPressed: () => _attemptRegistration(), // Use the new handler
        child: const Text(
          "REGISTER ACCOUNT", // More explicit text
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Login Button
  Widget _buildLoginButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            // Navigate to login using GoRouter
            context.go('/login');
          },
          child: Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryAmber,
            ),
          ),
        ),
      ],
    );
  }
}
