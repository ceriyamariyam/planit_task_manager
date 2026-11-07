import 'package:flutter/material.dart';
import 'package:offline_task_manager/features/tasks/data/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'tasks_database.db';
  static const int _databaseVersion = 2;
  static const String tableName = 'tasks';

  // Singleton instance
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  // Getter to return existing database instance or initialize a new one
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize SQLite database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tasks table with reminderDateTime column
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority TEXT NOT NULL,
        reminderDateTime TEXT
      )
    ''');
  }

  // Handle database schema migration
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await _onCreate(db, newVersion);
    }
  }

  // // Insert single task record into database
  // Future<int> insertTask(TaskModel task) async {
  //   final db = await database;
  //   return await db.insert(
  //     tableName,
  //     task.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
  // Insert single task record into database
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    debugPrint('DatabaseHelper -> Inserting map: ${task.toMap()}');
    return await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
// Retrieve all tasks ordered by creation time descending
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final records = await db.query(
      tableName,
      orderBy: 'createdAt DESC',
    );

    debugPrint('DatabaseHelper -> Raw records from DB: $records');
    return records.map((map) => TaskModel.fromMap(map)).toList();
  }
  // // Retrieve all tasks ordered by creation time descending
  // Future<List<TaskModel>> getTasks() async {
  //   final db = await database;
  //   final records = await db.query(
  //     tableName,
  //     orderBy: 'createdAt DESC',
  //   );

  //   return records.map((map) => TaskModel.fromMap(map)).toList();
  // }

  // Update existing task record by ID
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task record by ID
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
// import 'package:offline_task_manager/features/tasks/data/models/task_model.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   static const String _databaseName = 'tasks_database.db';
//   static const int _databaseVersion = 2;
//   static const String tableName = 'tasks';

//   DatabaseHelper._internal();
//   static final DatabaseHelper instance = DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasePath = await getDatabasesPath();
//     final path = join(databasePath, _databaseName);

//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $tableName (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         title TEXT NOT NULL,
//         description TEXT,
//         createdAt TEXT NOT NULL,
//         isCompleted INTEGER NOT NULL,
//         priority TEXT NOT NULL,
//         reminderDateTime TEXT
//       )
//     ''');
//   }

//   // Drop and recreate table when database schema changes
//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < newVersion) {
//       await db.execute('DROP TABLE IF EXISTS $tableName');
//       await _onCreate(db, newVersion);
//     }
//   }

//   Future<int> insertTask(TaskModel task) async {
//     final db = await database;
//     return await db.insert(
//       tableName,
//       task.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<TaskModel>> getTasks() async {
//     final db = await database;
//     // Order by 'createdAt' matching the updated column name
//     final records = await db.query(
//       tableName,
//       orderBy: 'createdAt DESC',
//     );

//     return records.map((map) => TaskModel.fromMap(map)).toList();
//   }

//   Future<int> updateTask(TaskModel task) async {
//     final db = await database;
//     return await db.update(
//       tableName,
//       task.toMap(),
//       where: 'id = ?',
//       whereArgs: [task.id],
//     );
//   }

//   Future<int> deleteTask(int id) async {
//     final db = await database;
//     return await db.delete(
//       tableName,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<void> close() async {
//     final db = await database;
//     db.close();
//   }
// }