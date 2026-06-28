import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:translator/translator.dart';
import 'package:medicine_guide_ai/core/services/ai/gemini_client.dart';
import 'package:medicine_guide_ai/core/services/ai/groq_client.dart';
import 'package:medicine_guide_ai/core/services/ai/openrouter_client.dart';

class AiScannerService {
  final _geminiClient = GeminiClient();
  final _groqClient = GroqClient();
  final _openRouterClient = OpenRouterClient();

  bool hasAnyWorkingKey() => _geminiClient.hasAnyWorkingKey();

  Future<List<Map<String, dynamic>>> checkAllKeysStatus() =>
      _geminiClient.checkAllKeysStatus();

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

    if (_geminiClient.hasKeys) {
      try {
        final result = await _geminiClient.fetchMedicineDetails(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] Gemini client failed: $e');
      }
    }

    if (_groqClient.hasKeys) {
      try {
        final result = await _groqClient.fetchMedicineDetails(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] Groq client failed: $e');
      }
    }

    if (_openRouterClient.hasKeys) {
      try {
        final result = await _openRouterClient.fetchMedicineDetails(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] OpenRouter client failed: $e');
      }
    }

    if (Secrets.openRouterApiKey.trim().isEmpty && Secrets.groqApiKey.trim().isEmpty) {
      _geminiClient.checkKeysAvailability();
    }
    
    throw Exception('ওষুধের তথ্য সংগ্রহ করা যায়নি। অনুগ্রহ করে স্পষ্ট ছবি আপলোড করুন।');
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

    if (_geminiClient.hasKeys) {
      try {
        final result = await _geminiClient.parsePrescription(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] Gemini client failed: $e');
      }
    }

    if (_groqClient.hasKeys) {
      try {
        final result = await _groqClient.parsePrescription(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] Groq client failed: $e');
      }
    }

    if (_openRouterClient.hasKeys) {
      try {
        final result = await _openRouterClient.parsePrescription(imagePath, prompt);
        if (result != null) return result;
      } catch (e) {
        debugPrint('[AiScannerService] OpenRouter client failed: $e');
      }
    }

    if (Secrets.openRouterApiKey.trim().isEmpty && Secrets.groqApiKey.trim().isEmpty) {
      _geminiClient.checkKeysAvailability();
    }

    throw Exception('প্রেসক্রিপশনটি পড়া যায়নি। অনুগ্রহ করে প্রেসক্রিপশনটির একটি স্পষ্ট ছবি তুলুন।');
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
      throw Exception('অনুবাদ করা সম্ভব হয়নি। অনুগ্রহ করে ইন্টারনেট সংযোগ চেক করুন।');
    }
  }
}
