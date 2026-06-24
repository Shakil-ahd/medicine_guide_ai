import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine_guide.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        genericName TEXT,
        manufacturer TEXT,
        indications TEXT,
        sideEffects TEXT,
        dosage TEXT,
        instructions TEXT,
        price TEXT,
        genericAlternativesJson TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT,
        time TEXT,
        daysOfWeek TEXT,
        isActive INTEGER,
        doseDescription TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT,
        scannedAt TEXT,
        isOffline INTEGER
      )
    ''');
  }

  Future<int> insertMedicine(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'medicines',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getMedicineByName(String name) async {
    final db = await instance.database;
    final results = await db.query(
      'medicines',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> insertReminder(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('reminders', row);
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await instance.database;
    return await db.query('reminders', orderBy: 'time ASC');
  }

  Future<int> updateReminder(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('reminders', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    final db = await instance.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('history', row);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'scannedAt DESC');
  }

  Future<int> deleteHistoryItem(int id) async {
    final db = await instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
