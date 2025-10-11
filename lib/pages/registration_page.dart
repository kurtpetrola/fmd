// registration_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/pages/login_page.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/services/sqlite.dart';

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

  // NEW: Controllers and State for Address and Gender
  final _addressController = TextEditingController();
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose(); // Dispose new controller
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo1.png",
                  height: 200,
                ),
                const Text(
                  'Find My Dorm',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 15),

                // 1. USERNAME
                _buildTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  icon: Icons.person,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please create a username.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 2. GENDER
                _buildGenderDropdown(),
                const SizedBox(height: 15),

                // 3. ADDRESS
                _buildTextField(
                  controller: _addressController,
                  hintText: 'Address',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your address.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 4. EMAIL ADDRESS
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please provide a valid email address.";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 5. PASSWORD
                _buildPasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPasswordVisible: _isPasswordVisible,
                  toggleVisibility: _togglePasswordVisibility,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // 6. CONFIRM PASSWORD
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  isPasswordVisible: _isPasswordVisible,
                  toggleVisibility: _togglePasswordVisibility,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password confirmation is required";
                    } else if (_passwordController.text != value) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _buildRegisterButton(context),
                const SizedBox(height: 10),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for the new Gender Dropdown
  Widget _buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.deepPurple.withOpacity(.2),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          icon: Icon(Icons.people),
          border: InputBorder.none,
          hintText: 'Select Gender',
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
      ),
    );
  }

  // Updated Register Button to pass all data
  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width * .9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.amber,
      ),
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final db = DatabaseHelper.instance;

            // Pass ALL REQUIRED FIELDS to the Users model
            db
                .signup(
              Users(
                usrName: _usernameController.text.trim(),
                usrEmail: _emailController.text.trim(),
                usrPassword: _passwordController
                    .text, // Password will be hashed in db.signup
                usrAddress: _addressController.text.trim(), // NEW
                usrGender: _selectedGender!, // NEW (Validated to be non-null)
              ),
            )
                .whenComplete(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            });
          }
        },
        child: const Text(
          "REGISTER",
          style: TextStyle(
            color: Colors.black, // Changed to black for amber button contrast
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // --- Existing Helper Methods (kept for context, no changes needed here) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    // ... existing implementation ...
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.deepPurple.withOpacity(.2),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    // ... existing implementation ...
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.deepPurple.withOpacity(.2),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock),
          border: InputBorder.none,
          hintText: hintText,
          suffixIcon: IconButton(
            onPressed: toggleVisibility,
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    // ... existing implementation ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text("Login"),
        ),
      ],
    );
  }
}
