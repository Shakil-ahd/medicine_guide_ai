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
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  static const Duration _timeout = Duration(seconds: 35);

  GenerativeModel _buildModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: Secrets.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
        maxOutputTokens: 1024,
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
        msg.contains('too many requests');
  }

  bool _isServerBusyError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('503') && msg.contains('unavailable');
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

    for (final modelName in _models) {
      try {
        debugPrint('[GeminiService] Trying model: $modelName');
        final model = _buildModel(modelName);
        final bytes = await File(imagePath).readAsBytes();
        final content = [
          Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
        ];

        final response = await model.generateContent(content).timeout(
              _timeout,
              onTimeout: () {
                throw TimeoutException('Model $modelName timed out after 35s');
              },
            );

        final text = response.text;
        if (text == null || text.trim().isEmpty) {
          debugPrint(
            '[GeminiService] Empty response from $modelName, skipping',
          );
          continue;
        }

        final cleaned = _cleanJson(text);
        try {
          final decoded = jsonDecode(cleaned);
          if (decoded is Map<String, dynamic>) {
            debugPrint('[GeminiService] Success with $modelName');
            return decoded;
          }
        } catch (parseError) {
          debugPrint(
            '[GeminiService] JSON parse error on $modelName: $parseError',
          );
          continue;
        }
      } on TimeoutException {
        debugPrint('[GeminiService] Timeout on $modelName, trying next...');
        continue;
      } catch (e) {
        if (_isFatalError(e)) {
          debugPrint('[GeminiService] Fatal error, aborting: $e');
          break;
        }
        if (_isQuotaError(e)) {
          debugPrint('[GeminiService] Quota hit on $modelName, skipping...');
          continue;
        }
        if (_isServerBusyError(e)) {
          debugPrint(
            '[GeminiService] Server busy on $modelName, waiting 3s...',
          );
          await Future.delayed(const Duration(seconds: 3));
          try {
            final model = _buildModel(modelName);
            final bytes = await File(imagePath).readAsBytes();
            final content = [
              Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
            ];
            final response = await model.generateContent(content).timeout(
                  _timeout,
                  onTimeout: () {
                    throw TimeoutException('Retry timeout');
                  },
                );
            final text = response.text;
            if (text != null && text.trim().isNotEmpty) {
              final cleaned = _cleanJson(text);
              try {
                final decoded = jsonDecode(cleaned);
                if (decoded is Map<String, dynamic>) return decoded;
              } catch (_) {}
            }
          } catch (_) {
            debugPrint('[GeminiService] Retry failed on $modelName');
          }
          continue;
        }
        debugPrint('[GeminiService] Error on $modelName: $e, skipping...');
        continue;
      }
    }

    debugPrint('[GeminiService] All models exhausted for medicine details.');
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

    for (final modelName in _models) {
      try {
        debugPrint('[GeminiService] Prescription - trying: $modelName');
        final model = _buildModel(modelName);
        final bytes = await File(imagePath).readAsBytes();
        final content = [
          Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
        ];

        final response = await model.generateContent(content).timeout(
              _timeout,
              onTimeout: () {
                throw TimeoutException('Model $modelName timed out after 35s');
              },
            );

        final text = response.text;
        if (text == null || text.trim().isEmpty) continue;

        final cleaned = _cleanJson(text);
        try {
          final decoded = jsonDecode(cleaned);
          if (decoded is List) {
            debugPrint('[GeminiService] Prescription success with $modelName');
            return decoded;
          }
        } catch (parseError) {
          debugPrint('[GeminiService] JSON parse error: $parseError');
          continue;
        }
      } on TimeoutException {
        debugPrint('[GeminiService] Timeout on $modelName, trying next...');
        continue;
      } catch (e) {
        if (_isFatalError(e)) {
          debugPrint('[GeminiService] Fatal error, aborting: $e');
          break;
        }
        if (_isQuotaError(e)) {
          debugPrint('[GeminiService] Quota hit on $modelName, skipping...');
          continue;
        }
        if (_isServerBusyError(e)) {
          debugPrint(
            '[GeminiService] Server busy on $modelName, waiting 3s...',
          );
          await Future.delayed(const Duration(seconds: 3));
          try {
            final model = _buildModel(modelName);
            final bytes = await File(imagePath).readAsBytes();
            final content = [
              Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
            ];
            final response = await model.generateContent(content).timeout(
                  _timeout,
                  onTimeout: () {
                    throw TimeoutException('Retry timeout');
                  },
                );
            final text = response.text;
            if (text != null && text.trim().isNotEmpty) {
              final cleaned = _cleanJson(text);
              try {
                final decoded = jsonDecode(cleaned);
                if (decoded is List) return decoded;
              } catch (_) {}
            }
          } catch (_) {
            debugPrint('[GeminiService] Retry failed on $modelName');
          }
          continue;
        }
        debugPrint('[GeminiService] Error on $modelName: $e, skipping...');
        continue;
      }
    }

    debugPrint('[GeminiService] All models exhausted for prescription.');
    return null;
  }
}
