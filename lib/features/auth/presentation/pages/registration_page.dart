// registration_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';
import 'package:findmydorm/core/widgets/custom_password_field.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/widgets/custom_dropdown_field.dart';

// SIGN UP WIDGET

/// Screen for new user registration and account creation.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // STATE & CONTROLLERS

  // Text Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  // State Variables
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Error State Variables
  bool _showDBError = false;
  String _dbErrorMessage = '';

  // Database and Form Key
  final db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  // Theme Constants
  final Color primaryAmber = Colors.amber.shade700;

  // LIFECYCLE METHODS

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // CORE LOGIC

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

  // UI BUILD METHOD

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
                CustomTextField(
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
                CustomTextField(
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
                CustomTextField(
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
                CustomPasswordField(
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
                CustomPasswordField(
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

  // Improved Gender Dropdown
  Widget _buildGenderDropdown() {
    return CustomDropdownField<String>(
      labelText: 'Gender',
      hintText: 'Select Gender',
      icon: Ionicons.people_outline,
      value: _selectedGender,
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
    return CustomButton(
      text: "REGISTER ACCOUNT",
      onPressed: () => _attemptRegistration(),
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
