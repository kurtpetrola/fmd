// login_page.dart

import 'package:findmydorm/components/bottom_navbar.dart';
import 'package:findmydorm/models/users.dart';
import 'package:flutter/material.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  // Use a more generic name since it accepts Username OR Email
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoginTrue = false;
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  // NOTE: You must also add the getUserByUsernameOrEmail function to your sqlite.dart
  // (see section 3 below) to make this logic work.
  login() async {
    final enteredIdentifier = identifierController.text.trim();
    final enteredPassword = passwordController.text.trim();

    // 1. Attempt login verification.
    // The db.login will check the enteredIdentifier against usrName OR usrEmail.
    var isAuthenticated = await db.login(Users(
      usrName:
          enteredIdentifier, // Used as the identifier for the OR check in DB
      usrEmail: '', // Placeholder
      usrPassword: enteredPassword,
      usrAddress: '', // Placeholder
      usrGender: '', // Placeholder
    ));

    if (isAuthenticated == true) {
      // 2. If login is successful, retrieve the full Users object using the same identifier
      Users? loggedInUser =
          await db.getUserByUsernameOrEmail(enteredIdentifier);

      if (!mounted) return;

      if (loggedInUser != null) {
        // Successful Login
        setState(() {
          isLoginTrue = false; // Clear any previous error messages
        });

        // Navigate and pass the full, correct Users object
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeHolder(currentUser: loggedInUser)));
      } else {
        // This case should ideally not happen if login() was true, but is a safety net
        _showError();
      }
    } else {
      // Failed Login
      _showError();
    }
  }

  void _showError() {
    setState(() {
      isLoginTrue = true; // Show the error message
    });
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo1.png",
                    height: 200,
                  ),
                  const Text(
                    'Find My Dorm',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 15),

                  // Username/Email field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller:
                          identifierController, // Using the new controller name
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username or Email is required.";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        // FIX: Change label to reflect accepted inputs
                        labelText: 'Username or Email Address',
                      ),
                    ),
                  ),

                  // Password field (Controller name updated to passwordController)
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller:
                          passwordController, // Using the new controller name
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "This field is required.";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          labelText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Login button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.amber),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            login(); // Calls the updated login logic
                          }
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        )),
                  ),

                  // Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account yet?"),
                      TextButton(
                          onPressed: () {
                            //Navigate to sign up
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen()));
                          },
                          child: const Text("Register now"))
                    ],
                  ),

                  // Error message
                  isLoginTrue
                      ? const Text(
                          "Username or password is incorrect",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
