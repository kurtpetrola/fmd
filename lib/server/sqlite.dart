// sqlite.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:findmydorm/models/users.dart';
import 'package:bcrypt/bcrypt.dart'; // <<< Required for secure password hashing

class DatabaseHelper {
  // Use a private field to hold the database instance
  static Database? _database;
  final databaseName = "fmd.db";

  // Table creation strings
  String noteTable =
      "CREATE TABLE notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  String users =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrEmail TEXT UNIQUE, usrPassword TEXT, usrAddress TEXT, usrGender TEXT)";

  String dorms =
      "CREATE TABLE dorms (dormId INTEGER PRIMARY KEY AUTOINCREMENT,dormNumber INTEGER, dormName TEXT UNIQUE, dormLocation TEXT)";

  // Optimized Database Initialization
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    // openDatabase will call onCreate only if the database did not exist.
    // NOTE: If you are changing the table structure, you must increase 'version'
    // and implement an 'onUpgrade' method, OR completely uninstall the app
    // to force 'onCreate' to run again.
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
      await db.execute(dorms);
    });
  }

  // Login Method (Securely checks password against the stored hash)
  Future<bool> login(Users user) async {
    final Database db = await database;

    // The 'user.usrName' field is assumed to be the user's input (either a username OR an email)
    final String identifier = user.usrName;

    // 1. Fetch the user's record (specifically the hashed password)
    // using an OR condition to allow login by Username OR Email.
    var result = await db.query(
      'users',
      // Get the password hash, and the username/email (for context/debugging)
      columns: ['usrPassword'],
      // NEW WHERE CLAUSE: Check the identifier against EITHER usrName OR usrEmail
      where: 'usrName = ? OR usrEmail = ?',
      whereArgs: [identifier, identifier], // Pass the identifier twice
      limit: 1,
    );

    if (result.isNotEmpty) {
      final storedHash = result.first['usrPassword'] as String;
      final plainTextPassword = user.usrPassword;

      // 2. Safely verify the plaintext password against the hash.
      final bool isPasswordValid =
          BCrypt.checkpw(plainTextPassword, storedHash);

      return isPasswordValid;
    } else {
      // User not found (either by username or email)
      return false;
    }
  }

  // SignUp Method (Hashes the password before insertion)
  Future<int> signup(Users user) async {
    final Database db = await database;

    final String salt = BCrypt.gensalt();
    final String hashedPassword = BCrypt.hashpw(user.usrPassword, salt);

    // UPDATED: Include new fields (usrAddress, usrGender) in the map
    final Map<String, dynamic> userMap = {
      'usrName': user.usrName,
      'usrEmail': user.usrEmail,
      'usrPassword': hashedPassword,
      'usrAddress': user.usrAddress, // <<< New Field
      'usrGender': user.usrGender, // <<< New Field
    };

    return db.insert(
      'users',
      userMap,
    );
  }

  // Method to retrieve all users
  Future<List<Users>> getAllUsers() async {
    final Database db = await database;

    // 1. Query the 'users' table for ALL rows.
    // The result is a List<Map<String, dynamic>>, where each Map is a row.
    final List<Map<String, dynamic>> userMaps = await db.query('users');

    // 2. Convert the List<Map<String, dynamic>> into a List<Users>.
    return List.generate(userMaps.length, (i) {
      // We use your existing Users.fromJson (or Users.fromMap, if you created one)
      // to transform the database row (Map) into a Users object.
      return Users.fromJson(userMaps[i]);
    });
  }

  // Retrieves the full user record using either the username or the email.
  Future<Users?> getUserByUsernameOrEmail(String identifier) async {
    final Database db = await database;

    // Query the 'users' table using an OR condition
    var result = await db.query(
      'users',
      where: 'usrName = ? OR usrEmail = ?', // Checks both columns
      whereArgs: [identifier, identifier],
      limit: 1, // Expect only one match
    );

    if (result.isNotEmpty) {
      // Convert the result map into a Users object
      return Users.fromJson(result.first);
    } else {
      return null; // User not found
    }
  }

// Checks if the new username or email is already in use by ANOTHER user.
  Future<bool> isUsernameOrEmailTaken(
      int currentUserId, String username, String email) async {
    final Database db = await database;

    // The query checks for any user (WHERE) whose usrName matches the new one OR
    // whose usrEmail matches the new one, AND whose usrId is NOT the current user's ID.
    var result = await db.rawQuery(
      '''
    SELECT COUNT(*) 
    FROM users 
    WHERE (usrName = ? OR usrEmail = ?) AND usrId != ?
    ''',
      [username, email, currentUserId],
    );

    // The count is in the first row and first column of the result list.
    int count = Sqflite.firstIntValue(result) ?? 0;

    // If count > 0, the username or email is already taken by someone else.
    return count > 0;
  }

  // Updates a user's record in the database.
  Future<int> updateUser(Users user) async {
    final Database db = await database;

    // Create a map containing the fields to update (excluding usrId and usrPassword)
    // We exclude usrPassword because we aren't changing it in this flow.
    final Map<String, dynamic> updateMap = {
      'usrName': user.usrName,
      'usrEmail': user.usrEmail,
      'usrAddress': user.usrAddress,
      'usrGender': user.usrGender,
      // Note: The password field should remain the old hash,
      // but since the original Users object (with the hash) is passed,
      // we can just convert it all to JSON and let it update the row.
      // However, it's safer to only update the fields that change:
    };

    // We only update the name, email address and gender here.
    return db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [user.usrId], // Ensure the correct user is updated
    );
  }

  // Updates the user's password field in the database with a new hash.
  Future<int> updatePassword(int userId, String newHashedPassword) async {
    final Database db = await database;

    // Create a map containing only the password field to update
    final Map<String, dynamic> updateMap = {
      'usrPassword': newHashedPassword,
    };

    // Update the row based on the user ID
    return db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [userId],
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      usrId INTEGER PRIMARY KEY, 
      usrName TEXT NOT NULL, 
      usrEmail TEXT NOT NULL, 
      usrPassword TEXT NOT NULL,
      -- ADD NEW COLUMNS HERE
      usrAddress TEXT NOT NULL,
      usrGender TEXT NOT NULL
    )
  ''');
  }
}
