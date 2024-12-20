import 'package:flutter/material.dart';
import 'package:findmydorm/pages/login_page.dart';

class LoginButton extends StatelessWidget {
  final Function()? onPressed;

  const LoginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size(250, 55), // This sets a minimum width and height
        elevation: 2, // Adds a small shadow
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 55),
        child: Text(
          "LOGIN",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
