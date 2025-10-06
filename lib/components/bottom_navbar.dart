// import 'package:findmydorm_mobile/pages/favorite_screen.dart';
import 'package:findmydorm/screen_pages/home_page.dart';
import 'package:findmydorm/screen_pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:findmydorm/dorms_directory/dorm_lists.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart'; // <--- Import your Users model

class HomeHolder extends StatefulWidget {
  // 1. Define the required currentUser field
  final Users currentUser;

  // 2. Update the constructor to require currentUser
  const HomeHolder({super.key, required this.currentUser});

  @override
  State<HomeHolder> createState() => _HomeHolderState();
}

class _HomeHolderState extends State<HomeHolder> {
  GlobalKey _navKey = GlobalKey();

  // Create a list of widget pages outside of build()
  late final List<Widget> pagesAll;

  var myIndex = 0;

  @override
  void initState() {
    super.initState();
    // 3. Initialize the list of pages in initState, passing the user data
    pagesAll = [
      const HomePage(),
      const DormList(),
      // PASS THE REQUIRED 'currentUser' HERE!
      UserPage(currentUser: widget.currentUser),
    ];
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
      body: pagesAll[myIndex],
    );
  }
}
