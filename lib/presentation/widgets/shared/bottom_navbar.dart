// bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:findmydorm/domain/models/user_model.dart';
import 'package:findmydorm/presentation/pages/dorms/home_page.dart';
import 'package:findmydorm/presentation/pages/dorms/dorm_lists.dart';
import 'package:findmydorm/presentation/pages/dorms/admin_page.dart';
import 'package:findmydorm/presentation/pages/user_profile/user_page.dart';

// -------------------------------------------------------------------
// ## HOME HOLDER WIDGET
// -------------------------------------------------------------------

class HomeHolder extends StatefulWidget {
  final Users currentUser;

  const HomeHolder({super.key, required this.currentUser});

  @override
  State<HomeHolder> createState() => _HomeHolderState();
}

class _HomeHolderState extends State<HomeHolder> {
  // -------------------------------------------------------------------
  // ## FIELDS & STATE
  // -------------------------------------------------------------------
  final GlobalKey _navKey = GlobalKey();

  // Used to manage the index of the CurvedNavigationBar and IndexedStack.
  int myIndex = 0;

  // Mutable state variable to hold the current user data.
  late Users _currentUser;

  /*
    CRITICAL: Key to force a rebuild of the UserPage.
    When the UserPage is navigated to, this key is reset, forcing Flutter
    to discard the old UserPage state and run its initState() again,
    which is useful for refreshing data that might have changed on another tab.
  */
  GlobalKey _userPageKey = GlobalKey();

  // -------------------------------------------------------------------
  // ## LIFECYCLE METHODS
  // -------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Initialize the current user state from the widget property.
    _currentUser = widget.currentUser;
  }

  // -------------------------------------------------------------------
  // ## BUSINESS LOGIC (State Management & Navigation)
  // -------------------------------------------------------------------

  /// Updates the user data stored in the state. Called via callbacks from child widgets.
  void _updateUser(Users updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
  }

  /// Changes the bottom navigation index and updates the UI.
  void navigateToTab(int index) {
    setState(() {
      myIndex = index;

      // OPTIONAL: Resetting the UserPage key here as well, in case navigation comes
      // from a non-navbar source (e.g., Home Page's onViewAllTap).
      if (index == 2) {
        _userPageKey = GlobalKey();
      }
    });
  }

  /// Generates the list of pages based on the current user's role.
  List<Widget> _buildPages() {
    final bool isAdmin = _currentUser.usrRole == 'Admin';

    return [
      // 0: Home Page
      HomePage(
        currentUser: _currentUser,
        onUserUpdated: _updateUser,
        onViewAllTap: () =>
            navigateToTab(1), // Navigates to Dorm List/Admin Page
      ),

      // 1: Dorm List or Admin Page (Role-based)
      isAdmin ? const AdminPage() : const DormList(initialSearchQuery: null),

      // 2: User Profile Page
      UserPage(
        // The key is reset in the onTap of the navbar to force rebuild.
        key: _userPageKey,
        currentUser: _currentUser,
        onUserUpdated: _updateUser,
      ),
    ];
  }

  // -------------------------------------------------------------------
  // ## WIDGET BUILDER (UI)
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUser.usrRole == 'Admin';
    final Color primaryAmber = Colors.amber.shade700;

    return Scaffold(
      // --- SMOOTH NAVIGATION BODY: IndexedStack to preserve page state ---
      body: IndexedStack(
        index: myIndex,
        // CRITICAL: Call _buildPages() here to ensure pages are rebuilt
        // when state (like _currentUser) changes.
        children: _buildPages(),
      ),

      // --- CURVED BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: CurvedNavigationBar(
        color: primaryAmber,
        backgroundColor: Colors.transparent,
        key: _navKey,
        index: myIndex,
        height: 60.0,
        items: [
          // Item 0: Home
          Icon(
            (myIndex == 0) ? Ionicons.home : Ionicons.home_outline,
            color: Colors.white,
          ),
          // Item 1: List (User) / Admin (Admin)
          Icon(
            isAdmin
                ? (myIndex == 1)
                    ? Ionicons.hammer
                    : Ionicons.hammer_outline
                : (myIndex == 1)
                    ? Ionicons.list
                    : Ionicons.list_outline,
            color: Colors.white,
          ),
          // Item 2: Profile
          Icon(
            (myIndex == 2) ? Ionicons.person : Ionicons.person_outline,
            color: Colors.white,
          ),
        ],
        buttonBackgroundColor: primaryAmber,
        onTap: (index) {
          setState(() {
            // CRITICAL FIX: If the target index is the UserPage (index 2),
            // reset the key to force the UserPage to run its initState().
            if (index == 2) {
              _userPageKey = GlobalKey();
            }
            myIndex = index;
          });
        },
        animationCurve: Curves.easeInOutQuad,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
