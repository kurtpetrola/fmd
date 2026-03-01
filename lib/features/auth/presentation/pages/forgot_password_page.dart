// forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';
import 'package:findmydorm/core/widgets/custom_password_field.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

// FORGOT PASSWORD WIDGET

/// Screen for users to request a password reset functionality.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // STATE & CONTROLLERS

  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  String _currentStep = 'VERIFY'; // 'VERIFY', 'RESET'

  // Database and Form Key
  final _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  // Theme Constants

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // CORE LOGIC

  // Step 1: Verify user identity using Email and Address
  Future<void> _verifyIdentity() async {
    // 1. Validate input fields
    if (!_formKey.currentState!.validate()) return;

    final usrEmail = _emailController.text.trim();
    final usrAddress = _addressController.text.trim();

    try {
      // 2. Call the newly implemented verification method
      final user = await _db.verifyUserByEmailAndAddress(usrEmail, usrAddress);

      // 3. Check if a user was found
      if (user != null) {
        setState(() {
          _currentStep = 'RESET'; // Move to password reset phase
        });
      } else {
        _showSnackBar("Verification failed. Email or address is incorrect.",
            isError: true);
      }
    } catch (e) {
      _showSnackBar("An error occurred during verification. Try again.",
          isError: true);
      debugPrint("Verification error: $e");
    }
  }

  // Step 2: Reset the password
  Future<void> _resetPassword() async {
    // 1. Validate password fields
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text;

    try {
      // 2. Call the newly implemented password update method (which handles hashing)
      final rowsAffected = await _db.updatePasswordByEmail(email, newPassword);

      if (!mounted) return;

      // 3. Check if the update was successful (rowsAffected > 0)
      if (rowsAffected > 0) {
        _showSnackBar("Password successfully reset! Please log in.");

        // Navigate back to the Login Page
        context.go('/login');
      } else {
        // This case indicates the email was somehow not found during the final update
        _showSnackBar("Failed to reset password. User not found.",
            isError: true);
      }
    } catch (e) {
      _showSnackBar("Failed to reset password. Try again.", isError: true);
      debugPrint("Password reset error: $e");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // UI BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 'VERIFY' ? 'Verify Account' : 'Reset Password',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _currentStep == 'VERIFY'
                      ? 'Enter your email and registered address to verify your identity.'
                      : 'Create a new, strong password.',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 30),

                // --- STEP 1: VERIFY FORM ---
                if (_currentStep == 'VERIFY') ...[
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Registered Email Address',
                    icon: Ionicons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email is required.";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Address Field (Security Check)
                  CustomTextField(
                    controller: _addressController,
                    hintText: 'Registered Address (Security Check)',
                    icon: Ionicons.location_outline,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Your registered address is required for verification.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Verify Button
                  CustomButton(
                    text: 'VERIFY ACCOUNT',
                    onPressed: _verifyIdentity,
                  ),
                ],

                // --- STEP 2: RESET FORM ---
                if (_currentStep == 'RESET') ...[
                  // New Password Field
                  CustomPasswordField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "New Password is required";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      }
                      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                        return "Must contain at least one uppercase letter";
                      }
                      if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                        return "Must contain at least one lowercase letter";
                      }
                      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                        return "Must contain at least one digit (0-9)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  CustomPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm New Password',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Confirmation is required";
                      }
                      if (_newPasswordController.text != value) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Reset Button
                  CustomButton(
                    text: 'RESET PASSWORD',
                    onPressed: _resetPassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
