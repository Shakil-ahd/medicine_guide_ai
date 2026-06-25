import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';

class GeminiService {
  static const List<String> _models = [
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
  ];

  static const Duration _timeout = Duration(seconds: 40);

  int _currentKeyIndex = 0;

  List<String> get _keys {
    if (Secrets.geminiApiKeys.isNotEmpty) {
      return Secrets.geminiApiKeys;
    }
    return [Secrets.geminiApiKey];
  }

  String get _currentKey {
    final keys = _keys;
    return keys[_currentKeyIndex % keys.length];
  }

  GenerativeModel _buildModel(String modelName, {String? apiKey}) {
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey ?? _currentKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
        maxOutputTokens: 4096,
      ),
    );
  }

  String _cleanJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return text.trim();
  }

  String _getMimeType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  bool _isQuotaError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('429') ||
        msg.contains('quota') ||
        msg.contains('resource_exhausted') ||
        msg.contains('too many requests') ||
        msg.contains('rate limit');
  }

  bool _isServerBusyError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('503') ||
        msg.contains('unavailable') ||
        msg.contains('overloaded');
  }

  bool _isFatalError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('api_key_invalid') ||
        msg.contains('api key not valid') ||
        msg.contains('invalid api key') ||
        msg.contains('socketexception') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated');
  }

  Future<Map<String, dynamic>?> fetchMedicineDetails(
    String imagePath,
    String scannedText,
  ) async {
    final prompt =
        'You are a medical expert for Bangladesh market. Analyze this medicine package image carefully.\n'
        'OCR extracted text: "$scannedText"\n\n'
        'CRITICAL: Return ONLY a raw JSON object (no markdown code blocks, no explanation) with this exact structure:\n'
        '{"name":"exact brand name from image","genericName":"INN generic name","manufacturer":"company name in English",'
        '"indications":"ব্যবহার বাংলায়","sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়","dosage":"মাত্রা বাংলায়",'
        '"instructions":"সেবনবিধি বাংলায়","price":"official MRP price in BDT e.g. ৳12.50/tablet or ৳150/pack",'
        '"genericAlternatives":[{"name":"brand","manufacturer":"company","price":"৳X/unit"}]}\n\n'
        'ACCURACY RULES:\n'
        '1. Medicine name MUST exactly match what is printed on the pack.\n'
        '2. Price MUST be the current official retail price (MRP) in Bangladesh Taka. Use your training data for accurate prices. Never guess or approximate.\n'
        '3. If price is unknown, write "মূল্য অজানা" instead of guessing.\n'
        '4. Alternatives must be real brands available in Bangladesh pharmacies.';

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final keys = _keys;
    final totalKeys = keys.length;

    for (int ki = 0; ki < totalKeys; ki++) {
      final keyIndex = (_currentKeyIndex + ki) % totalKeys;
      final key = keys[keyIndex];

      debugPrint('[GeminiService] --- Testing Key Index: $keyIndex ---');

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiService] Trying key=$keyIndex model=$modelName');
          final model = _buildModel(modelName, apiKey: key);
          final content = [
            Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
          ];

          final response = await model.generateContent(content).timeout(
                _timeout,
                onTimeout: () => throw TimeoutException('Timeout on $modelName'),
              );

          final text = response.text;
          if (text == null || text.trim().isEmpty) {
            debugPrint('[GeminiService] Empty response from $modelName');
            continue;
          }

          final cleaned = _cleanJson(text);
          try {
            final decoded = jsonDecode(cleaned);
            if (decoded is Map<String, dynamic>) {
              debugPrint('[GeminiService] ✓ Success with key=$keyIndex model=$modelName');
              _currentKeyIndex = keyIndex;
              return decoded;
            }
          } catch (e) {
            debugPrint('[GeminiService] JSON parse error on $modelName: $e. Raw text: $text');
            continue;
          }
        } on TimeoutException {
          debugPrint('[GeminiService] Timeout on model $modelName with key $keyIndex');
          continue;
        } catch (e) {
          if (_isFatalError(e)) {
            debugPrint('[GeminiService] Fatal network error: $e');
            return null;
          }
          if (_isQuotaError(e)) {
            debugPrint('[GeminiService] Quota hit on model $modelName with key $keyIndex');
            continue;
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiService] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint('[GeminiService] Error on key $keyIndex model $modelName: $e');
          continue;
        }
      }

      debugPrint('[GeminiService] All models exhausted for Key Index: $keyIndex. Rotating to next key...');
    }

    debugPrint('[GeminiService] All keys and models completely exhausted.');
    return null;
  }

  Future<List<dynamic>?> parsePrescription(String imagePath) async {
    final prompt =
        'You are a medical expert for Bangladesh. Read this handwritten prescription image carefully.\n'
        'Extract ALL medicines listed by the doctor. For each medicine, provide detailed info.\n\n'
        'CRITICAL: Return ONLY a raw JSON array (no markdown, no extra text) with this structure:\n'
        '[{"name":"medicine brand name","purpose":"কেন খেতে হবে বাংলায়",'
        '"dosage":"exact dose as written e.g. ১+০+১ বা ১ টি সকালে",'
        '"duration":"কতদিন বাংলায়","genericName":"INN name in English",'
        '"manufacturer":"Bangladesh manufacturer in English",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়",'
        '"price":"actual MRP in BDT e.g. ৳12.50/tablet",'
        '"genericAlternatives":[{"name":"brand","manufacturer":"company","price":"৳X"}]}]\n\n'
        'ACCURACY RULES:\n'
        '1. READ dose instructions VERY carefully. If written 1+0+1, dosage = "সকালে ১টি ও রাতে ১টি (দিনে ২বার)".\n'
        '2. Price must be actual current MRP in Bangladesh. Write "মূল্য অজানা" if uncertain.\n'
        '3. Do NOT invent medicines not written in the prescription.\n'
        '4. Alternatives must be real brands in Bangladesh pharmacies.';

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final keys = _keys;
    final totalKeys = keys.length;

    for (int ki = 0; ki < totalKeys; ki++) {
      final keyIndex = (_currentKeyIndex + ki) % totalKeys;
      final key = keys[keyIndex];

      debugPrint('[GeminiService] --- Testing Key Index: $keyIndex ---');

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiService] Trying key=$keyIndex model=$modelName');
          final model = _buildModel(modelName, apiKey: key);
          final content = [
            Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
          ];

          final response = await model.generateContent(content).timeout(
                _timeout,
                onTimeout: () => throw TimeoutException('Timeout on $modelName'),
              );

          final text = response.text;
          if (text == null || text.trim().isEmpty) {
            debugPrint('[GeminiService] Empty response from $modelName');
            continue;
          }

          final cleaned = _cleanJson(text);
          try {
            final decoded = jsonDecode(cleaned);
            if (decoded is List) {
              debugPrint('[GeminiService] ✓ Prescription success with key=$keyIndex model=$modelName');
              _currentKeyIndex = keyIndex;
              return decoded;
            }
          } catch (e) {
            debugPrint('[GeminiService] JSON parse error on $modelName: $e. Raw text: $text');
            continue;
          }
        } on TimeoutException {
          debugPrint('[GeminiService] Timeout on model $modelName with key $keyIndex');
          continue;
        } catch (e) {
          if (_isFatalError(e)) {
            debugPrint('[GeminiService] Fatal network error: $e');
            return null;
          }
          if (_isQuotaError(e)) {
            debugPrint('[GeminiService] Quota hit on model $modelName with key $keyIndex');
            continue;
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiService] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint('[GeminiService] Error on key $keyIndex model $modelName: $e');
          continue;
        }
      }

      debugPrint('[GeminiService] All models exhausted for Key Index: $keyIndex. Rotating to next key...');
    }

    debugPrint('[GeminiService] All keys and models completely exhausted.');
    return null;
  }
}
