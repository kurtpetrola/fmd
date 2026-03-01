import 'package:flutter/material.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

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
        return AppColors.genderFemale;
      case 'Male Dorm':
        return AppColors.genderMale;
      default:
        return AppColors.genderMixed;
    }
  }

  static Color getPriceColor(String category) {
    switch (category) {
      case 'Budget-Friendly':
        return AppColors.priceBudget;
      case 'Luxury':
        return AppColors.priceLuxury;
      default:
        return AppColors.priceStandard;
    }
  }
}
