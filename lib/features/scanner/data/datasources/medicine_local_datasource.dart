import 'dart:convert';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';

abstract class MedicineLocalDataSource {
  Future<void> cacheMedicine(MedicineModel medicine);
  Future<MedicineModel?> getCachedMedicineByOcrText(String ocrText);
  Future<void> saveScanLog(
    String medicineName,
    bool isOffline,
    String? imagePath,
  );
}

class MedicineLocalDataSourceImpl implements MedicineLocalDataSource {
  final DatabaseHelper _dbHelper;

  MedicineLocalDataSourceImpl(this._dbHelper);

  @override
  Future<void> cacheMedicine(MedicineModel medicine) async {
    await _dbHelper.insertMedicine(medicine.toDbMap());
  }

  bool _isOcrMatch(String dbName, String ocrText, {required bool strict}) {
    final dbLower = dbName.toLowerCase();
    final ocrLower = ocrText.toLowerCase();

    
    List<String> tokenize(String text) {
      return RegExp(
        r'([a-zA-Z]+|\d+(?:\.\d+)?)',
      ).allMatches(text).map((m) => m.group(0)!).toList();
    }

    final dbTokens = tokenize(dbLower);
    final ocrTokens = tokenize(ocrLower);

    if (dbTokens.isEmpty) return false;

    
    final brandToken = dbTokens.first;
    if (!ocrTokens.contains(brandToken)) return false;

    
    if (!strict) return true;

    final units = {
      'mg',
      'ml',
      'g',
      'mcg',
      'iu',
      'ug',
      'percentage',
      'percent',
      'pc',
      'tablet',
      'tablets',
      'capsule',
      'capsules',
      'cap',
      'tab',
      'vial',
      'ampoule',
      'syrup',
      'suspension',
      'injection',
      'drops',
    };

    
    final dbNumbers = dbTokens
        .where((t) => RegExp(r'^\d+(?:\.\d+)?$').hasMatch(t))
        .toList();
    final primaryDbNumber = dbNumbers.isNotEmpty ? dbNumbers.first : null;

    for (final token in dbTokens) {
      if (units.contains(token)) continue;

      if (RegExp(r'^\d+(?:\.\d+)?$').hasMatch(token)) {
        
        if (token == primaryDbNumber) {
          if (!ocrTokens.contains(token)) {
            return false;
          }
        }
      } else {
        
        if (token.length >= 2 && !ocrTokens.contains(token)) {
          return false;
        }
      }
    }
    return true;
  }

  int _calculateScore(String dbName, String ocrText) {
    final dbTokens = dbName
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    int score = 0;
    for (final token in dbTokens) {
      if (ocrText.contains(token)) {
        score++;
      }
    }
    return score;
  }

  @override
  Future<MedicineModel?> getCachedMedicineByOcrText(String ocrText) async {
    final db = await _dbHelper.database;
    final cleanOcr = ocrText.toLowerCase();
    final tokens = cleanOcr
        .split(RegExp(r'[^a-zA-Z0-9\-]+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return null;

    final List<String> whereClauses = [];
    final List<String> whereArgs = [];

    for (final token in tokens) {
      if (token.length >= 3 && !RegExp(r'^\d+$').hasMatch(token)) {
        whereClauses.add('name LIKE ?');
        whereArgs.add('$token%');
      }
    }

    if (whereClauses.isEmpty) return null;

    
    final results = await db.query(
      'medicines',
      where: whereClauses.join(' OR '),
      whereArgs: whereArgs,
    );

    if (results.isEmpty) return null;

    
    List<Map<String, dynamic>> matchingCandidates = [];
    final Map<String, int> candidateScores = {};

    for (final row in results) {
      final dbName = row['name'] as String? ?? '';
      if (_isOcrMatch(dbName, cleanOcr, strict: true)) {
        matchingCandidates.add(row);
        candidateScores[dbName] = _calculateScore(dbName, cleanOcr);
      }
    }

    
    if (matchingCandidates.isEmpty) {
      for (final row in results) {
        final dbName = row['name'] as String? ?? '';
        if (_isOcrMatch(dbName, cleanOcr, strict: false)) {
          matchingCandidates.add(row);
          candidateScores[dbName] = _calculateScore(dbName, cleanOcr);
        }
      }
    }

    if (matchingCandidates.isEmpty) return null;

    
    matchingCandidates.sort((a, b) {
      final nameA = a['name'] as String? ?? '';
      final nameB = b['name'] as String? ?? '';
      final scoreA = candidateScores[nameA] ?? 0;
      final scoreB = candidateScores[nameB] ?? 0;
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return nameB.length.compareTo(nameA.length);
    });

    final matchedRow = Map<String, dynamic>.from(matchingCandidates.first);
    final brandName = matchedRow['name'] as String;
    final genericName = matchedRow['genericName'] as String? ?? '';

    
    try {
      final alternatives = await db.query(
        'medicines',
        columns: ['name', 'manufacturer', 'price'],
        where: 'LOWER(genericName) = ? AND LOWER(name) != ?',
        whereArgs: [genericName.toLowerCase(), brandName.toLowerCase()],
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

      matchedRow['genericAlternativesJson'] = jsonEncode(mappedAlternatives);
    } catch (_) {
      matchedRow['genericAlternativesJson'] = '[]';
    }

    return MedicineModel.fromDbMap(matchedRow);
  }

  @override
  Future<void> saveScanLog(
    String medicineName,
    bool isOffline,
    String? imagePath,
  ) async {
    await _dbHelper.insertHistory({
      'medicineName': medicineName,
      'scannedAt': DateTime.now().toIso8601String(),
      'isOffline': isOffline ? 1 : 0,
      'imagePath': imagePath,
    });
  }
}
