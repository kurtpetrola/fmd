import 'package:findmydorm/screen_pages/account_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/dialog/alert_dialog.dart';
import 'package:findmydorm/server/sqlite.dart';

class UserPage extends StatefulWidget {
  // 1. Define a final variable to hold the Users object
  final Users currentUser;

  // Accept the update callback function
  final ValueChanged<Users> onUserUpdated;

  const UserPage({
    super.key,
    required this.currentUser,
    required this.onUserUpdated, // ADD THIS
  });

  @override
  State<UserPage> createState() => _UserState();
}

class _UserState extends State<UserPage> {
  // We no longer need Future<List<Users>> notes here unless you intend to
  // display notes on this page, but we'll keep the handler for potential future use.
  late DatabaseHelper handler;

  DateTime backPressedTime = DateTime.now();
  String title = 'AlertDialog';
  bool tappedYes = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    // The user data is now available via widget.currentUser
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
            // 4. Pass the currentUser object to the info widget
            _buildUserInfo(widget.currentUser),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                // Navigate to the AccountSettingsPage
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AccountSettingsPage(
                      user: widget.currentUser,
                      // PASS THE CALLBACK FUNCTION DOWN!
                      onUserUpdated: widget.onUserUpdated,
                    ),
                  ),
                );
              },
              child: _buildProfileOption(
                  'Account Settings', Ionicons.person_circle_outline),
            ),
            const SizedBox(height: 10),
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

  // 3. Update the method signature to accept the Users object
  Widget _buildUserInfo(Users user) {
    return Column(
      children: [
        Text(
          // Use the username from the passed Users object
          user.usrName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        Text(
          // Optionally, display the email here
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
