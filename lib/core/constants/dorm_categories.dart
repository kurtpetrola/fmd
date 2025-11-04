// dorm_categories.dart

import 'package:flutter/material.dart';

class DormCategories {
  // Available category options
  static const List<String> genderCategories = [
    'Female Dorm',
    'Male Dorm',
    'Mixed/General',
  ];

  static const List<String> priceCategories = [
    'Budget-Friendly',
    'Standard',
    'Luxury',
  ];

  // Get display info for categories
  static String getGenderIcon(String category) {
    switch (category) {
      case 'Female Dorm':
        return '♀️';
      case 'Male Dorm':
        return '♂️';
      default:
        return '👥';
    }
  }

  static String getPriceIcon(String category) {
    switch (category) {
      case 'Budget-Friendly':
        return '💰';
      case 'Luxury':
        return '✨';
      default:
        return '🏠';
    }
  }

  // Get colors for chips/badges
  static Color getGenderColor(String category) {
    switch (category) {
      case 'Female Dorm':
        return Colors.pink.shade100;
      case 'Male Dorm':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  static Color getPriceColor(String category) {
    switch (category) {
      case 'Budget-Friendly':
        return Colors.green.shade100;
      case 'Luxury':
        return Colors.purple.shade100;
      default:
        return Colors.orange.shade100;
    }
  }
}
