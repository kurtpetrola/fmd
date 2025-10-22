// server/sqlite.dart

import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';

// ==========================================================
// DatabaseHelper - Singleton Class for SQLite Operations
// ==========================================================

class DatabaseHelper {
  // --- 1. SINGLETON SETUP ---

  // Private named constructor to prevent external instantiation (Singleton)
  DatabaseHelper._privateConstructor();

  // Static final field to hold the single instance
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  // Public static getter to provide global access to the single instance
  static DatabaseHelper get instance => _instance;

  // Internal state variables
  static Database? _database;
  final String databaseName = "fmd.db";

  // --- 2. DATABASE INITIALIZATION & ACCESS ---

  /// Provides global access to the initialized database instance.
  ///
  /// Implements a lazy initialization check (`_database != null`) to ensure
  /// `_initDB()` is called only once, preventing race conditions.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // Initialize the database and assign the instance
    _database = await _initDB();
    return _database!;
  }

  /// Initializes the database by opening the file and creating tables if necessary.
  ///
  /// This method is only called once by the `database` getter.
  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    print("Database Path: $path");

    // Open the database, specifying the version and the onCreate callback
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // Consider adding onUpgrade/onDowngrade callbacks for future migrations
    );
  }

  // --- 3. SQL SCHEMA DEFINITIONS ---

  // SQL for creating the Users table
  final String _usersTableSql = """
      CREATE TABLE users (
        usrId INTEGER PRIMARY KEY AUTOINCREMENT, 
        usrName TEXT UNIQUE, 
        usrEmail TEXT UNIQUE, 
        usrPassword TEXT, 
        usrAddress TEXT, 
        usrGender TEXT, 
        usrRole TEXT DEFAULT 'User'
      )
      """;

  // SQL for creating the Dormitories table
  final String _dormsTableSql = """
      CREATE TABLE dorms (
        dormId INTEGER PRIMARY KEY AUTOINCREMENT, 
        dormNumber TEXT, 
        dormName TEXT UNIQUE, 
        dormLocation TEXT, 
        dormDescription TEXT, 
        latitude REAL, 
        longitude REAL, 
        createdAt TEXT
      )
      """;

  // SQL for creating the Favorites junction table (Many-to-Many relationship)
  final String _favoritesTableSql = """
      CREATE TABLE favorites (
        favId INTEGER PRIMARY KEY AUTOINCREMENT, 
        usrId INTEGER, 
        dormId INTEGER, 
        FOREIGN KEY(usrId) REFERENCES users(usrId), 
        FOREIGN KEY(dormId) REFERENCES dorms(dormId), 
        UNIQUE(usrId, dormId)
      )
      """;

  // --- 4. DATABASE CREATION AND SEEDING (onCreate Callback) ---

  /// Executes when the database is first created (i.e., when the version is 1).
  Future<void> _onCreate(Database db, int version) async {
    // 1. Create all necessary tables
    await db.execute(_usersTableSql);
    await db.execute(_dormsTableSql);
    await db.execute(_favoritesTableSql);

    // 2. Insert initial, mandatory data (Seeding)
    await _seedInitialData(db);
  }

  /// Inserts the initial required data (Admin User and default Dorms).
  Future<void> _seedInitialData(Database db) async {
    print("Database is empty. Inserting initial seed data...");

    // --- A. SEED ADMIN USER ---
    final String salt = BCrypt.gensalt();
    final String adminPasswordHash =
        BCrypt.hashpw('admin123', salt); // Default password: admin123

    await db.insert('users', {
      'usrName': 'AdminUser',
      'usrEmail': 'admin@fmd.com',
      'usrPassword': adminPasswordHash,
      'usrAddress': 'Database HQ',
      'usrGender': 'N/A',
      'usrRole': 'Admin', // Designated Admin Role
    });

    // --- B. SEED DORMITORY DATA ---
    final now = DateTime.now().toIso8601String();

    final List<Dorms> initialDorms = [
      // DORM 1 (Dagupan City)
      Dorms(
        dormName: 'Anderson Hall',
        dormNumber: '101',
        dormLocation: 'Dagupan City',
        latitude: 16.0354,
        longitude: 120.3346,
        dormDescription:
            'A modern dormitory located near the Dagupan City business district. Features fast Wi-Fi, 24/7 security, air-conditioned rooms, and a communal study lounge. Ideal for students prioritizing convenience and contemporary living.',
        createdAt: now,
      ),
      // DORM 2 (San Fabian)
      Dorms(
        dormName: 'Blakely House',
        dormNumber: '202',
        dormLocation: 'San Fabian',
        latitude: 16.1260,
        longitude: 120.4490,
        dormDescription:
            'Blakely House offers affordable and peaceful living in San Fabian. Perfect for students seeking a quiet environment for study. Rooms are spacious with basic furnishings. Includes shared kitchen facilities and laundry area.',
        createdAt: now,
      ),
      // DORM 3 (Mangaldan)
      Dorms(
        dormName: 'Curtis Dormitory',
        dormNumber: '303',
        dormLocation: 'Mangaldan',
        latitude: 16.0594,
        longitude: 120.4144,
        dormDescription:
            'A popular choice in Mangaldan known for its strong community atmosphere. Offers private rooms and 4-bed shared units. Amenities include a dedicated fitness corner and weekly cleaning services. Close proximity to local markets.',
        createdAt: now,
      ),
      // DORM 4 (Urdaneta City)
      Dorms(
        dormName: 'Davis Hall',
        dormNumber: '404',
        dormLocation: 'Urdaneta City',
        latitude: 15.9734,
        longitude: 120.5739,
        dormDescription:
            'Situated in the heart of Urdaneta City, Davis Hall provides excellent access to major transport links. High security measures, including CCTV and keycard access. All rooms feature private bathrooms and individual metering for utilities.',
        createdAt: now,
      ),
    ];

    for (final dorm in initialDorms) {
      await db.insert('dorms', dorm.toSqlite());
    }

    print(
        "Initial Seeding Complete: Admin user and ${initialDorms.length} dorms inserted.");
  }

  // ==========================================================
  // I. USER AUTHENTICATION & PROFILE METHODS (Users Table)
  // ==========================================================

  /// Attempts to log in a user by checking the provided password against the stored hash.
  ///
  /// On successful login, sets the global session via `AuthManager.login()`.
  Future<bool> login(Users user) async {
    final Database db = await database;
    final String identifier = user.usrName;

    // 1. Find user by username or email
    var result = await db.query(
      'users',
      columns: ['*'],
      where: 'usrName = ? OR usrEmail = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final storedHash = result.first['usrPassword'] as String;
      final plainTextPassword = user.usrPassword;

      // 2. Verify password securely using bcrypt
      final bool isPasswordValid =
          BCrypt.checkpw(plainTextPassword, storedHash);

      if (isPasswordValid) {
        // 3. SUCCESS: Set session and return true
        final Users loggedInUser = Users.fromJson(result.first);
        AuthManager.login(loggedInUser);
        return true;
      }
      return false; // Invalid password
    }
    return false; // User not found
  }

  /// Registers a new user, hashing the password before insertion.
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

    return db.insert('users', userMap);
  }

  /// Retrieves the full user record by username or email.
  Future<Users?> getUserByUsernameOrEmail(String identifier) async {
    final Database db = await database;
    var result = await db.query(
      'users',
      where: 'usrName = ? OR usrEmail = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );
    return result.isNotEmpty ? Users.fromJson(result.first) : null;
  }

  /// Retrieves the full user record by their primary ID.
  Future<Users?> getUserById(int userId) async {
    final Database db = await database;
    var result = await db.query(
      'users',
      where: 'usrId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? Users.fromJson(result.first) : null;
  }

  /// Checks if a username or email is already in use by a DIFFERENT user.
  Future<bool> isUsernameOrEmailTaken(
      int currentUserId, String username, String email) async {
    final Database db = await database;
    var result = await db.rawQuery(
      // Ensure the check excludes the user currently being edited (if currentUserId is provided)
      '''
      SELECT COUNT(*) FROM users
      WHERE (usrName = ? OR usrEmail = ?) AND usrId != ?
      ''',
      [username, email, currentUserId],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Updates a user's profile details (excluding password).
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

  /// Updates only the user's password field.
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

  /// Retrieves all user records (primarily for Admin use).
  Future<List<Users>> getAllUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    return List.generate(userMaps.length, (i) {
      return Users.fromJson(userMaps[i]);
    });
  }

  // ==========================================================
  // II. DORMITORY CRUD METHODS (Dorms Table)
  // ==========================================================

  /// Inserts a new dorm into the database.
  Future<int> insertDorm(Dorms dorm) async {
    final db = await database;
    return await db.insert(
      'dorms',
      dorm.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches all dorms from the database, ordered by name.
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

  /// Fetches a single dorm by its primary ID.
  Future<Dorms?> getDormById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dorms',
      where: 'dormId = ?',
      whereArgs: [id],
      limit: 1,
    );

    return maps.isNotEmpty ? Dorms.fromSqlite(maps.first) : null;
  }

  /// Updates an existing dorm's record.
  Future<int> updateDorm(Dorms dorm) async {
    final db = await database;
    return await db.update(
      'dorms',
      dorm.toSqlite(),
      where: 'dormId = ?',
      whereArgs: [dorm.dormId],
    );
  }

  /// Deletes a dorm record by its ID.
  Future<int> deleteDorm(int id) async {
    final db = await database;
    return await db.delete(
      'dorms',
      where: 'dormId = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================
  // III. FAVORITES CRUD METHODS (Favorites Table)
  // ==========================================================

  // NOTE: These methods require the current logged-in user's ID (usrId).

  /// Adds a dorm to the user's favorites list.
  ///
  /// Uses `ConflictAlgorithm.ignore` to prevent inserting duplicates.
  Future<int> addFavorite(int usrId, int dormId) async {
    final db = await database;
    try {
      return await db.insert(
        'favorites',
        {
          'usrId': usrId,
          'dormId': dormId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print("Error adding favorite: $e");
      return -1; // Indicate failure
    }
  }

  /// Removes a dorm from the user's favorites list.
  Future<int> removeFavorite(int usrId, int dormId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'usrId = ? AND dormId = ?',
      whereArgs: [usrId, dormId],
    );
  }

  /// Checks if a specific dorm is marked as a favorite by the user.
  Future<bool> isDormFavorite(int usrId, int dormId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'favorites',
      where: 'usrId = ? AND dormId = ?',
      whereArgs: [usrId, dormId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Retrieves the list of all dorms favorited by a given user.
  Future<List<Dorms>> getFavoriteDorms(int usrId) async {
    final db = await database;
    // Perform an INNER JOIN to fetch dorm details using the favorite record
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT d.* FROM dorms d
      INNER JOIN favorites f ON d.dormId = f.dormId
      WHERE f.usrId = ?
    ''', [usrId]);

    return List.generate(maps.length, (i) {
      return Dorms.fromSqlite(maps[i]);
    });
  }
}
