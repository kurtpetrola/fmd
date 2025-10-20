// main.dart

import 'package:findmydorm/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1. Change main to async and add WidgetsFlutterBinding
Future<void> main() async {
  // This line ensures Flutter is fully initialized before we load the .env file.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle the error if the file is missing or corrupted (optional, but good practice)
    print("Error loading .env file: $e");
  }

  // We no longer need the 'args' parameter from the old signature, so we remove it.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
