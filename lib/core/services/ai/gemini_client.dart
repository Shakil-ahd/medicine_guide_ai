import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';

class GeminiClient {
  static const List<String> _models = [
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash-lite',
    'gemini-3-flash-preview',
  ];

  static const Duration _timeout = Duration(seconds: 30);

  final Map<int, String> _lastKnownStatus = {};
  final Map<int, DateTime> _rateLimitExpiry = {};

  List<String> get _keys {
    final list = <String>[];
    if (Secrets.geminiApiKey.trim().isNotEmpty) {
      list.add(Secrets.geminiApiKey.trim());
    }
    for (final k in Secrets.geminiApiKeys) {
      final trimmed = k.trim();
      if (trimmed.isNotEmpty && !list.contains(trimmed)) {
        list.add(trimmed);
      }
    }
    return list;
  }

  bool get hasKeys => _keys.isNotEmpty;

  void checkKeysAvailability() {
    final keys = _keys;
    final total = keys.length;
    if (total == 0) {
      throw Exception('কোনো এপিআই কি (API Key) কনফিগার করা নেই।');
    }

    int invalidCount = 0;
    int rateLimitCount = 0;
    final now = DateTime.now();

    for (int i = 0; i < total; i++) {
      if (_lastKnownStatus[i] == 'invalid') {
        invalidCount++;
      } else {
        final expiry = _rateLimitExpiry[i];
        if (expiry != null && now.isBefore(expiry)) {
          rateLimitCount++;
        }
      }
    }

    if (invalidCount == total) {
      throw Exception('আপনার এপিআই কি (API Key) সঠিক নয়।');
    }
    if (rateLimitCount == total) {
      throw Exception(
        'কোটা বা রেট লিমিট শেষ হয়েছে। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন বা ব্যাকআপ কী ব্যবহার করুন।',
      );
    }
  }

  bool hasAnyWorkingKey() {
    try {
      checkKeysAvailability();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> checkAllKeysStatus() async {
    final statusList = <Map<String, dynamic>>[];
    final keys = _keys;
    int? firstWorkingIndex;

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final maskedKey = key.length > 10
          ? '${key.substring(0, 6)}...${key.substring(key.length - 4)}'
          : 'Key ${i + 1}';

      try {
        final model = GenerativeModel(
          model: 'gemini-3.5-flash',
          apiKey: key,
          generationConfig: GenerationConfig(
            maxOutputTokens: 2,
            temperature: 0.0,
          ),
        );
        final response = await model
            .generateContent([Content.text('respond with OK')])
            .timeout(const Duration(seconds: 10));

        if (response.text != null && response.text!.trim().isNotEmpty) {
          _lastKnownStatus[i] = 'working';
          firstWorkingIndex ??= i;
          statusList.add({
            'index': i,
            'masked': maskedKey,
            'status': 'সচল (Working)',
            'isWorking': true,
          });
        } else {
          _lastKnownStatus[i] = 'unknown';
          statusList.add({
            'index': i,
            'masked': maskedKey,
            'status': 'অজানা সমস্যা (Unknown Response)',
            'isWorking': false,
          });
        }
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        String statusText = 'ত্রুটি (Error)';
        if (_isQuotaError(e)) {
          statusText = 'কোটা শেষ (Limit Exceeded / 429)';
          _lastKnownStatus[i] = 'rateLimited';
        } else if (_isInvalidKeyError(e)) {
          statusText = 'ভুল কি (Invalid Key)';
          _lastKnownStatus[i] = 'invalid';
        } else if (errorMsg.contains('timeout')) {
          statusText = 'সময় শেষ (Timeout)';
          _lastKnownStatus[i] = 'timeout';
        } else {
          _lastKnownStatus[i] = 'error';
        }

        statusList.add({
          'index': i,
          'masked': maskedKey,
          'status': statusText,
          'isWorking': false,
        });
      }
    }

    return statusList;
  }

  GenerativeModel _buildModel(String modelName, {required String apiKey}) {
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  bool _isQuotaError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('quota') ||
        msg.contains('429') ||
        msg.contains('rate limit') ||
        msg.contains('resource exhausted');
  }

  bool _isInvalidKeyError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('api key not valid') ||
        msg.contains('400') ||
        msg.contains('invalid api key') ||
        msg.contains('key invalid');
  }

