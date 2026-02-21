// auth_manager.dart

import 'package:findmydorm/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findmydorm/data/local/database_helper.dart';
import 'dart:developer';

class AuthManager {
  static Users? _currentUser;
  static const _userIdKey = 'logged_in_user_id'; // Key for SharedPreferences

  static bool get isLoggedIn => _currentUser != null;
  static Users? get currentUser => _currentUser;
  static int? get currentUserId => _currentUser?.usrId;

  // Allows external classes to update the in-memory user object
  static void updateCurrentUser(Users updatedUser) {
    if (_currentUser?.usrId == updatedUser.usrId) {
      _currentUser = updatedUser;
      log("AuthManager: Current user data updated in memory.");
    } else {
      log("AuthManager: Failed to update user - ID mismatch or no user logged in.");
    }
  }

  // Login: Saves the user to memory and persists the ID locally
  static void login(Users user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    // Only persist the ID if it's not null (shouldn't be after a successful login)
    if (user.usrId != null) {
      await prefs.setInt(_userIdKey, user.usrId!);
    }
    log("User ${user.usrName} (${user.usrId}) is now logged in. Status saved.");
  }

  // Logout: Clears the user from memory and removes the ID from local storage
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();

    // Remove the persisted user ID from SharedPreferences
    await prefs.remove(_userIdKey);

    log("User logged out. Status cleared.");
  }

  // Load the persisted user status on app startup
  static Future<bool> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt(_userIdKey);

    if (storedUserId != null) {
      // Use the new method from your DatabaseHelper
      final user = await DatabaseHelper.instance.getUserById(storedUserId);

      if (user != null) {
        _currentUser = user; // Set the static in-memory session
        log("Persisted user ${user.usrName} loaded.");
        return true;
      }
    }

    _currentUser = null; // No persisted user or user not found in DB
    return false;
  }
}
