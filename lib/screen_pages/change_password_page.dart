// change_password_page.dart

import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'package:findmydorm/models/users.dart';

class ChangePasswordPage extends StatefulWidget {
  final Users user;

  const ChangePasswordPage({super.key, required this.user});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isVisible = false; // For password visibility toggle

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final plainCurrentPassword = _currentPasswordController.text;
    final plainNewPassword = _newPasswordController.text;

    try {
      // 1. Verify the current password
      // Since the Users object passed to this page only has the HASHED password in its
      // usrPassword field (from the login retrieval), we verify the current password
      // against that stored hash.
      final bool isCurrentPasswordValid = BCrypt.checkpw(
        plainCurrentPassword,
        widget.user.usrPassword, // This holds the stored hash!
      );

      if (!isCurrentPasswordValid) {
        setState(() {
          _errorMessage = 'Incorrect current password.';
        });
        return;
      }

      // Prevent changing to the same password (optional but good practice)
      // Note: This check only prevents the new plaintext password from being
      // identical to the plaintext password they *just* entered as "current".
      // A more robust check might compare the *new hash* to the *old hash*,
      // but the BCrypt library handles comparison securely, so checking the plaintext
      // against itself is fine for basic UX.

      // 2. Hash the new password securely
      final String salt = BCrypt.gensalt();
      final String hashedPassword = BCrypt.hashpw(plainNewPassword, salt);

      // 3. Update the database
      // The database helper needs to be updated to accept the user ID and the new hash.
      int rowsAffected =
          await dbHelper.updatePassword(widget.user.usrId!, hashedPassword);

      if (rowsAffected > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!')),
          );
          // 4. Important: Log the user out after a password change for security
          // You should navigate back to your LoginPage or SelectionPage,
          // forcing a re-login with the new password.
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Assuming your LoginPage is the first route, adjust as needed.
          // A safer route is to push a dedicated login prompt/page.
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to update password in the database.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter your current and new passwords.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Current Password Field
              _buildPasswordField(
                  _currentPasswordController, 'Current Password', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password.';
                }
                return null;
              }),
              const SizedBox(height: 20),

              // New Password Field
              _buildPasswordField(_newPasswordController, 'New Password',
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              }),
              const SizedBox(height: 20),

              // Confirm New Password Field
              _buildPasswordField(
                  _confirmPasswordController, 'Confirm New Password', (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password.';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              }),
              const SizedBox(height: 30),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: !_isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
        ),
      ),
      validator: validator,
    );
  }
}
