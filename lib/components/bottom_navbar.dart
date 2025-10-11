// bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/pages/home_page.dart';
import 'package:findmydorm/features/user_profile/pages/user_page.dart';
import 'package:findmydorm/features/dorms/admin/admin_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:findmydorm/features/dorms/pages/dorm_lists.dart';

class HomeHolder extends StatefulWidget {
  // 1. The initial user object received from the LoginPage
  final Users currentUser;

  const HomeHolder({super.key, required this.currentUser});

  @override
  State<HomeHolder> createState() => _HomeHolderState();
}

class _HomeHolderState extends State<HomeHolder> {
  GlobalKey _navKey = GlobalKey();

  // 2. Mutable state variable to hold the current user data.
  // We use 'late' because it will be initialized in initState.
  late Users _currentUser;

  // 3. Mutable list of pages, which will be built with the current user state.
  late List<Widget> _pagesAll;
  var myIndex = 0;

  @override
  void initState() {
    super.initState();
    // 4. Initialize the late fields in the correct lifecycle stage (initState)
    // using the data passed to the widget.
    _currentUser = widget.currentUser;
    // Build the initial list of pages
    _pagesAll = _buildPages();
  }

// 5. Function to rebuild the pages with the updated user data
  List<Widget> _buildPages() {
    final bool isAdmin = _currentUser.usrRole == 'Admin';

    return [
      const HomePage(),

      // Conditional Page Load: Admin gets CRUD page, User gets view list.
      isAdmin
          ? const AdminPage() // ADMIN: Full CRUD control
          : const DormList(), // USER: View-only dynamic list

      UserPage(
        currentUser: _currentUser,
        onUserUpdated: _updateUser,
      ),
    ];
  }

// 6. Callback function to update the user data and trigger a rebuild
  void _updateUser(Users updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      _pagesAll = _buildPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUser.usrRole == 'Admin';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        key: _navKey,
        items: [
          Icon(
            (myIndex == 0) ? Ionicons.home : Ionicons.home_outline,
            color: Colors.white,
          ),
          // Icon based on role: Hammer for Admin, List for User
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
          Icon(
            (myIndex == 2) ? Ionicons.person : Ionicons.person_outline,
            color: Colors.white,
          ),
        ],
        buttonBackgroundColor: Colors.amber,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        animationCurve: Curves.fastLinearToSlowEaseIn,
        color: Colors.amber,
      ),
      body: _pagesAll[myIndex],
    );
  }
}
