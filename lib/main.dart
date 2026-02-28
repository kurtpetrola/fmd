// main.dart

import 'package:findmydorm/core/router/app_router.dart';
import 'package:findmydorm/data/local/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:findmydorm/presentation/viewmodels/auth_viewmodel.dart';
import 'package:findmydorm/presentation/viewmodels/dorm_viewmodel.dart';

// 1. Change main to async and add WidgetsFlutterBinding
Future<void> main() async {
  // This line ensures Flutter is fully initialized before we load the .env file.
  WidgetsFlutterBinding.ensureInitialized();

  // Set default status bar style to transparent with dark icons for pages without AppBars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 2. Load the .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle the error if the file is missing or corrupted (optional, but good practice)
    log("Error loading .env file: $e");
  }

  // 3. Initialize the database (this triggers onCreate if it's the first run)
  await DatabaseHelper.instance.database;

  // 4. DEBUG: Selective debugging - shows only table overview and specific tables
  // Comment out these lines in production
  log("\n🔍 DEBUGGING DATABASE ON APP START 🔍");
  await DatabaseHelper.instance.debugPrintTables();
  await DatabaseHelper.instance.debugPrintTableData('users');
  await DatabaseHelper.instance.debugPrintTableData('dorms');
  await DatabaseHelper.instance.debugPrintTableData('favorites');
  await DatabaseHelper.instance.debugPrintTableSchema('users');

  // We no longer need the 'args' parameter from the old signature, so we remove it.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DormViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
