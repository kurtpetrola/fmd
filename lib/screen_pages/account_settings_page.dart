// account_settings_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart'; // Assuming you use ionicons
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/server/sqlite.dart';

class AccountSettingsPage extends StatefulWidget {
  final Users user;
  final ValueChanged<Users> onUserUpdated;

  const AccountSettingsPage({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  // State variable to manage View (false) vs Edit (true) mode
  bool _isEditing = false;

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current user data
    _usernameController = TextEditingController(text: widget.user.usrName);
    _emailController = TextEditingController(text: widget.user.usrEmail);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Helper method to toggle the editing mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _errorMessage = null; // Clear error message when toggling mode
    });

    // CRITICAL FIX: Update controllers when entering edit mode,
    // ensuring they reflect the latest data from the parent widget (widget.user).
    if (_isEditing) {
      _usernameController.text = widget.user.usrName;
      _emailController.text = widget.user.usrEmail;
    }

    // OPTIONAL: If switching back to view mode, reset controllers to current saved values
    // (This handles the case where the user started editing but hit the "Cancel/Close" icon)
    if (!_isEditing) {
      // Since saving also calls _toggleEditMode(), this ensures the saved data is displayed
      // when returning to the view.
      _usernameController.text = widget.user.usrName;
      _emailController.text = widget.user.usrEmail;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();

    // Check if anything has actually changed
    if (newUsername == widget.user.usrName &&
        newEmail == widget.user.usrEmail) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes detected.')),
        );
        _toggleEditMode(); // Exit edit mode since nothing changed
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Check if the new username or email is already taken
      bool isTaken = await dbHelper.isUsernameOrEmailTaken(
        widget.user.usrId!,
        newUsername,
        newEmail,
      );

      if (isTaken) {
        setState(() {
          _errorMessage = 'Username or Email is already taken by another user.';
        });
        return;
      }

      // 2. Create a new Users object with the updated details
      final updatedUser = Users(
        usrId: widget.user.usrId,
        usrName: newUsername,
        usrEmail: newEmail,
        usrPassword: widget.user.usrPassword,
      );

      // 3. Persist the changes to the database
      int rowsAffected = await dbHelper.updateUser(updatedUser);

      if (rowsAffected > 0) {
        // 4. Update the local state in HomeHolder via the callback
        widget.onUserUpdated(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          _toggleEditMode(); // Exit edit mode after saving
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to update user profile in the database.';
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
        title: Text(_isEditing ? 'Edit Profile' : 'Account Settings'),
        backgroundColor: Colors.amber,
        actions: [
          // Toggle button to switch between View and Edit mode
          IconButton(
            icon: Icon(_isEditing
                ? Ionicons.close_circle_outline
                : Ionicons.create_outline),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Cancel Editing' : 'Start Editing',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'User Profile Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const Divider(height: 30, thickness: 2),

              // Conditional UI rendering based on the editing state
              _isEditing ? _buildEditModeFields() : _buildViewModeFields(),

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

              // Save button (only visible in Edit Mode)
              if (_isEditing)
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
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
                          'SAVE CHANGES',
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

  // --- Widget Builders for Read-Only View Mode ---

  Widget _buildViewModeFields() {
    return Column(
      children: [
        // View Username
        ListTile(
          leading: const Icon(Ionicons.person, color: Colors.deepPurple),
          title: const Text(
            'Username',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.user.usrName,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        // View Email
        ListTile(
          leading: const Icon(Ionicons.mail, color: Colors.deepPurple),
          title: const Text(
            'Email Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.user.usrEmail,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // --- Widget Builders for Editable Mode ---

  Widget _buildEditModeFields() {
    return Column(
      children: [
        // Editable Username Field
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Ionicons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username cannot be empty.';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Editable Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Ionicons.mail),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email cannot be empty.';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
