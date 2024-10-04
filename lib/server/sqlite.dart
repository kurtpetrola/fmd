import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:findmydorm/models/users.dart';

class DatabaseHelper {
  final databaseName = "fmd.db";
  String noteTable =
      "CREATE TABLE notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  // Now we must create our user table into our sqlite db

  String users =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrEmail TEXT UNIQUE, usrPassword TEXT)";

  String dorms =
      "CREATE TABLE dorms (dormId INTEGER PRIMARY KEY AUTOINCREMENT,dormNumberINTEGER, dormName TEXT UNIQUE, dormLocation TEXT)";

  // We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(noteTable);
      await db.execute(dorms);
    });
  }

  // Now we create login and sign up method

  // Login
  Future<bool> login(Users user) async {
    final Database db = await initDB();

    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where usrName = '${user.usrName}' AND usrPassword = '${user.usrPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // SignUp
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toJson());
  }
}
