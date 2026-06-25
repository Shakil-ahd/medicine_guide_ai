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
    await _checkAndSeed(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
        await db.execute('ALTER TABLE history ADD COLUMN prescriptionMedicinesJson TEXT');
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
        where: 'LOWER(medicineName) = ? AND (imagePath IS NULL OR imagePath = "")',
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
      if (countResult == 0) {
        await _seedDatabase(db);
      }
    } catch (_) {}
  }

  Future<void> _seedDatabase(Database db) async {
    final List<Map<String, dynamic>> initialMedicines = [
      {
        'name': 'Napa',
        'genericName': 'Paracetamol',
        'manufacturer': 'Beximco Pharmaceuticals Ltd.',
        'indications': 'জ্বর, মাথাব্যথা, দাঁত ব্যথা এবং শরীর ব্যথার উপশম।',
        'sideEffects': 'সাধারণত পার্শ্বপ্রতিক্রিয়া নেই। তবে অতিরিক্ত মাত্রায় সেবনে লিভারের ক্ষতি হতে পারে।',
        'dosage': 'প্রাপ্তবয়স্ক: ১-২টি ট্যাবলেট দিনে ৩-৪ বার।',
        'instructions': 'খাবারের পর পর্যাপ্ত জল দিয়ে সেবন করুন।',
        'price': '৳১.২ / ট্যাবলেট',
        'genericAlternativesJson': '[{"name":"Ace","manufacturer":"Square Pharmaceuticals","price":"৳১.২"},{"name":"Fast","manufacturer":"Acme Laboratories","price":"৳১.২"},{"name":"Pyrexin","manufacturer":"Incepta","price":"৳১.০"}]',
      },
      {
        'name': 'Napa Extra',
        'genericName': 'Paracetamol + Caffeine',
        'manufacturer': 'Beximco Pharmaceuticals Ltd.',
        'indications': 'তীব্র মাথাব্যথা, মাইগ্রেন, দাঁত ব্যথা এবং জ্বরের দ্রুত উপশম।',
        'sideEffects': 'বুক ধড়ফড় করা, অনিদ্রা বা অস্থিরতা (ক্যাফেইনের কারণে)।',
        'dosage': 'প্রাপ্তবয়স্ক: ১-২টি ট্যাবলেট দিনে ৩-৪ বার।',
        'instructions': 'খাবারের পর পর্যাপ্ত জল দিয়ে সেবন করুন। রাতে ঘুমানোর আগে না নেওয়া ভালো।',
        'price': '৳২.৫ / ট্যাবলেট',
        'genericAlternativesJson': '[{"name":"Ace Plus","manufacturer":"Square Pharmaceuticals","price":"৳২.৫"},{"name":"Fast Plus","manufacturer":"Acme Laboratories","price":"৳২.৫"},{"name":"Extraol","manufacturer":"Incepta","price":"৳২.২"}]',
      },
      {
        'name': 'Seclo 20',
        'genericName': 'Omeprazole 20mg',
        'manufacturer': 'Square Pharmaceuticals Ltd.',
        'indications': 'গ্যাস্ট্রিক আলসার, বুক জ্বালাপোড়া, এসিডিটি এবং গ্যাস্ট্রিকের সমস্যা উপশম।',
        'sideEffects': 'মাথাব্যথা, ডায়রিয়া, কোষ্ঠকাঠিন্য বা পেট ফাঁপা।',
        'dosage': '১টি ক্যাপসুল দিনে ১-২ বার।',
        'instructions': 'খাবারের ৩০ মিনিট আগে খালি পেটে সেবন করুন।',
        'price': '৳৭.০ / ক্যাপসুল',
        'genericAlternativesJson': '[{"name":"Losec 20","manufacturer":"Beximco","price":"৳৬.০"},{"name":"Proceptin 20","manufacturer":"Incepta","price":"৳৭.০"},{"name":"Xeldrin 20","manufacturer":"Acme","price":"৳৬.৫"}]',
      },
      {
        'name': 'Fexo 120',
        'genericName': 'Fexofenadine Hydrochloride 120mg',
        'manufacturer': 'Square Pharmaceuticals Ltd.',
        'indications': 'অ্যালার্জিজনিত সর্দি, হাঁচি, চুলকানি এবং চোখ দিয়ে জল পড়া।',
        'sideEffects': 'সামান্য ঝিমুনি, মাথাব্যথা, মুখ শুকিয়ে যাওয়া।',
        'dosage': 'প্রাপ্তবয়স্ক: ১টি ট্যাবলেট দিনে ১ বার।',
        'instructions': 'খাবারের আগে বা পরে জল দিয়ে সেবন করা যায়।',
        'price': '৳৮.০ / ট্যাবলেট',
        'genericAlternativesJson': '[{"name":"Fexofast 120","manufacturer":"Beximco","price":"৳৮.০"},{"name":"Axodin 120","manufacturer":"Acme","price":"৳৭.৫"},{"name":"Telfast 120","manufacturer":"Sanofi","price":"৳৯.০"}]',
      },
      {
        'name': 'Sergel 20',
        'genericName': 'Esomeprazole 20mg',
        'manufacturer': 'Incepta Pharmaceuticals Ltd.',
        'indications': 'তীব্র গ্যাস্ট্রিক আলসার, বুক জ্বালাপোড়া এবং টক ঢেকুর।',
        'sideEffects': 'মাথাব্যথা, পেট ব্যথা, বমি বমি ভাব।',
        'dosage': '১টি ক্যাপসুল দিনে ২ বার।',
        'instructions': 'খাবারের ৩০ মিনিট আগে সেবন করুন।',
        'price': '৳৮.০ / ক্যাপসুল',
        'genericAlternativesJson': '[{"name":"Maxpro 20","manufacturer":"Renata","price":"৳৮.০"},{"name":"Nexum 20","manufacturer":"Square","price":"৳৮.০"},{"name":"Optimo 20","manufacturer":"Beximco","price":"৳৭.৫"}]',
      },
    ];

    for (final med in initialMedicines) {
      await db.insert(
        'medicines',
        med,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
