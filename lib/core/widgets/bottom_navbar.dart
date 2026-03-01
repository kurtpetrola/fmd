// bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:findmydorm/features/dorms/presentation/pages/home_page.dart';
import 'package:findmydorm/features/dorms/presentation/pages/dorm_lists.dart';
import 'package:findmydorm/features/dorms/presentation/pages/admin_page.dart';
import 'package:findmydorm/features/user_profile/presentation/pages/user_page.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';

// -------------------------------------------------------------------
// ## HOME HOLDER WIDGET
// -------------------------------------------------------------------

class HomeHolder extends StatefulWidget {
  // Navigation arguments are typically untyped in go_router's extra,
  // but we don't strictly need it passed in anymore if it's in Provider.
  // Keeping it as optional for backwards compatibility during migration if needed,
  // but not required.
  final Users? currentUser;

  const HomeHolder({super.key, this.currentUser});

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
    // No longer initialize local _currentUser state from widget property;
    // we use Provider now.
  }

  // -------------------------------------------------------------------
  // ## BUSINESS LOGIC (State Management & Navigation)
  // -------------------------------------------------------------------

  // We no longer need _updateUser since AuthViewModel handles it.
  // The pages reading the provider will rebuild automatically.

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
  List<Widget> _buildPages(Users currentUser) {
    final bool isAdmin = currentUser.usrRole == 'Admin';

    return [
      // 0: Home Page
      HomePage(
        onViewAllTap: () =>
            navigateToTab(1), // Navigates to Dorm List/Admin Page
      ),

      // 1: Dorm List or Admin Page (Role-based)
      isAdmin ? const AdminPage() : const DormList(initialSearchQuery: null),

      // 2: User Profile Page
      UserPage(
        // The key is reset in the onTap of the navbar to force rebuild.
        key: _userPageKey,
      ),
    ];
  }

  // -------------------------------------------------------------------
  // ## WIDGET BUILDER (UI)
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Read the current user state from the AuthViewModel.
    // This will cause a rebuild if the user logs out or modifies their profile.
    final authVM = context.watch<AuthViewModel>();
    final currentUser = authVM.currentUser;

    // Safety check in case the user was logged out while on this screen
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Color primaryAmber = Colors.amber.shade700;
    final bool isAdmin = currentUser.usrRole == 'Admin';

    return Scaffold(
      // --- SMOOTH NAVIGATION BODY: IndexedStack to preserve page state ---
      body: IndexedStack(
        index: myIndex,
        // CRITICAL: Call _buildPages() here to ensure pages are rebuilt
        // when state (like _currentUser) changes.
        children: _buildPages(currentUser),
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
