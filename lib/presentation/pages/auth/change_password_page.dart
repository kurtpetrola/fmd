// change_password_page.dart

import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:findmydorm/data/local/database_helper.dart';
import 'package:findmydorm/domain/models/user_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/data/services/auth_manager.dart';
import 'package:findmydorm/presentation/pages/auth/login_page.dart';

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

          // Call logout function to clear session state
          await AuthManager.logout();

          // 4. Navigate to the LoginPage and clear the entire navigation stack
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              // Replace `const LoginPage()` with the correct constructor if needed
              builder: (BuildContext context) => const LoginPage(),
            ),
            (Route<dynamic> route) => false, // Clears all previous routes
          );
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

  // --- Password Field Builder with Card Consistency ---
  Widget _buildPasswordField(
      TextEditingController controller,
      String label,
      bool isVisible,
      ValueChanged<bool> onVisibilityToggle,
      String? Function(String?) validator) {
    final Color amberColor = Colors.amber.shade700; // Define primary color

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        // Modern, filled styling
        filled: true,
        fillColor: Colors.grey.shade100,

        // Soft, rounded border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        // Themed focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: amberColor, width: 2.0),
        ),

        // Themed icon color for consistency
        prefixIcon: Icon(Ionicons.lock_closed_outline, color: amberColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Ionicons.eye_outline : Ionicons.eye_off_outline,
            color:
                Colors.grey.shade600, // Use a neutral color for secondary icon
          ),
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
                  //  Use the specific shade and white text for high contrast
                  backgroundColor: Colors.amber.shade700,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18), // Taller button
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Match field radius
                  ),
                  elevation: 6, // Make it pop
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, // White spinner for contrast
                            strokeWidth: 2.5),
                      )
                    : const Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // White text for contrast
                          letterSpacing: 0.5,
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
