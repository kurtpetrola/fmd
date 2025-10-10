// server/sqlite.dart

import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  static Database? _database;
  final databaseName = "fmd.db";

  String noteTable =
      "CREATE TABLE notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  String users =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrEmail TEXT UNIQUE, usrPassword TEXT, usrAddress TEXT, usrGender TEXT, usrRole TEXT DEFAULT 'User')";

  String dormsTable =
      "CREATE TABLE dorms (dormId INTEGER PRIMARY KEY AUTOINCREMENT, dormNumber TEXT, dormName TEXT UNIQUE, dormLocation TEXT,latitude REAL, longitude REAL, createdAt TEXT)";

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

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
      await db.execute(dormsTable);

      // ==========================================================
      // >>> ADMIN USER & DORM SEEDING (Inside onCreate) <<<
      // ==========================================================

      final String salt = BCrypt.gensalt();
      final String adminPasswordHash =
          BCrypt.hashpw('admin123', salt); // Admin password: admin123

      // 1. SEED ADMIN USER
      await db.insert('users', {
        'usrName': 'AdminUser',
        'usrEmail': 'admin@fmd.com',
        'usrPassword': adminPasswordHash,
        'usrAddress': 'Database HQ',
        'usrGender': 'N/A',
        'usrRole': 'Admin', // KEEP: Admin Role
      });

      // 2. SEED DORMITORY DATA (Reverted to old constructor)
      print("DATABASE IS EMPTY. Inserting initial dorm data...");
      final now = DateTime.now().toIso8601String();

      // DORM 1 (Dagupan City - Example)
      await db.insert(
          'dorms',
          Dorms(
                  dormName: 'Anderson Hall',
                  dormNumber: '101',
                  dormLocation: 'Dagupan City',
                  latitude: 16.0354, // NEW
                  longitude: 120.3346, // NEW
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: now)
              .toSqlite());

      // DORM 2 (San Fabian - Example)
      await db.insert(
          'dorms',
          Dorms(
                  dormName: 'Blakely House',
                  dormNumber: '202',
                  dormLocation: 'San Fabian',
                  latitude: 16.1260, // NEW
                  longitude: 120.4490, // NEW
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: now)
              .toSqlite());

      // DORM 3 (Mangaldan - Example)
      await db.insert(
          'dorms',
          Dorms(
                  dormName: 'Curtis Dormitory',
                  dormNumber: '303',
                  dormLocation: 'Mangaldan',
                  latitude: 16.0594, // NEW
                  longitude: 120.4144, // NEW
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: now)
              .toSqlite());

      // DORM 4 (Urdaneta City - Example)
      await db.insert(
          'dorms',
          Dorms(
                  dormName: 'Davis Hall',
                  dormNumber: '404',
                  dormLocation: 'Urdaneta City',
                  latitude: 15.9734, // NEW
                  longitude: 120.5739, // NEW
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: now)
              .toSqlite());

      print("Initial Seeding Complete: Admin user and 4 dorms inserted.");
      // ==========================================================
    });
  }

  // --- All other CRUD methods remain the same ---

  // Login Method (Securely checks password against the stored hash)
  Future<bool> login(Users user) async {
    final Database db = await database;
    final String identifier = user.usrName;
    // ... (logic remains the same) ...
    var result = await db.query(
      'users',
      columns: ['usrPassword'],
      where: 'usrName = ? OR usrEmail = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final storedHash = result.first['usrPassword'] as String;
      final plainTextPassword = user.usrPassword;
      final bool isPasswordValid =
          BCrypt.checkpw(plainTextPassword, storedHash);
      return isPasswordValid;
    } else {
      return false; // User not found
    }
  }

  // SignUp Method (Hashes the password before insertion)
  Future<int> signup(Users user) async {
    final Database db = await database;
    final String salt = BCrypt.gensalt();
    final String hashedPassword = BCrypt.hashpw(user.usrPassword, salt);

    final Map<String, dynamic> userMap = {
      'usrName': user.usrName,
      'usrEmail': user.usrEmail,
      'usrPassword': hashedPassword,
      'usrAddress': user.usrAddress,
      'usrGender': user.usrGender,
      'usrRole': user.usrRole,
    };

    return db.insert(
      'users',
      userMap,
    );
  }

  // Method to retrieve all users (remains the same)
  Future<List<Users>> getAllUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    return List.generate(userMaps.length, (i) {
      return Users.fromJson(userMaps[i]);
    });
  }

  // Retrieves the full user record (remains the same)
  Future<Users?> getUserByUsernameOrEmail(String identifier) async {
    final Database db = await database;
    var result = await db.query(
      'users',
      where: 'usrName = ? OR usrEmail = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Users.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Checks if the new username or email is already in use (remains the same)
  Future<bool> isUsernameOrEmailTaken(
      int currentUserId, String username, String email) async {
    final Database db = await database;
    var result = await db.rawQuery(
      '''
    SELECT COUNT(*) 
    FROM users 
    WHERE (usrName = ? OR usrEmail = ?) AND usrId != ?
    ''',
      [username, email, currentUserId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // Updates a user's record (remains the same)
  Future<int> updateUser(Users user) async {
    final Database db = await database;
    final Map<String, dynamic> updateMap = {
      'usrName': user.usrName,
      'usrEmail': user.usrEmail,
      'usrAddress': user.usrAddress,
      'usrGender': user.usrGender,
    };
    return db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [user.usrId],
    );
  }

  // Updates the user's password field (remains the same)
  Future<int> updatePassword(int userId, String newHashedPassword) async {
    final Database db = await database;
    final Map<String, dynamic> updateMap = {
      'usrPassword': newHashedPassword,
    };
    return db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [userId],
    );
  }

  // --- DORMITORY CRUD OPERATIONS ---

  // 1. CREATE: Insert a new dorm (uses reverted toSqlite)
  Future<int> insertDorm(Dorms dorm) async {
    final db = await database;
    return await db.insert(
      'dorms',
      dorm.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. READ: Fetch all dorms (uses reverted fromSqlite)
  Future<List<Dorms>> getDorms() async {
    final db = await database;
    print("Attempting to query 'dorms' table...");
    final List<Map<String, dynamic>> maps =
        await db.query('dorms', orderBy: 'dormName ASC');
    print("Query successful. Found ${maps.length} dorms.");

    return List.generate(maps.length, (i) {
      try {
        return Dorms.fromSqlite(maps[i]);
      } catch (e) {
        print("Error converting map to Dorms object: $e");
        print("Problematic Map: ${maps[i]}");
        rethrow;
      }
    });
  }

  // 3. READ: Fetch a single dorm by its ID (remains the same)
  Future<Dorms?> getDormById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dorms',
      where: 'dormId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Dorms.fromSqlite(maps.first);
    }
    return null;
  }

  // 4. UPDATE: Update an existing dorm (uses reverted toSqlite)
  Future<int> updateDorm(Dorms dorm) async {
    final db = await database;
    return await db.update(
      'dorms',
      dorm.toSqlite(),
      where: 'dormId = ?',
      whereArgs: [dorm.dormId],
    );
  }

  // 5. DELETE: Delete a dorm by ID (remains the same)
  Future<int> deleteDorm(int id) async {
    final db = await database;
    return await db.delete(
      'dorms',
      where: 'dormId = ?',
      whereArgs: [id],
    );
  }
}
