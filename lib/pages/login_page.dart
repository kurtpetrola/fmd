// login_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/components/bottom_navbar.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoginTrue = false;
  String errorMessage = "Username or password is incorrect";

  final db = DatabaseHelper.instance;
  final formKey = GlobalKey<FormState>();

  // --- Core Login Logic ---
  login() async {
    final enteredIdentifier = identifierController.text.trim();
    final enteredPassword = passwordController.text.trim();

    try {
      // 1. Attempt login verification using the identifier and password
      var isAuthenticated = await db.login(Users(
        usrName:
            enteredIdentifier, // Used as the identifier for the OR check in DB
        usrEmail: '', // Placeholder
        usrPassword: enteredPassword,
        usrAddress: '', // Placeholder
        usrGender: '', // Placeholder
      ));

      if (isAuthenticated == true) {
        // 2. If login is successful, retrieve the full Users object (needed for role and details)
        Users? loggedInUser =
            await db.getUserByUsernameOrEmail(enteredIdentifier);

        // Crucial check before using context or setState
        if (!mounted) return;

        if (loggedInUser != null) {
          // Successful Login
          setState(() {
            isLoginTrue = false; // Clear any previous error messages
          });

          // 3. Navigate and pass the full, correct Users object to HomeHolder
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeHolder(currentUser: loggedInUser)));
        } else {
          // Fallback error if authentication passed but user data couldn't be fetched
          _showError(message: "User data not found after successful login.");
        }
      } else {
        // Failed Login (Incorrect credentials)
        _showError(message: "Username or password is incorrect.");
      }
    } catch (e) {
      // Catch any unexpected exceptions during database access
      if (mounted) {
        _showError(message: "An unexpected error occurred: ${e.toString()}");
      }
      // Print to console for debugging purposes
      print("Login Exception: ${e.toString()}");
    }
  }

  void _showError({String message = "Username or password is incorrect"}) {
    setState(() {
      isLoginTrue = true; // Show the red error text field
      errorMessage = message; // Update the message
    });
    // Also display a SnackBar for quick user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                      controller: identifierController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username or Email is required.";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        labelText: 'Username or Email Address',
                      ),
                    ),
                  ),

                  // Password field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: passwordController,
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
                            // Clear previous errors before attempting new login
                            setState(() {
                              isLoginTrue = false;
                            });
                            login(); // Calls the async login logic
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

                  // Error message display
                  isLoginTrue
                      ? Text(
                          errorMessage, // Display the dynamic error message
                          style: const TextStyle(color: Colors.red),
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
