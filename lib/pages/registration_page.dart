// registration_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/pages/login_page.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:ionicons/ionicons.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // --- THEME COLOR CONSTANTS ---
  final Color primaryAmber = Colors.amber.shade700;
  final Color inputFillColor = Colors.grey.shade100;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is removed for a cleaner, full-screen look
      body: SafeArea(
        // Use SafeArea to push content below the system status bar
        child: SingleChildScrollView(
          // Increased horizontal padding for better spacing
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
                    height: 100, // Slightly smaller logo for more space
                  ),
                ),
                const SizedBox(height: 10),

                // ADDED: "Find My Dorm" brand text for consistency
                const Text(
                  'Find My Dorm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 35), // Space before form fields

                // 1. USERNAME
                _buildStyledTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  icon: Ionicons.person_outline,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter a username.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 2. GENDER
                _buildGenderDropdown(),
                const SizedBox(height: 15),

                // 3. ADDRESS
                _buildStyledTextField(
                  controller: _addressController,
                  hintText: 'Address',
                  icon: Ionicons.location_outline,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter your address.";
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
                    if (value!.isEmpty) return "Email address is required.";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                      return 'Enter a valid email.';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 5. PASSWORD
                _buildStyledPasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  validator: (value) {
                    if (value!.isEmpty) return "Password is required";
                    if (value.length < 6)
                      return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 6. CONFIRM PASSWORD
                _buildStyledPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Password confirmation is required";
                    else if (_passwordController.text != value)
                      return "Passwords don't match";
                    return null;
                  },
                ),

                const SizedBox(height: 30),
                _buildRegisterButton(context),
                const SizedBox(height: 20),
                _buildLoginButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## HELPER WIDGETS (Unchanged from previous suggestion)
  // -------------------------------------------------------------------

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
      // Ensure dropdown menu background is white/light
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
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final db = DatabaseHelper.instance;

            db
                .signup(
              Users(
                usrName: _usernameController.text.trim(),
                usrEmail: _emailController.text.trim(),
                usrPassword: _passwordController.text,
                usrAddress: _addressController.text.trim(),
                usrGender: _selectedGender!,
              ),
            )
                .whenComplete(() {
              // Show a successful registration snackbar or dialog here before navigating
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            });
          }
        },
        child: const Text(
          "REGISTER ACCOUNT", // More explicit text
          style: TextStyle(
            fontFamily: 'Inter',
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
            // Use pushReplacement to ensure no back-stack buildup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
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
