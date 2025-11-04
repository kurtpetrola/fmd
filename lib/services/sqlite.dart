// sqlite.dart

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
        dormImageAsset TEXT DEFAULT 'assets/images/dorm_default.png',
        genderCategory TEXT DEFAULT 'Mixed/General',
        priceCategory TEXT DEFAULT 'Standard', 
        isFeatured INTEGER DEFAULT 0,
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

    // --- B. SEED STANDARD TEST USER ---
    final String testUserPasswordHash =
        BCrypt.hashpw('test123', salt); // Default password: test123

    await db.insert('users', {
      'usrName': 'TestUser',
      'usrEmail': 'test@fmd.com',
      'usrPassword': testUserPasswordHash,
      'usrAddress': '123 Testing Lane, San Fabian',
      'usrGender': 'Male',
      'usrRole': 'User', // Standard User Role
    });

    // --- C. SEED DORMITORY DATA ---
    final now = DateTime.now().toIso8601String();

    final List<Dorms> initialDorms = [
      // --- MIXED/GENERAL CATEGORY (2) ---

      // DORM 1 (Dagupan City) - Mixed/General (Luxury)
      Dorms(
        dormName: 'Anderson Hall',
        dormNumber: '101',
        dormLocation: 'Dagupan City',
        dormImageAsset: 'assets/images/dorm_general_luxury.png',
        genderCategory: 'Mixed/General',
        priceCategory: 'Luxury',
        isFeatured: true,
        latitude: 16.0354,
        longitude: 120.3346,
        dormDescription:
            'A modern dormitory located near the Dagupan City business district. Features fast Wi-Fi, 24/7 security, air-conditioned rooms, and a communal study lounge. Ideal for students prioritizing convenience and contemporary living.',
        createdAt: now,
      ),

      // DORM 2 (San Fabian) - Mixed/General (Budget-Friendly)
      Dorms(
        dormName: 'Blakely House',
        dormNumber: '202',
        dormLocation: 'San Fabian',
        dormImageAsset: 'assets/images/dorm_general_budget.png',
        genderCategory: 'Mixed/General',
        priceCategory: 'Budget-Friendly',
        isFeatured: true,
        latitude: 16.1260,
        longitude: 120.4490,
        dormDescription:
            'Blakely House offers affordable and peaceful living in San Fabian. Perfect for students seeking a quiet environment for study. Rooms are spacious with basic furnishings. Includes shared kitchen facilities and laundry area.',
        createdAt: now,
      ),

      // --- MALE DORM CATEGORY (2) ---

      // DORM 3 (Urdaneta City) - Male Dorm (Luxury)
      Dorms(
        dormName: 'Davis Hall',
        dormNumber: '404',
        dormLocation: 'Urdaneta City',
        dormImageAsset: 'assets/images/dorm_male_luxury.png',
        genderCategory: 'Male Dorm',
        priceCategory: 'Luxury',
        isFeatured: true,
        latitude: 15.9734,
        longitude: 120.5739,
        dormDescription:
            'Situated in the heart of Urdaneta City, Davis Hall provides excellent access to major transport links. High security measures, including CCTV and keycard access. All rooms feature private bathrooms and individual metering for utilities.',
        createdAt: now,
      ),

      // DORM 4 (Lingayen) - Male Dorm (Standard)
      Dorms(
        dormName: 'Edison Residence',
        dormNumber: '505',
        dormLocation: 'Lingayen',
        dormImageAsset: 'assets/images/dorm_male_budget.png',
        genderCategory: 'Male Dorm',
        priceCategory: 'Standard',
        isFeatured: true,
        latitude: 16.0220,
        longitude: 120.2320,
        dormDescription:
            'Edison Residence is conveniently located near the Provincial Capitol in Lingayen. Offers standard, well-maintained rooms with common areas for group study and recreation. Features a reliable security guard and biometric entry.',
        createdAt: now,
      ),

      // --- FEMALE DORM CATEGORY (2) ---

      // DORM 5 (Dagupan City) - Female Dorm (Luxury)
      Dorms(
        dormName: 'Grace Tower',
        dormNumber: '707',
        dormLocation: 'Dagupan City',
        dormImageAsset: 'assets/images/dorm_female_luxury.png',
        genderCategory: 'Female Dorm',
        priceCategory: 'Luxury',
        isFeatured: true,
        latitude: 16.0380,
        longitude: 120.3400,
        dormDescription:
            'An exclusive, high-end residence for female students in Dagupan. Features fully air-conditioned suites, a private pantry on each floor, and keycard-only access to enhance safety and privacy. Amenities include a roof deck garden.',
        createdAt: now,
      ),

      // DORM 6 (Alaminos City) - Female Dorm (Budget-Friendly)
      Dorms(
        dormName: 'Hana Residence',
        dormNumber: '606',
        dormLocation: 'Alaminos City',
        dormImageAsset: 'assets/images/dorm_female_budget.png',
        genderCategory: 'Female Dorm',
        priceCategory: 'Budget-Friendly',
        isFeatured: true,
        latitude: 16.1500,
        longitude: 119.9850,
        dormDescription:
            'A secure and affordable female-only dorm in Alaminos City, offering clean shared rooms with basic amenities. Excellent location near local schools and public transit, perfect for the budget-conscious student.',
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
  // DEBUG METHODS - For Development & Testing
  // ==========================================================

  /// Prints the full database path for manual inspection
  Future<void> printDatabasePath() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    print("\n═══════════════════════════════════════");
    print("DATABASE LOCATION: $path");
    print("═══════════════════════════════════════\n");
  }

  /// Prints all tables and their row counts
  Future<void> debugPrintTables() async {
    final db = await database;
    print("\n╔════════════════════════════════════════╗");
    print("║        DATABASE TABLE OVERVIEW         ║");
    print("╚════════════════════════════════════════╝");

    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var table in tables) {
      final tableName = table['name'] as String;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
      print("📊 $tableName: $count rows");
    }
    print("════════════════════════════════════════\n");
  }

  /// Prints all data from a specific table
  Future<void> debugPrintTableData(String tableName) async {
    final db = await database;
    print("\n╔════════════════════════════════════════╗");
    print("║  TABLE: $tableName");
    print("╚════════════════════════════════════════╝");

    try {
      final data = await db.query(tableName);
      if (data.isEmpty) {
        print("   (No data found)");
      } else {
        for (int i = 0; i < data.length; i++) {
          print("\n--- Row ${i + 1} ---");
          data[i].forEach((key, value) {
            print("  $key: $value");
          });
        }
      }
    } catch (e) {
      print("❌ Error reading table: $e");
    }
    print("════════════════════════════════════════\n");
  }

  /// Prints table schema (column definitions)
  Future<void> debugPrintTableSchema(String tableName) async {
    final db = await database;
    print("\n╔════════════════════════════════════════╗");
    print("║  SCHEMA: $tableName");
    print("╚════════════════════════════════════════╝");

    try {
      final schema = await db.rawQuery('PRAGMA table_info($tableName)');
      if (schema.isEmpty) {
        print("   (Table not found)");
      } else {
        for (var column in schema) {
          final name = column['name'];
          final type = column['type'];
          final notNull = column['notnull'] == 1 ? 'NOT NULL' : '';
          final pk = column['pk'] == 1 ? 'PRIMARY KEY' : '';
          print("  📌 $name: $type $notNull $pk".trim());
        }
      }
    } catch (e) {
      print("❌ Error reading schema: $e");
    }
    print("════════════════════════════════════════\n");
  }

  /// Prints everything - all tables, schemas, and data (full database dump)
  Future<void> debugPrintAllData() async {
    print("\n");
    print("═══════════════════════════════════════════════════════");
    print("           FULL DATABASE DEBUG DUMP");
    print("═══════════════════════════════════════════════════════");

    await printDatabasePath();
    await debugPrintTables();

    // Get all table names
    final db = await database;
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var table in tables) {
      final tableName = table['name'] as String;
      await debugPrintTableSchema(tableName);
      await debugPrintTableData(tableName);
    }

    print("═══════════════════════════════════════════════════════");
    print("           END OF DATABASE DUMP");
    print("═══════════════════════════════════════════════════════\n");
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

    final result = await db.insert('users', userMap);

    // DEBUG: Print updated table after user signup (comment out in production)
    print("\n✅ USER REGISTERED - Updated Users Table:");
    await debugPrintTableData('users');

    return result;
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
    final result = await db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [user.usrId],
    );

    // DEBUG: Print updated table after user update (comment out in production)
    print("\n✏️ USER UPDATED - Updated Users Table:");
    await debugPrintTableData('users');

    return result;
  }

  /// Updates only the user's password field.
  Future<int> updatePassword(int userId, String newHashedPassword) async {
    final Database db = await database;
    final Map<String, dynamic> updateMap = {
      'usrPassword': newHashedPassword,
    };
    final result = await db.update(
      'users',
      updateMap,
      where: 'usrId = ?',
      whereArgs: [userId],
    );
    // DEBUG: Print updated table after user update (comment out in production)
    print("🛠️ [DEBUG] Updated password for userId: $userId ");
    await debugPrintTableData('users');

    return result;
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
    final result = await db.insert(
      'dorms',
      dorm.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // DEBUG: Print updated table after insertion (comment out in production)
    print("\n✅ DORM INSERTED - Updated Table:");
    await debugPrintTableData('dorms');

    return result;
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
    final result = await db.update(
      'dorms',
      dorm.toSqlite(),
      where: 'dormId = ?',
      whereArgs: [dorm.dormId],
    );

    // DEBUG: Print updated table after dorm update (comment out in production)
    print("\n✏️ DORM UPDATED - Updated Dorms Table:");
    await debugPrintTableData('dorms');

    return result;
  }

  /// Deletes a dorm record by its ID.
  Future<int> deleteDorm(int id) async {
    final db = await database;
    final result = await db.delete(
      'dorms',
      where: 'dormId = ?',
      whereArgs: [id],
    );

    // DEBUG: Print updated table after dorm deletion (comment out in production)
    print("\n🗑️ DORM DELETED - Updated Dorms Table:");
    await debugPrintTableData('dorms');

    return result;
  }

  // ==========================================================
  // III. FAVORITES CRUD METHODS (Favorites Table)
  // ==========================================================

  // NOTE: These methods require the current logged-in user's ID (usrId).

// Get the total count of favorited dorms
  /// Retrieves the total count of dorms marked as favorite by a specific user.
  Future<int> getFavoriteDormsCount(int usrId) async {
    final db = await database;

    // Perform a simple COUNT query on the favorites table filtered by the user ID
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(dormId) FROM favorites WHERE usrId = ?',
      [usrId],
    );

    // Sqflite.firstIntValue is the safest way to extract a single COUNT result
    final count = Sqflite.firstIntValue(result) ?? 0;

    print("🔍 [DEBUG] User $usrId has $count favorite dorms.");
    return count;
  }

  /// Adds a dorm to the user's favorites list.
  ///
  /// Uses `ConflictAlgorithm.ignore` to prevent inserting duplicates.
  Future<int> addFavorite(int usrId, int dormId) async {
    final db = await database;
    try {
      final result = await db.insert(
        'favorites',
        {
          'usrId': usrId,
          'dormId': dormId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // DEBUG: Print updated favorites table (comment out in production)
      print("\n❤️ FAVORITE ADDED - Updated Favorites Table:");
      await debugPrintTableData('favorites');

      return result;
    } catch (e) {
      print("Error adding favorite: $e");
      return -1; // Indicate failure
    }
  }

  /// Removes a dorm from the user's favorites list.
  Future<int> removeFavorite(int usrId, int dormId) async {
    final db = await database;
    final result = await db.delete(
      'favorites',
      where: 'usrId = ? AND dormId = ?',
      whereArgs: [usrId, dormId],
    );

    // DEBUG: Print updated favorites table (comment out in production)
    print("\n💔 FAVORITE REMOVED - Updated Favorites Table:");
    await debugPrintTableData('favorites');

    return result;
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
