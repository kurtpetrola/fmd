import 'package:flutter/material.dart';

/// Centralized color constants for the application.
///
/// This class provides a single source of truth for all brand and
/// functional colors, ensuring consistency across the UI.
class AppColors {
  // Brand Colors
  static const Color transparent = Colors.transparent;
  static const Color primaryAmber = Color(0xFFFF8F00); // Colors.amber.shade800
  static const Color primaryAmberShade700 =
      Color(0xFFFFA000); // Colors.amber.shade700
  static const Color primaryAmberShade400 =
      Color(0xFFFFCA28); // Colors.amber.shade400
  static const Color primaryAmberShade100 =
      Color(0xFFFFECB3); // Colors.amber.shade100

  // Background & Surface Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Colors.grey.shade50
  static const Color surfaceLight = Color(0xFFFFFFFF); // Colors.white
  static const Color inputFill = Color(0xFFF5F5F5); // Colors.grey.shade100

  // Text Colors
  static const Color textPrimary = Color(0xDE000000); // Colors.black87
  static const Color textSecondary = Color(0x8A000000); // Colors.black54
  static const Color textWhite = Color(0xFFFFFFFF); // Colors.white
  static const Color textHint = Color(0xFF9E9E9E); // Colors.grey

  // Functional Colors
  static const Color error = Color(0xFFD32F2F); // Colors.red.shade700
  static const Color errorContainer = Color(0xFFFFEBEE); // Colors.red.shade100
  static const Color errorBorder = Color(0xFFEF5350); // Colors.red.shade400
  static const Color success = Color(0xFF388E3C); // Colors.green.shade700
  static const Color successContainer =
      Color(0xFFE8F5E9); // Colors.green.shade100
  static const Color borderLight = Color(0xFFE0E0E0); // Colors.grey.shade300

  // Neutral Shades
  static const Color grey200 = Color(0xFFEEEEEE); // Colors.grey.shade200
  static const Color grey300 = Color(0xFFE0E0E0); // Colors.grey.shade300
  static const Color grey400 = Color(0xFFBDBDBD); // Colors.grey.shade400
  static const Color grey500 = Color(0xFF9E9E9E); // Colors.grey.shade500
  static const Color grey600 = Color(0xFF757575); // Colors.grey.shade600
  static const Color grey700 = Color(0xFF616161); // Colors.grey.shade700
  static const Color black54 = Color(0x8A000000);
  static const Color black87 = Color(0xDE000000);

  // Map Specific Colors
  static const Color mapBlue = Color(0xFF1976D2); // Colors.blue.shade700
  static const Color mapBlueDark = Color(0xFF0D47A1); // Colors.blue.shade900
  static const Color walkGreen = Color(0xFF388E3C); // Colors.green.shade700
  static const Color wazeOrange = Colors.orange;

  // Category Colors
  static const Color genderFemale = Color(0xFFF8BBD0); // Colors.pink.shade100
  static const Color genderMale = Color(0xFFBBDEFB); // Colors.blue.shade100
  static const Color genderMixed = Color(0xFFEEEEEE); // Colors.grey.shade200
  static const Color priceBudget = Color(0xFFC8E6C9); // Colors.green.shade100
  static const Color priceLuxury = Color(0xFFE1BEE7); // Colors.purple.shade100
  static const Color priceStandard =
      Color(0xFFFFE0B2); // Colors.orange.shade100

  // Feature Specific
  static const Color favoriteRed = Color(0xFFEF5350); // Colors.red.shade400
  static const Color securityOrange =
      Color(0xFFFF3D00); // Colors.deepOrangeAccent
  static const Color detailPurple = Color(0xFF673AB7); // Colors.deepPurple
  static const Color detailPurpleLight =
      Color(0xFFEDE7F6); // Colors.deepPurple.shade50

  // Private constructor to prevent instantiation
  AppColors._();
}
