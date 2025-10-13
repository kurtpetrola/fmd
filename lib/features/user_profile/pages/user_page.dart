// user_page.dart

import 'package:findmydorm/features/user_profile/pages/account_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/core/utils/alert_dialog.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/user_profile/pages/favorite_dorms_page.dart';

class UserPage extends StatefulWidget {
  final Users currentUser;
  final ValueChanged<Users> onUserUpdated;

  const UserPage({
    super.key,
    required this.currentUser,
    required this.onUserUpdated,
  });

  @override
  State<UserPage> createState() => _UserState();
}

class _UserState extends State<UserPage> {
  final DatabaseHelper handler = DatabaseHelper.instance;

  DateTime backPressedTime = DateTime.now();
  String title = 'AlertDialog';
  bool tappedYes = false;

  @override
  void initState() {
    super.initState();
  }

  // Helper method to navigate to the Favorites Page
  void _navigateToFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteDormsPage(
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  // Helper method to navigate to the Account Settings and re-fetch favorites if needed
  void _navigateToSettings() async {
    // Navigate to the AccountSettingsPage
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountSettingsPage(
          user: widget.currentUser,
          onUserUpdated: widget.onUserUpdated,
        ),
      ),
    );

    // FIX: Trigger a rebuild of the UserPage's UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeaderCard(widget.currentUser),
            const SizedBox(height: 30),

            _buildSettingsGroup([
              _buildProfileOption('My Favorites', Ionicons.heart_outline,
                  _navigateToFavorites, Colors.redAccent),
              _buildProfileOption(
                  'Account Settings',
                  Ionicons.person_circle_outline,
                  _navigateToSettings,
                  Colors.deepPurple),
            ]),
            const SizedBox(height: 15),

            // 4. UPDATED SIGN OUT BUTTON WITH BORDER
            Card(
              // Wrap in Card for consistent elevation and rounded corners
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: _buildSignOutOption(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## PROFILE HEADER CARD
  // --------------------------------------------------------------------------
  Widget _buildProfileHeaderCard(Users user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple,
            child: Text(
              user.usrName.isNotEmpty ? user.usrName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            user.usrName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
              color: Colors.deepPurple,
            ),
          ),
          Text(
            user.usrEmail,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lato',
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Welcome to Find My Dorm',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lato',
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## SETTINGS GROUPING CARD (Used for Favorites and Settings)
  // --------------------------------------------------------------------------
  Widget _buildSettingsGroup(List<Widget> options) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            options[i],
            if (i < options.length - 1)
              const Divider(height: 1, indent: 20, endIndent: 20),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ## PROFILE OPTION
  // --------------------------------------------------------------------------
  Widget _buildProfileOption(
      String title, IconData iconData, VoidCallback onTap, Color iconColor) {
    return ListTile(
      leading: Icon(iconData, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Ionicons.chevron_forward, color: Colors.grey),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
    );
  }

  // --------------------------------------------------------------------------
  // ## SIGN OUT OPTION (Now wrapped in a Card for border/elevation consistency)
  // --------------------------------------------------------------------------
  Widget _buildSignOutOption(BuildContext context) {
    return _buildProfileOption(
      'Sign Out',
      Ionicons.log_out_outline,
      () async {
        final action = await AlertDialogs.yesCancelDialog(
          context,
          'Log out of your account?',
          'You can always come back any time.',
        );
        if (action == DialogsAction.yes) {
          setState(() => tappedYes = true);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const SelectionPage(),
            ),
          );
        } else {
          setState(() => tappedYes = false);
        }
      },
      Colors.red,
    );
  }
}
