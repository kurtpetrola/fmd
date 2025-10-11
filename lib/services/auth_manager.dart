//auth_manager.dart

import 'package:findmydorm/models/users.dart';

// This is a simple in-memory session manager.
// In a real application, you would use Shared Preferences or a state management solution (like Provider, Riverpod, BLoC)
// to manage the current user and persist login status across app restarts.
class AuthManager {
  static Users? _currentUser;

  // Getter to check if a user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Getter to retrieve the current user object
  static Users? get currentUser => _currentUser;

  // Getter to safely retrieve the current user's ID
  // Returns null if no user is logged in
  static int? get currentUserId => _currentUser?.usrId;

  // Sets the current user upon successful login/signup
  static void login(Users user) {
    _currentUser = user;
    print("User ${user.usrName} (${user.usrId}) is now logged in.");
  }

  // Clears the current user upon logout
  static void logout() {
    _currentUser = null;
    print("User logged out.");
  }
}
