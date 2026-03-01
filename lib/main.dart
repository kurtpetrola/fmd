// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/core/router/app_router.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/core/theme/app_theme.dart';
import 'package:findmydorm/core/theme/app_colors.dart';
import 'dart:developer';

import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:findmydorm/features/dorms/presentation/viewmodels/dorm_viewmodel.dart';

/// App entry point.
Future<void> main() async {
  /// Ensure Flutter is fully initialized before loading the .env file.
  WidgetsFlutterBinding.ensureInitialized();

  /// Set default status bar style for pages without AppBars.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  /// Load the environment variables.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    /// Handle the error if the file is missing or corrupted.
    log("Error loading .env file: $e");
  }

  /// Initialize the database (this triggers onCreate if it's the first run).
  await DatabaseHelper.instance.database;

  /// DEBUG: Selective debugging. Comment out these lines in production.
  log("\n🔍 DEBUGGING DATABASE ON APP START 🔍");
  await DatabaseHelper.instance.debugPrintTables();
  await DatabaseHelper.instance.debugPrintTableData('users');
  await DatabaseHelper.instance.debugPrintTableData('dorms');
  await DatabaseHelper.instance.debugPrintTableData('favorites');
  await DatabaseHelper.instance.debugPrintTableSchema('users');

  /// Initialize the app with providers.
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

/// The main application widget setting up routing and theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}
