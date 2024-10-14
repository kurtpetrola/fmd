import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/dialog/alert_dialog.dart';
import 'package:findmydorm/server/sqlite.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserState();
}

class _UserState extends State<UserPage> {
  late DatabaseHelper handler;
  late Future<List<Users>> notes;

  DateTime backPressedTime = DateTime.now();
  String title = 'AlertDialog';
  bool tappedYes = false;

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
            _buildUserInfo(),
            const SizedBox(height: 40),
            _buildProfileOption(
                'Account Settings', Ionicons.person_circle_outline),
            // Uncomment this line to add the Notifications option
            // _buildProfileOption('Notifications', Icons.notifications),
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

  Widget _buildUserInfo() {
    return Column(
      children: const [
        Text(
          'Guest',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        Text(
          'Welcome to Find My Dorm',
          style: TextStyle(
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
