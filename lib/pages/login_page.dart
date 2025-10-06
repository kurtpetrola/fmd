import 'package:findmydorm/components/bottom_navbar.dart';
import 'package:findmydorm/models/users.dart';
import 'package:flutter/material.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'registration_page.dart';

// Assuming HomeHolder and bottom_navbar.dart exist and are correct

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  // We need two text editing controller
  final username = TextEditingController();
  final email =
      TextEditingController(); // This controller is declared but NOT used in the UI below.
  final password = TextEditingController();

  // A bool variable for show and hide password
  bool isVisible = false;

  // Here is our bool variable for error message
  bool isLoginTrue = false;

  final db = DatabaseHelper();

  // Now we should call this function in login button
  login() async {
    final enteredUsername = username.text;
    final enteredPassword = password.text;

    // 1. Check if the login is valid (using your existing boolean check logic)
    // NOTE: Your current db.login expects a full Users object.
    var isAuthenticated = await db.login(Users(
      usrName: enteredUsername,
      // Since email isn't collected on the UI, it's sent as an empty string.
      usrEmail: email.text.trim(),
      usrPassword: enteredPassword,
    ));

    if (isAuthenticated == true) {
      // 2. If login is successful, retrieve the full Users object
      Users? loggedInUser = await db.getUserByUsername(enteredUsername);

      if (!mounted) return;

      if (loggedInUser != null) {
        // 3. Navigate and PASS THE REQUIRED 'currentUser'
        // The HomeHolder now receives the user data, resolving the error.
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeHolder(currentUser: loggedInUser)));
      } else {
        // Fallback error if authentication passed but user data couldn't be retrieved
        setState(() {
          isLoginTrue = true;
        });
      }
    } else {
      // If not, true the bool value to show error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  // We have to create global key for our form
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            // We put all our textfield to a form to be controlled and not allow as empty
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  //Username field

                  //Before we show the image, after we copied the image we need to define the location in pubspec.yaml
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
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: username,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "This field is required.";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        //hintText: "Enter your username",
                        labelText: 'Username',
                      ),
                    ),
                  ),

                  //Password field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: password,
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
                          //hintText: "Enter your password",
                          suffixIcon: IconButton(
                              onPressed: () {
                                //In here we will create a click to show and hide the password a toggle button
                                setState(() {
                                  //toggle button
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),

                  const SizedBox(height: 10),
                  //Login button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.amber),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Login method will be here
                            login();

                            //Now we have a response from our sqlite method
                            //We are going to create a user
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

                  //Sign up button
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

                  // We will disable this message in default, when user and pass is incorrect we will trigger this message to user
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
