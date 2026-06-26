import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine_guide.db');
    await _checkAndSeed(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
        // Load the compressed database from assets
        final ByteData data = await rootBundle.load(
          join('assets', 'database', 'preseeded_medicines.db.gz'),
        );
        final List<int> compressedBytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        // Decompress the database using GZipCodec
        final List<int> decompressedBytes = GZipCodec().decode(compressedBytes);

        // Write the decompressed database to local documents
        await File(path).writeAsBytes(decompressedBytes, flush: true);
        debugPrint(
          'Successfully decompressed and copied preseeded database from assets',
        );
      } catch (e) {
        debugPrint('Error decompressing preseeded database: $e');
      }
    }

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicineName TEXT,
            time TEXT,
            daysOfWeek TEXT,
            isActive INTEGER,
            doseDescription TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicineName TEXT,
            scannedAt TEXT,
            isOffline INTEGER,
            imagePath TEXT,
            prescriptionMedicinesJson TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
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
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT,
        time TEXT,
        daysOfWeek TEXT,
        isActive INTEGER,
        doseDescription TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT,
        scannedAt TEXT,
        isOffline INTEGER,
        imagePath TEXT,
        prescriptionMedicinesJson TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineName TEXT,
          time TEXT,
          daysOfWeek TEXT,
          isActive INTEGER,
          doseDescription TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineName TEXT,
          scannedAt TEXT,
          isOffline INTEGER
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE history ADD COLUMN imagePath TEXT');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE history ADD COLUMN prescriptionMedicinesJson TEXT',
        );
      } catch (_) {}
    }
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
      final row = Map<String, dynamic>.from(results.first);
      final genericName = row['genericName'] as String? ?? '';

      try {
        final alternatives = await db.query(
          'medicines',
          columns: ['name', 'manufacturer', 'price'],
          where: 'LOWER(genericName) = ? AND LOWER(name) != ?',
          whereArgs: [genericName.toLowerCase(), name.toLowerCase()],
          limit: 3,
        );

        final mappedAlternatives = alternatives
            .map(
              (alt) => {
                'name': alt['name'],
                'manufacturer': alt['manufacturer'],
                'price': alt['price'] ?? 'N/A',
              },
            )
            .toList();

        row['genericAlternativesJson'] = jsonEncode(mappedAlternatives);
      } catch (_) {
        row['genericAlternativesJson'] = '[]';
      }
      return row;
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
    final medicineName = row['medicineName'] as String? ?? '';
    final imagePath = row['imagePath'] as String?;

    List<Map<String, dynamic>> existing = [];
    if (imagePath != null && imagePath.isNotEmpty) {
      existing = await db.query(
        'history',
        where: 'imagePath = ?',
        whereArgs: [imagePath],
      );
    } else {
      existing = await db.query(
        'history',
        where:
            'LOWER(medicineName) = ? AND (imagePath IS NULL OR imagePath = "")',
        whereArgs: [medicineName.toLowerCase()],
      );
    }

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'history',
        {
          'scannedAt': row['scannedAt'],
          'isOffline': row['isOffline'],
          if (row.containsKey('prescriptionMedicinesJson'))
            'prescriptionMedicinesJson': row['prescriptionMedicinesJson'],
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    } else {
      return await db.insert('history', row);
    }
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

  Future<void> _checkAndSeed(Database db) async {
    try {
      final countResult = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM medicines'),
      );
      if (countResult == null || countResult < 20000) {
        debugPrint(
          'Database has incomplete data ($countResult rows). Re-copying preseeded database...',
        );
        try {
          await db.close();
        } catch (_) {}
        _database = null;

        final dbPath = await getDatabasesPath();
        final path = join(dbPath, 'medicine_guide.db');
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }

        _database = await _initDB('medicine_guide.db');
      }
    } catch (_) {}
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final results = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
