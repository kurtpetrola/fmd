// user_page.dart - MODIFIED

import 'package:findmydorm/screen_pages/account_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/dialog/alert_dialog.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'package:findmydorm/pages/favorite_dorms_page.dart';

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
  final DatabaseHelper handler = DatabaseHelper.instance; // Cleaner syntax

  // FIX: Re-add the missing state variables
  DateTime backPressedTime = DateTime.now();
  String title = 'AlertDialog';
  bool tappedYes = false; // <--- ADD THIS LINE BACK

  @override
  void initState() {
    super.initState();
  }

// NEW Helper method to navigate to the Favorites Page
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildUserIcon(),
            const SizedBox(height: 15),
            _buildUserInfo(widget.currentUser),
            const SizedBox(height: 40),

            // FAVORITES BUTTON (NEW)
            GestureDetector(
              onTap: _navigateToFavorites,
              child:
                  _buildProfileOption('My Favorites', Ionicons.heart_outline),
            ),
            const SizedBox(height: 10),

            // ACCOUNT SETTINGS BUTTON
            GestureDetector(
              onTap: _navigateToSettings,
              child: _buildProfileOption(
                  'Account Settings', Ionicons.person_circle_outline),
            ),
            const SizedBox(height: 10),

            // SIGN OUT BUTTON
            _buildSignOutOption(context),
            const SizedBox(height: 20),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return const Icon(
      Ionicons.person,
      size: 80,
      color: Colors.amber,
    );
  }

  Widget _buildUserInfo(Users user) {
    return Column(
      children: [
        Text(
          user.usrName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        Text(
          'Welcome to Find My Dorm',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.deepPurple.withOpacity(.2),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Lato',
          ),
        ),
        leading: Icon(iconData, color: Colors.black),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildSignOutOption(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
      child: _buildProfileOption('Sign Out', Ionicons.log_out_outline),
    );
  }
}
