// user_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/core/widgets/alert_dialog.dart';
import 'package:findmydorm/pages/selection_page.dart';
import 'package:findmydorm/features/user_profile/pages/account_settings_page.dart';
import 'package:findmydorm/features/user_profile/pages/favorite_dorms_page.dart';

// --------------------------------------------------------------------------
// ## WIDGET DEFINITION
// --------------------------------------------------------------------------
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
  // --------------------------------------------------------------------------
  // ## FIELDS & DATABASE
  // --------------------------------------------------------------------------
  final DatabaseHelper handler = DatabaseHelper.instance;

  // State variable to hold the favorite count for the badge
  int _favoriteCount = 0;

  // --------------------------------------------------------------------------
  // ## LIFECYCLE METHODS
  // --------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    // This is called when the widget is first created or when the key is reset.
    _fetchFavoriteCount();
  }

  // --------------------------------------------------------------------------
  // ## DATA FETCHING & LOGIC
  // --------------------------------------------------------------------------
  /// Fetches the current favorite count from the database and updates the state.
  Future<void> _fetchFavoriteCount() async {
    if (widget.currentUser.usrId == null) return;

    final count =
        await handler.getFavoriteDormsCount(widget.currentUser.usrId!);

    if (mounted) {
      setState(() {
        _favoriteCount = count;
      });
    }
  }

  // --------------------------------------------------------------------------
  // ## NAVIGATION HANDLERS
  // --------------------------------------------------------------------------
  /// Navigates to the Favorites Page and refreshes the count on return.
  void _navigateToFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteDormsPage(
          currentUser: widget.currentUser,
        ),
      ),
    );

    // Refresh the favorite count when the user returns
    _fetchFavoriteCount();
  }

  /// Navigates to the Account Settings page.
  void _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountSettingsPage(
          user: widget.currentUser,
          onUserUpdated: widget.onUserUpdated,
        ),
      ),
    );

    // Trigger a rebuild of the UserPage's UI if needed (e.g., if username changed)
    if (mounted) {
      setState(() {});
    }
  }

  /// Handles the sign-out process.
  void _handleSignOut() async {
    final action = await AlertDialogs.yesCancelDialog(
      context,
      'Log out of your account?',
      'You can always come back any time.',
    );

    if (action == DialogsAction.yes) {
      // 1. Log out (clears SharedPreferences)
      await AuthManager.logout();

      // 2. Navigate and clear the stack.
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const SelectionPage(),
        ),
        (Route<dynamic> route) => false, // Clears all previous routes
      );
    }
  }

  // --------------------------------------------------------------------------
  // ## WIDGET BUILDER METHODS
  // --------------------------------------------------------------------------
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
              // My Favorites
              _buildProfileOption('My Favorites', Ionicons.heart_outline,
                  _navigateToFavorites, Colors.redAccent,
                  trailingWidget: _buildFavoritesBadge()),

              // Account Settings
              _buildProfileOption(
                  'Account Settings',
                  Ionicons.person_circle_outline,
                  _navigateToSettings,
                  Colors.deepPurple),
            ]),
            const SizedBox(height: 15),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: _buildSignOutOption(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds the badge showing the count of favorite dorms.
  Widget _buildFavoritesBadge() {
    // If count is zero, just return the forward chevron icon.
    if (_favoriteCount == 0) {
      return const Icon(Ionicons.chevron_forward, color: Colors.grey);
    }

    // If count > 0, return a Stack with the chevron and the badge.
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Ionicons.chevron_forward, color: Colors.grey),
        Positioned(
          right: 1,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red, // Standard badge color
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              '$_favoriteCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the main profile information card.
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

  /// Wraps a list of profile options in a card with dividers.
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

  /// Builds a single, tappable profile option ListTile.
  Widget _buildProfileOption(
      String title, IconData iconData, VoidCallback onTap, Color iconColor,
      {Widget? trailingWidget}) {
    return ListTile(
      leading: Icon(iconData, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailingWidget ??
          const Icon(Ionicons.chevron_forward, color: Colors.grey),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
    );
  }

  /// Builds the Sign Out option, using the _buildProfileOption for structure.
  Widget _buildSignOutOption() {
    // Note: Removed context argument as it's available via build/State
    return _buildProfileOption(
      'Sign Out',
      Ionicons.log_out_outline,
      _handleSignOut,
      Colors.red,
    );
  }
}
