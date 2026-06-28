import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';
import 'package:translator/translator.dart';

class GeminiService {
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

  int _currentKeyIndex = 0;

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

  bool _isApiKeyInvalidError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('api_key_invalid') ||
        msg.contains('api key not valid') ||
        msg.contains('invalid api key') ||
        msg.contains('api key');
  }

  bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated');
  }

  static final Map<int, String> _lastKnownStatus = {};
  static final Map<int, DateTime> _rateLimitExpiry = {};

  void _checkKeysAvailability() {
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
        'কোটা শেষ হয়ে গেছে। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন।',
      );
    }
    if (invalidCount + rateLimitCount == total) {
      throw Exception(
        'সচল এপিআই কি (API Key) পাওয়া যায়নি। কোটা শেষ অথবা কি-গুলো সঠিক নয়।',
      );
    }
  }

  bool hasAnyWorkingKey() {
    try {
      _checkKeysAvailability();
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
        } else if (_isApiKeyInvalidError(e)) {
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

    if (firstWorkingIndex != null) {
      _currentKeyIndex = firstWorkingIndex;
    }
    return statusList;
  }

  Future<Map<String, dynamic>?> fetchMedicineDetails(
    String imagePath,
    String scannedText,
  ) async {
    final prompt =
        'You are a medical expert for Bangladesh market. Analyze this medicine package image carefully.\n'
        'OCR extracted text: "$scannedText"\n\n'
        'VALIDATION RULE:\n'
        'First, check if the image displays a medicine package, blister pack, tablet, pill, capsule, syrup bottle, or health product. '
        'If the image is NOT a medicine, health product, or medical item (e.g. it is a cat, dog, random object, general text, book, food plate, scenery, etc.), '
        'you MUST return a JSON object with ONLY an "error" key explaining this in Bengali: '
        '{"error": "এটি কোনো ওষুধ বা প্রেসক্রিপশনের ছবি নয়। অনুগ্রহ করে ওষুধের স্পষ্ট ছবি আপলোড করুন।"}.\n\n'
        'CRITICAL: Return ONLY a raw JSON object (no markdown code blocks, no explanation) with this exact structure:\n'
        '{"name":"exact brand name from image","genericName":"INN generic name","manufacturer":"company name in English",'
        '"indications":"ব্যবহার বাংলায়","sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়","dosage":"মাত্রা বাংলায় (e.g. 1-0-1 or 1-0-0 as numeric pattern corresponding to Morning-Afternoon-Night/Evening if matching standard dosage)",'
        '"instructions":"সেবনবিধি বাংলায়","price":"official MRP price in BDT e.g. ৳12.50/tablet or ৳150/pack",'
        '"genericAlternatives":[{"name":"brand","manufacturer":"company","price":"৳X/unit"}]}\n\n'
        'ACCURACY RULES:\n'
        '1. Medicine name MUST exactly match what is printed on the pack.\n'
        '2. Price MUST be the current official retail price (MRP) in Bangladesh Taka. Use your training data for accurate prices. Never guess or approximate.\n'
        '3. If price is unknown, write "মূল্য অজানা" instead of guessing.\n'
        '4. Alternatives must be real brands available in Bangladesh pharmacies.\n'
        '5. The OCR extracted text is provided only as secondary helper context. The primary source of truth is the visual image. Look at the package visually, read the brand name, dosage strength (e.g. 20mg, 500mg), form (tablet, capsule, syrup), and company name directly from the image. If the OCR text is messy or incorrect, ignore it and rely entirely on your vision capability to identify the medicine.';

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final keys = _keys;
    final totalKeys = keys.length;

    if (Secrets.openRouterApiKey.trim().isEmpty) {
      _checkKeysAvailability();
    }

    for (int keyIndex = 0; keyIndex < totalKeys; keyIndex++) {
      final key = keys[keyIndex];

      // Skip keys that are known to be invalid
      if (_lastKnownStatus[keyIndex] == 'invalid') {
        continue;
      }

      // Skip keys that are currently rate-limited
      final expiry = _rateLimitExpiry[keyIndex];
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        continue;
      }

      debugPrint('[GeminiService] --- Testing Key Index: $keyIndex ---');

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiService] Trying key=$keyIndex model=$modelName');
          final model = _buildModel(modelName, apiKey: key);
          final content = [
            Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
          ];

          final response = await model
              .generateContent(content)
              .timeout(
                _timeout,
                onTimeout: () =>
                    throw TimeoutException('Timeout on $modelName'),
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
              debugPrint(
                '[GeminiService] ✓ Success with key=$keyIndex model=$modelName',
              );
              _currentKeyIndex = keyIndex;
              _lastKnownStatus[keyIndex] = 'working';
              return decoded;
            }
          } catch (e) {
            debugPrint(
              '[GeminiService] JSON parse error on $modelName: $e. Raw text: $text',
            );
            continue;
          }
        } on TimeoutException {
          debugPrint(
            '[GeminiService] Timeout on model $modelName with key $keyIndex',
          );
          continue;
        } catch (e) {
          if (_isNetworkError(e)) {
            debugPrint('[GeminiService] Fatal network error: $e');
            return null;
          }
          if (_isApiKeyInvalidError(e)) {
            debugPrint(
              '[GeminiService] Invalid key error: $e. Rotating key immediately.',
            );
            _lastKnownStatus[keyIndex] = 'invalid';
            break; // Break model loop to rotate key immediately
          }
          if (_isQuotaError(e)) {
            debugPrint(
              '[GeminiService] Quota hit on model $modelName with key $keyIndex. Trying next model.',
            );
            continue; // Try other models first
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiService] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint(
            '[GeminiService] Error on key $keyIndex model $modelName: $e',
          );
          continue;
        }
      }

      debugPrint(
        '[GeminiService] All models exhausted or key failed for Key Index: $keyIndex. Rotating to next key...',
      );
    }

    debugPrint('[GeminiService] All keys and models completely exhausted.');

    if (Secrets.openRouterApiKey.trim().isNotEmpty) {
      final fallbackData = await _callOpenRouterFallback(
        imagePath,
        prompt,
        false,
      );
      if (fallbackData != null) {
        return fallbackData;
      }
    }

    _checkKeysAvailability();
    throw Exception(
      'ওষুধের তথ্য সংগ্রহ করা যায়নি। অনুগ্রহ করে স্পষ্ট ছবি আপলোড করুন।',
    );
  }

  Future<List<dynamic>?> parsePrescription(String imagePath) async {
    final prompt =
        'You are a medical expert for Bangladesh. Read this handwritten prescription or medical report image carefully.\n'
        'VALIDATION RULE:\n'
        'First, check if the image displays a medical prescription, doctor note, or clinical report. '
        'If the image is NOT a medical prescription or clinical document (e.g. it is a cat, dog, food, random text, scenery, etc.), '
        'you MUST return a JSON array containing a single object with ONLY an "error" key explaining this in Bengali: '
        '[{"error": "এটি কোনো প্রেসক্রিপশনের ছবি নয়। অনুগ্রহ করে একটি স্পষ্ট প্রেসক্রিপশন আপলোড করুন।"}]\n\n'
        'Extract ALL medicines listed by the doctor. For each medicine, provide detailed info.\n\n'
        'CRITICAL: Return ONLY a raw JSON array (no markdown, no extra text) with this structure:\n'
        '[{"name":"medicine brand name","purpose":"কেন খেতে হবে বাংলায়",'
        '"dosage":"dosage pattern formatted strictly as a numeric pattern e.g., 1-0-1 for morning/night, 1-1-1 for thrice a day, 1-0-0 for morning only, 0-0-1 for night only (strictly digits separated by hyphens, no Bengali text or parentheses inside this field)",'
        '"duration":"কতদিন বাংলায়","genericName":"INN name in English",'
        '"manufacturer":"Bangladesh manufacturer in English",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়",'
        '"price":"actual MRP in BDT e.g. ৳12.50/tablet",'
        '"genericAlternatives":[{"name":"brand","manufacturer":"company","price":"৳X"}]}]\n\n'
        'ACCURACY RULES:\n'
        '1. Translate the dose instructions VERY carefully into the strict hyphen-separated numeric pattern format (e.g. 1-0-1, 1-1-1, 1-0-0, 0-0-1).\n'
        '2. Price must be actual current MRP in Bangladesh. Write "মূল্য অজানা" if uncertain.\n'
        '3. Do NOT invent medicines not written in the prescription.\n'
        '4. Alternatives must be real brands in Bangladesh pharmacies.\n'
        '5. HANDWRITING READABILITY: Be extremely careful when reading handwritten numbers. In prescriptions, doctors often write a simple vertical stroke ("|") or slash ("/") to represent "1". Do NOT confuse this for "2". If it is written as a single line, it is 1, not 2. Look at typical patterns (e.g. 1-0-1, 1-0-0, 1-1-1). Double check "1" vs "2" visually.';

    final mimeType = _getMimeType(imagePath);
    final bytes = await File(imagePath).readAsBytes();
    final keys = _keys;
    final totalKeys = keys.length;

    if (Secrets.openRouterApiKey.trim().isEmpty) {
      _checkKeysAvailability();
    }

    for (int keyIndex = 0; keyIndex < totalKeys; keyIndex++) {
      final key = keys[keyIndex];

      // Skip keys that are known to be invalid
      if (_lastKnownStatus[keyIndex] == 'invalid') {
        continue;
      }

      // Skip keys that are currently rate-limited
      final expiry = _rateLimitExpiry[keyIndex];
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        continue;
      }

      debugPrint('[GeminiService] --- Testing Key Index: $keyIndex ---');

      for (final modelName in _models) {
        try {
          debugPrint('[GeminiService] Trying key=$keyIndex model=$modelName');
          final model = _buildModel(modelName, apiKey: key);
          final content = [
            Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
          ];

          final response = await model
              .generateContent(content)
              .timeout(
                _timeout,
                onTimeout: () =>
                    throw TimeoutException('Timeout on $modelName'),
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
              debugPrint(
                '[GeminiService] ✓ Prescription success with key=$keyIndex model=$modelName',
              );
              _currentKeyIndex = keyIndex;
              _lastKnownStatus[keyIndex] = 'working';
              return decoded;
            }
          } catch (e) {
            debugPrint(
              '[GeminiService] JSON parse error on $modelName: $e. Raw text: $text',
            );
            continue;
          }
        } on TimeoutException {
          debugPrint(
            '[GeminiService] Timeout on model $modelName with key $keyIndex',
          );
          continue;
        } catch (e) {
          if (_isNetworkError(e)) {
            debugPrint('[GeminiService] Fatal network error: $e');
            return null;
          }
          if (_isApiKeyInvalidError(e)) {
            debugPrint(
              '[GeminiService] Invalid key error: $e. Rotating key immediately.',
            );
            _lastKnownStatus[keyIndex] = 'invalid';
            break; // Break model loop to rotate key immediately
          }
          if (_isQuotaError(e)) {
            debugPrint(
              '[GeminiService] Quota hit on model $modelName with key $keyIndex. Trying next model.',
            );
            continue; // Try other models first
          }
          if (_isServerBusyError(e)) {
            debugPrint('[GeminiService] Server busy, waiting 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          debugPrint(
            '[GeminiService] Error on key $keyIndex model $modelName: $e',
          );
          continue;
        }
      }

      debugPrint(
        '[GeminiService] All models exhausted or key failed for Key Index: $keyIndex. Rotating to next key...',
      );
    }

    if (Secrets.openRouterApiKey.trim().isNotEmpty) {
      final fallbackData = await _callOpenRouterFallback(
        imagePath,
        prompt,
        true,
      );
      if (fallbackData != null) {
        return fallbackData;
      }
    }

    _checkKeysAvailability();
    throw Exception(
      'প্রেসক্রিপশনটি পড়া যায়নি। অনুগ্রহ করে প্রেসক্রিপশনটির একটি স্পষ্ট ছবি তুলুন।',
    );
  }

  Future<Map<String, String>?> translateMedicineDetails({
    required String name,
    required String genericName,
    required String indications,
    required String sideEffects,
    required String dosage,
    required String instructions,
  }) async {
    final translator = GoogleTranslator();

    Future<String> safeTranslate(String text) async {
      if (text.trim().isEmpty) return '';
      if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
        return text;
      }
      try {
        final res = await translator.translate(text, to: 'bn');
        return res.text;
      } catch (e) {
        debugPrint('[Translator] Translation error: $e');
        return text;
      }
    }

    try {
      final results = await Future.wait([
        safeTranslate(indications),
        safeTranslate(sideEffects),
        safeTranslate(dosage),
        safeTranslate(instructions),
      ]);

      return {
        'indications': results[0],
        'sideEffects': results[1],
        'dosage': results[2],
        'instructions': results[3],
      };
    } catch (e) {
      debugPrint('[Translator] Parallel translation error: $e');
      throw Exception(
        'অনুবাদ করা সম্ভব হয়নি। অনুগ্রহ করে ইন্টারনেট সংযোগ চেক করুন।',
      );
    }
  }

  Future<dynamic> _callOpenRouterFallback(
    String imagePath,
    String prompt,
    bool isList,
  ) async {
    if (Secrets.openRouterApiKey.trim().isEmpty) {
      return null;
    }

    debugPrint('[GeminiService] Calling OpenRouter Fallback...');
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final client = HttpClient();
      final uri = Uri.parse(AppConstants.openRouterApiUrl);

      // We use openrouter/free to dynamically select available free vision models, with specific fallbacks
      final models = [
        'openrouter/free',
        'nvidia/nemotron-nano-12b-v2-vl:free',
        'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
      ];

      for (final modelName in models) {
        try {
          debugPrint('[GeminiService] Trying OpenRouter model=$modelName');
          final request = await client
              .postUrl(uri)
              .timeout(const Duration(seconds: 25));

          request.headers.set('Content-Type', 'application/json');
          request.headers.set(
            'Authorization',
            'Bearer ${Secrets.openRouterApiKey.trim()}',
          );
          request.headers.set('HTTP-Referer', AppConstants.openRouterReferer);
          request.headers.set('X-Title', AppConstants.appName);

          final requestBody = jsonEncode({
            'model': modelName,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': prompt},
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
                  },
                ],
              },
            ],
            'temperature': 0.1,
          });

          request.add(utf8.encode(requestBody));
          final response = await request.close().timeout(
            const Duration(seconds: 25),
          );
          final responseBody = await response.transform(utf8.decoder).join();

          if (response.statusCode == 200) {
            final decodedResponse =
                jsonDecode(responseBody) as Map<String, dynamic>;
            final choices = decodedResponse['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final content = choices[0]['message']['content'] as String?;
              if (content != null && content.trim().isNotEmpty) {
                final cleaned = _cleanJson(content);
                final decodedContent = jsonDecode(cleaned);
                if (isList && decodedContent is List) {
                  debugPrint(
                    '[GeminiService] ✓ OpenRouter Fallback success (List) via $modelName',
                  );
                  client.close();
                  return decodedContent;
                } else if (!isList && decodedContent is Map<String, dynamic>) {
                  debugPrint(
                    '[GeminiService] ✓ OpenRouter Fallback success (Map) via $modelName',
                  );
                  client.close();
                  return decodedContent;
                }
              }
            }
          } else {
            debugPrint(
              '[GeminiService] OpenRouter model $modelName returned error: ${response.statusCode} - $responseBody',
            );
          }
        } catch (e) {
          debugPrint(
            '[GeminiService] Error calling OpenRouter model $modelName: $e',
          );
        }
      }
      client.close();
    } catch (e) {
      debugPrint(
        '[GeminiService] Exception in OpenRouter Fallback structure: $e',
      );
    }
    return null;
  }
}
