// account_settings_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/auth/change_password_page.dart';

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
  final dbHelper = DatabaseHelper.instance;

  // 1. STATE VARIABLE TO HOLD LOCAL USER DATA
  late Users _localUser;

  // State variable to manage View (false) vs Edit (true) mode
  bool _isEditing = false;

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  late String _selectedGender;

  bool _isLoading = false;
  String? _errorMessage;

  // Define the list of options for the Gender dropdown
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // 2. INITIALIZE LOCAL USER FROM WIDGET PROPERTY
    _localUser = widget.user;

    // Initialize controllers with the current user data (from _localUser now)
    _usernameController = TextEditingController(text: _localUser.usrName);
    _emailController = TextEditingController(text: _localUser.usrEmail);
    _addressController = TextEditingController(text: _localUser.usrAddress);

    // INITIALIZE GENDER STATE
    _selectedGender = _localUser.usrGender;
  }

  // NOTE: If the UserPage were to update the user object while this page
  // is on the screen, didUpdateWidget would be needed, but since this
  // page is modal, we can skip that for simplicity.

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Helper method to toggle the editing mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _errorMessage = null; // Clear error message when toggling mode
    });

    // Restore controllers and state to current widget data when CANCELING edit mode
    if (!_isEditing) {
      _usernameController.text = _localUser.usrName;
      _emailController.text = _localUser.usrEmail;
      _addressController.text = _localUser.usrAddress;
      _selectedGender = _localUser.usrGender; // Restore Gender
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newAddress = _addressController.text.trim();
    final newGender = _selectedGender;

    // Check if anything has actually changed (use _localUser for comparison)
    if (newUsername == _localUser.usrName &&
        newEmail == _localUser.usrEmail &&
        newAddress == _localUser.usrAddress &&
        newGender == _localUser.usrGender) {
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
        _localUser.usrId!, // Use local user ID
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
        usrId: _localUser.usrId,
        usrName: newUsername,
        usrEmail: newEmail,
        usrPassword: _localUser.usrPassword,
        usrAddress: newAddress,
        usrGender: newGender,
      );

      // 3. Persist the changes to the database
      int rowsAffected = await dbHelper.updateUser(updatedUser);

      if (rowsAffected > 0) {
        // 4. Update the local state FIRST, then notify the parent, then switch modes
        if (mounted) {
          setState(() {
            _localUser = updatedUser; // <<< THE KEY FIX: UPDATE LOCAL STATE
          });
        }

        // 5. Update the parent state via the callback
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
          child: _buildCommonBody(),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## Common Body Builder for View and Edit Mode
  // --------------------------------------------------------------------------

  Widget _buildCommonBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 1. Conditional Header/Title (Use _localUser)
        if (_isEditing)
          _buildEditModeTitle()
        else
          _buildProfileHeader(context, _localUser.usrName, _localUser.usrEmail),

        // 2. Account Details Card (View or Edit fields)
        _isEditing ? _buildEditModeCard() : _buildViewModeCard(),

        // 3. Security Card (Always visible, separate from details)
        _buildSecurityCard(),

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

        // 4. Save button (only visible in Edit Mode)
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
    );
  }

  // --- Compact Title for Edit Mode ---
  Widget _buildEditModeTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Text(
        'Update Your Profile Information',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## Profile Header (View Mode Only)
  // --------------------------------------------------------------------------

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.20;
    const minHeight = 150.0;

    return Container(
      height: headerHeight > minHeight ? headerHeight : minHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## Component Builders (Shared)
  // --------------------------------------------------------------------------

  // --- Info Row (for key-value display) ---
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple.shade400, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Generic Card Container for Info Grouping ---
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

  // --- Security Card (Change Password) ---
  Widget _buildSecurityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: const Icon(Ionicons.key_outline,
            color: Colors.redAccent), // Highlight security
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Ionicons.chevron_forward),
        onTap: () {
          // Pass the updated local user object to ChangePasswordPage
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangePasswordPage(user: _localUser),
            ),
          );
        },
      ),
    );
  }

  // --- Helper for consistent TextFormField styling ---
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  // --------------------------------------------------------------------------
  // ## View Mode (Read-Only)
  // --------------------------------------------------------------------------

  Widget _buildViewModeCard() {
    // Returns a single card for account details in view mode
    return _buildInfoCard(
      title: 'Account Details',
      children: [
        // Address (Uses _localUser)
        _buildInfoRow(
            Ionicons.location_outline, 'Address', _localUser.usrAddress),
        const Divider(height: 0, indent: 45),
        // Gender (Uses _localUser)
        _buildInfoRow(Ionicons.people_outline, 'Gender', _localUser.usrGender),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // ## Edit Mode (Consistent Card Design)
  // --------------------------------------------------------------------------

  Widget _buildEditModeCard() {
    // Returns a single card containing all editable fields
    return _buildInfoCard(
      title: 'Edit Account Details',
      children: [
        // ... (TextFormFields and Dropdown remain the same, bound to controllers)
        // Editable Username Field
        _buildTextFormField(
          controller: _usernameController,
          label: 'Username',
          icon: Ionicons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username cannot be empty.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Editable Email Field
        _buildTextFormField(
          controller: _emailController,
          label: 'Email Address',
          icon: Ionicons.mail,
          keyboardType: TextInputType.emailAddress,
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
        const SizedBox(height: 15),

        // Editable Address Field
        _buildTextFormField(
          controller: _addressController,
          label: 'Address',
          icon: Ionicons.location,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address cannot be empty.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Editable Gender Dropdown
        DropdownButtonFormField<String>(
          value: _selectedGender.isNotEmpty &&
                  _genderOptions.contains(_selectedGender)
              ? _selectedGender
              : null,
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Ionicons.people),
          ),
          items: _genderOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Gender cannot be empty.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
