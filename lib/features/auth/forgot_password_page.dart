// forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/pages/login_page.dart';

// ===================================
// FORGOT PASSWORD WIDGET
// ===================================

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ===================================
  // STATE & CONTROLLERS
  // ===================================

  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  String _currentStep = 'VERIFY'; // 'VERIFY', 'RESET'
  bool _isPasswordVisible = false;

  // Database and Form Key
  final _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  // Theme Constants
  final Color primaryAmber = Colors.amber.shade700;
  final Color inputFillColor = Colors.grey.shade100;

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
      print("Verification error: $e");
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // This case indicates the email was somehow not found during the final update
        _showSnackBar("Failed to reset password. User not found.",
            isError: true);
      }
    } catch (e) {
      _showSnackBar("Failed to reset password. Try again.", isError: true);
      print("Password reset error: $e");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===================================
  // UI BUILD METHOD
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 'VERIFY' ? 'Verify Account' : 'Reset Password',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryAmber),
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
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 30),

                // --- STEP 1: VERIFY FORM ---
                if (_currentStep == 'VERIFY') ...[
                  // Email Field
                  _buildStyledTextField(
                    controller: _emailController,
                    hintText: 'Registered Email Address',
                    icon: Ionicons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return "Email is required.";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                        return 'Enter a valid email.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Address Field (Security Check)
                  _buildStyledTextField(
                    controller: _addressController,
                    hintText: 'Registered Address (Security Check)',
                    icon: Ionicons.location_outline,
                    validator: (value) {
                      if (value!.isEmpty)
                        return "Your registered address is required for verification.";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Verify Button
                  _buildActionButton(
                    text: 'VERIFY ACCOUNT',
                    onPressed: _verifyIdentity,
                  ),
                ],

                // --- STEP 2: RESET FORM ---
                if (_currentStep == 'RESET') ...[
                  // New Password Field
                  _buildStyledPasswordField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    validator: (value) {
                      if (value!.isEmpty) return "New Password is required";
                      if (value.length < 8)
                        return "Password must be at least 8 characters long";
                      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value))
                        return "Must contain at least one uppercase letter";
                      if (!RegExp(r'(?=.*[a-z])').hasMatch(value))
                        return "Must contain at least one lowercase letter";
                      if (!RegExp(r'(?=.*\d)').hasMatch(value))
                        return "Must contain at least one digit (0-9)";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildStyledPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm New Password',
                    validator: (value) {
                      if (value!.isEmpty) return "Confirmation is required";
                      if (_newPasswordController.text != value)
                        return "Passwords don't match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Reset Button
                  _buildActionButton(
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

  // ===================================
  // UI HELPER WIDGETS
  // ===================================

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

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
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
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
