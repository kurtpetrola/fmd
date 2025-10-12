// change_password_page.dart

import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/models/users.dart';
import 'package:ionicons/ionicons.dart';

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
  // Use separate visibility flags for security, though one can be shared if only one field is ever focused
  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

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

      // 2. Hash the new password securely
      final String salt = BCrypt.gensalt();
      final String hashedPassword = BCrypt.hashpw(plainNewPassword, salt);

      // 3. Update the database
      int rowsAffected =
          await dbHelper.updatePassword(widget.user.usrId!, hashedPassword);

      if (rowsAffected > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!')),
          );
          // 4. Important: Log the user out after a password change for security
          // Navigate to the root (login page)
          Navigator.of(context).popUntil((route) => route.isFirst);
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

  // --- Generic Card Container for Info Grouping (Copied from AccountSettingsPage) ---
  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(height: 15, thickness: 1.5),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- Password Field Builder with Card Consistency ---
  Widget _buildPasswordField(
      TextEditingController controller,
      String label,
      bool isVisible,
      ValueChanged<bool> onVisibilityToggle,
      String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Ionicons.lock_closed_outline),
        suffixIcon: IconButton(
          icon:
              Icon(isVisible ? Ionicons.eye_outline : Ionicons.eye_off_outline),
          onPressed: () => onVisibilityToggle(!isVisible),
        ),
      ),
      validator: validator,
    );
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
              // Apply the Card design to the password fields
              _buildInfoCard(
                title: 'Security Update',
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Enter your current and new passwords. You will be logged out after a successful password change.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Current Password Field
                  _buildPasswordField(
                    _currentPasswordController,
                    'Current Password',
                    _isCurrentVisible,
                    (value) => setState(() => _isCurrentVisible = value),
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // New Password Field
                  _buildPasswordField(
                    _newPasswordController,
                    'New Password',
                    _isNewVisible,
                    (value) => setState(() => _isNewVisible = value),
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password.';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm New Password Field
                  _buildPasswordField(
                    _confirmPasswordController,
                    'Confirm New Password',
                    _isConfirmVisible,
                    (value) => setState(() => _isConfirmVisible = value),
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password.';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
}
