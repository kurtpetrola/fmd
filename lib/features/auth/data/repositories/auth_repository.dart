import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';

/// Abstracts all authentication and user-related database operations.
///
/// This repository acts as a single point of access for user data,
/// decoupling ViewModels and pages from the [DatabaseHelper] implementation.
class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Attempts to log in a user by checking credentials.
  /// Returns the authenticated [Users] object on success, or null.
  Future<Users?> login(Users user) => _dbHelper.login(user);

  /// Registers a new user, hashing the password before insertion.
  Future<int> signup(Users user) => _dbHelper.signup(user);

  /// Retrieves a user by their primary ID.
  Future<Users?> getUserById(int userId) => _dbHelper.getUserById(userId);

  /// Verifies if a user exists by matching email and address.
  /// Used for password recovery flows.
  Future<Users?> verifyUserByEmailAndAddress(String email, String address) =>
      _dbHelper.verifyUserByEmailAndAddress(email, address);

  /// Checks if a username or email is already taken by a different user.
  Future<bool> isUsernameOrEmailTaken(
          int currentUserId, String username, String email) =>
      _dbHelper.isUsernameOrEmailTaken(currentUserId, username, email);

  /// Updates a user's profile details (excluding password).
  Future<int> updateUser(Users user) => _dbHelper.updateUser(user);

  /// Updates only the user's password using the User ID.
  Future<int> updatePassword(int userId, String newHashedPassword) =>
      _dbHelper.updatePassword(userId, newHashedPassword);

  /// Updates a user's password using their email (auto-hashes the password).
  Future<int> updatePasswordByEmail(String email, String newPassword) =>
      _dbHelper.updatePasswordByEmail(email, newPassword);
}
