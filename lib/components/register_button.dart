import 'package:flutter/material.dart';
import 'package:findmydorm/pages/registration_page.dart';

class RegisterButton extends StatelessWidget {
  final Function()? onPressed;

  const RegisterButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => SignUpScreen()));
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size(250, 55), // Sets minimum width and height
        elevation: 2, // Adds a small shadow
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 55),
        child: Text(
          "REGISTER",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
