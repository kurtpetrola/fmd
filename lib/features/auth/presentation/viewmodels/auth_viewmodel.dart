import 'package:flutter/material.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findmydorm/core/database/database_helper.dart';

/// Manages user authentication state and loads saved user sessions.
class AuthViewModel extends ChangeNotifier {
  Users? _currentUser;
  bool _isLoading = true;

  static const _userIdKey = 'logged_in_user_id';

  Users? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _loadUser();
  }

  /// Loads the user from local storage initially.
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt(_userIdKey);

    if (storedUserId != null) {
      final user = await DatabaseHelper.instance.getUserById(storedUserId);
      if (user != null) {
        _currentUser = user;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Sets the current user and persists the session.
  Future<void> login(Users user) async {
    _currentUser = user;
    notifyListeners();

    if (user.usrId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, user.usrId!);
    }
  }

  /// Clears the current user and removes the saved session.
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  /// Updates the current user's profile data in state if the ID matches.
  Future<void> updateUserProfile(Users updatedUser) async {
    if (_currentUser?.usrId == updatedUser.usrId) {
      _currentUser = updatedUser;
      notifyListeners();

      // We don't need to persist the user data here because DatabaseHelper already does it.
      // We only store the userId in SharedPreferences, which hasn't changed.
    }
  }
}
