// bottom_navbar.dart

import 'package:findmydorm/screen_pages/home_page.dart';
import 'package:findmydorm/screen_pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:findmydorm/dorms_directory/dorm_lists.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';

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
    return [
      const HomePage(),
      const DormList(),
      // The UserPage is passed the current user state AND the update function.
      UserPage(
        currentUser: _currentUser,
        onUserUpdated: _updateUser,
      ),
    ];
  }

  // 6. Callback function to update the user data and trigger a rebuild
  void _updateUser(Users updatedUser) {
    setState(() {
      _currentUser = updatedUser; // Update the state with the new user data
      // Rebuild the pages list to ensure the UserPage has the new data
      _pagesAll = _buildPages();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Icon(
            (myIndex == 1) ? Ionicons.heart : Ionicons.heart_outline,
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
      // Use the pages list initialized in initState
      body: _pagesAll[myIndex],
    );
  }
}