  bool _isServerBusyError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('503') ||
        msg.contains('service unavailable') ||
        msg.contains('overloaded');
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'png') return 'image/png';
    if (ext == 'webp') return 'image/webp';
    if (ext == 'heic') return 'image/heic';
    if (ext == 'heif') return 'image/heif';
    return 'image/jpeg';
  }

  String _cleanJson(String raw) {
    String clean = raw.trim();
    if (clean.startsWith('```')) {
      final lines = clean.split('\n');
      if (lines.first.startsWith('```')) {
        lines.removeAt(0);
      }
      if (lines.isNotEmpty && lines.last.startsWith('```')) {
        lines.removeLast();
      }
      clean = lines.join('\n').trim();
    }
    return clean;
  }

  Future<Map<String, dynamic>?> fetchMedicineDetails(
    String imagePath,
    String prompt,
  ) async {
    final keys = _keys;
    if (keys.isEmpty) return null;

    debugPrint('[AI Service] Try Gemini API...');

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final totalKeys = keys.length;

    for (int keyIndex = 0; keyIndex < totalKeys; keyIndex++) {
      final key = keys[keyIndex];

      if (_lastKnownStatus[keyIndex] == 'invalid') continue;
      final expiry = _rateLimitExpiry[keyIndex];
      if (expiry != null && DateTime.now().isBefore(expiry)) continue;

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiClient] Trying model=$modelName with keyIndex=$keyIndex');
          final model = _buildModel(modelName, apiKey: key);
          
          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart(mimeType, bytes),
            ])
          ];

          final response = await model
              .generateContent(content)
              .timeout(_timeout);

          final rawText = response.text;
          if (rawText != null && rawText.isNotEmpty) {
            final cleaned = _cleanJson(rawText);
            final decoded = jsonDecode(cleaned) as Map<String, dynamic>;

            _lastKnownStatus[keyIndex] = 'valid';
            debugPrint('[AI Service] ✓ Gemini API Success (Model: $modelName)');
            return decoded;
          }
        } catch (e) {
          if (_isInvalidKeyError(e)) {
            _lastKnownStatus[keyIndex] = 'invalid';
            debugPrint('[GeminiClient] Invalid key at index $keyIndex: $e');
            break; 
          }
          if (_isQuotaError(e)) {
            _rateLimitExpiry[keyIndex] = DateTime.now().add(const Duration(minutes: 5));
            debugPrint(
              '[GeminiClient] Quota limit exceeded for key index $keyIndex. Model: $modelName. Error: $e',
            );
            continue; 
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiClient] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint(
            '[GeminiClient] Error on key $keyIndex model $modelName: $e',
          );
        }
      }
    }
    return null;
  }

  Future<List<dynamic>?> parsePrescription(
    String imagePath,
    String prompt,
  ) async {
    final keys = _keys;
    if (keys.isEmpty) return null;

    debugPrint('[AI Service] Try Gemini API...');

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final totalKeys = keys.length;

    for (int keyIndex = 0; keyIndex < totalKeys; keyIndex++) {
      final key = keys[keyIndex];

      if (_lastKnownStatus[keyIndex] == 'invalid') continue;
      final expiry = _rateLimitExpiry[keyIndex];
      if (expiry != null && DateTime.now().isBefore(expiry)) continue;

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiClient] Trying model=$modelName with keyIndex=$keyIndex');
          final model = _buildModel(modelName, apiKey: key);

          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart(mimeType, bytes),
            ])
          ];

          final response = await model
              .generateContent(content)
              .timeout(_timeout);

          final rawText = response.text;
          if (rawText != null && rawText.isNotEmpty) {
            final cleaned = _cleanJson(rawText);
            final decoded = jsonDecode(cleaned) as List<dynamic>;

            _lastKnownStatus[keyIndex] = 'valid';
            debugPrint('[AI Service] ✓ Gemini API Success (Model: $modelName)');
            return decoded;
          }
        } catch (e) {
          if (_isInvalidKeyError(e)) {
            _lastKnownStatus[keyIndex] = 'invalid';
            debugPrint('[GeminiClient] Invalid key at index $keyIndex: $e');
            break;
          }
          if (_isQuotaError(e)) {
            _rateLimitExpiry[keyIndex] = DateTime.now().add(const Duration(minutes: 5));
            debugPrint(
              '[GeminiClient] Quota limit exceeded for key index $keyIndex. Model: $modelName. Error: $e',
            );
            continue;
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiClient] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint(
            '[GeminiClient] Error on key $keyIndex model $modelName: $e',
          );
        }
      }
    }
    return null;
  }
}
