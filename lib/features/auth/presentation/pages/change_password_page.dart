// change_password_page.dart

import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/core/widgets/custom_password_field.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

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

          // Cache the context/router values to prevent unmounting issues
          final authVM = context.read<AuthViewModel>();
          final router = GoRouter.of(context);

          // 4. Navigate to the LoginPage and clear the entire navigation stack
          router.go('/login');

          // Call logout function to clear session state using AuthViewModel
          await authVM.logout();
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
      // Consistent card style
      elevation: 6,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)), // Match fields
      margin: const EdgeInsets.only(bottom: 25), // Increased margin
      child: Padding(
        padding: const EdgeInsets.all(18.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                // 🟢 IMPROVEMENT: Use a dark neutral color
                color: Colors.black87,
              ),
            ),
            // Thinner divider
            const Divider(height: 20, thickness: 0.8, color: Colors.grey),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        // Use the specific shade and color contrast from other pages
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white, // Text and back button color
        centerTitle: true,
        elevation: 0,
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
                  CustomPasswordField(
                    controller: _currentPasswordController,
                    hintText: 'Current Password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // New Password Field
                  CustomPasswordField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    validator: (value) {
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
                  CustomPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm New Password',
                    validator: (value) {
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
              CustomButton(
                text: 'UPDATE PASSWORD',
                onPressed: _changePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
