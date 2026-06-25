import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';

class GeminiService {
  static const List<String> _models = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash-lite',
  ];

  GeminiService() {
    _checkApiKey();
  }

  GenerativeModel _buildModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: Secrets.geminiApiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<void> _checkApiKey() async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(
        "${AppConstants.modelsUrl}?key=${Secrets.geminiApiKey}",
      );
      final request = await client.getUrl(uri);
      final response = await request.close();
      print("Gemini API Status: ${response.statusCode}");
    } catch (e) {
      print("API key check failed: $e");
    }
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

  Future<Map<String, dynamic>?> fetchMedicineDetails(
    String imagePath,
    String scannedText,
  ) async {
    final prompt =
        'You are a medical assistant for Bangladesh. Look at this medicine pack image and analyze its text details.\n'
        'OCR text helper: "$scannedText"\n'
        'Identify the medicine correctly. Return ONLY a valid JSON object (no markdown, no explanation) with this exact structure:\n'
        '{"name":"medicine name in English","genericName":"generic/chemical name",'
        '"manufacturer":"company name","indications":"ব্যবহার বাংলায়",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়","dosage":"মাত্রা বাংলায়",'
        '"instructions":"সেবনবিধি বাংলায়","price":"প্রকৃত খুচরা মূল্য বাংলায় (যেমন: ৳১২ / ট্যাবলেট)",'
        '"genericAlternatives":[{"name":"alternative name","manufacturer":"manufacturer","price":"price"}]}\n'
        'Important guidelines:\n'
        '1. Ensure the medicine name, generic name, and manufacturer are 100% correct according to the image. Do not guess a wrong medicine name.\n'
        '2. Retrieve the actual, accurate market retail price in Bangladesh Taka (৳) from your knowledge base for the brand. Do not give arbitrary mock prices.\n'
        '3. Provide actual alternative brands commonly available in Bangladesh with their current prices.';

    final mimeType = _getMimeType(imagePath);

    for (final modelName in _models) {
      try {
        print('Trying model: $modelName');
        final model = _buildModel(modelName);
        final bytes = await File(imagePath).readAsBytes();
        final content = [
          Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
        ];
        final response = await model.generateContent(content);
        final text = response.text;
        if (text == null || text.trim().isEmpty) continue;
        final cleaned = _cleanJson(text);
        final decoded = jsonDecode(cleaned);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (e) {
        final errMsg = e.toString().toLowerCase();
        if (errMsg.contains('api_key_invalid') ||
            errMsg.contains('api key not valid') ||
            errMsg.contains('invalid api key') ||
            errMsg.contains('socketexception') ||
            errMsg.contains('network') ||
            errMsg.contains('connection')) {
          print('Fatal network or API key error: $e. Aborting model loop.');
          break;
        }
        if (_isQuotaError(e)) {
          print('Quota hit on $modelName, skipping...');
          continue;
        }
        if (_isServerBusyError(e)) {
          print('Server busy on $modelName, waiting 5s and retrying...');
          await Future.delayed(const Duration(seconds: 5));
          try {
            final model = _buildModel(modelName);
            final bytes = await File(imagePath).readAsBytes();
            final content = [
              Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
            ];
            final response = await model.generateContent(
              content,
            );
            final text = response.text;
            if (text != null && text.trim().isNotEmpty) {
              final cleaned = _cleanJson(text);
              final decoded = jsonDecode(cleaned);
              if (decoded is Map<String, dynamic>) return decoded;
            }
          } catch (_) {
            print('Retry failed on $modelName, skipping...');
          }
          continue;
        }
        print('Unknown error on $modelName: $e, skipping...');
        continue;
      }
    }
    print('All models exhausted.');
    return null;
  }

  Future<List<dynamic>?> parsePrescription(String imagePath) async {
    final prompt =
        'You are a medical assistant for Bangladesh. Read this handwritten prescription image carefully.\n'
        'Extract all medicines listed. For each medicine, provide additional details from your medical knowledge base.\n'
        'Return ONLY a valid JSON array (no markdown, no extra text) with this exact structure:\n'
        '[{"name":"medicine name","purpose":"কেন খেতে হবে বাংলায়",'
        '"dosage":"কীভাবে খেতে হবে বাংলায় (যেমন: ১+০+১ (সকালে ও রাতে ১টি করে))",'
        '"duration":"কতদিন বাংলায়",'
        '"genericName":"generic/chemical name of the medicine in English",'
        '"manufacturer":"Bangladesh company name (manufacturer) in English",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়",'
        '"price":"প্রকৃত খুচরা মূল্য বাংলায় (যেমন: ৳২.৫ / ট্যাবলেট)",'
        '"genericAlternatives":[{"name":"alternative name","manufacturer":"manufacturer","price":"price"}]}]\n'
        'Critical accuracy guidelines:\n'
        '1. Pay extreme attention to the handwritten numbers, dose instructions, and quantities. Read the exact number of tablets/capsules prescribed (e.g. if the doctor wrote "1 tablet" or "১টি করে" or "১+০+১" or "1 time a day", DO NOT return "2 tablets" or "২টি করে"). The dosage and frequency count must be 100% accurate.\n'
        '2. Retrieve the actual, highly accurate retail market price in Bangladesh Taka (৳) for each medicine from your knowledge base. Do not make up mock prices.\n'
        '3. Provide real alternative brands in Bangladesh with their actual retail prices.';

    final mimeType = _getMimeType(imagePath);

    for (final modelName in _models) {
      try {
        print('Prescription - trying model: $modelName');
        final model = _buildModel(modelName);
        final bytes = await File(imagePath).readAsBytes();
        final content = [
          Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
        ];
        final response = await model.generateContent(content);
        final text = response.text;
        if (text == null || text.trim().isEmpty) continue;
        final cleaned = _cleanJson(text);
        final decoded = jsonDecode(cleaned);
        if (decoded is List) return decoded;
      } catch (e) {
        final errMsg = e.toString().toLowerCase();
        if (errMsg.contains('api_key_invalid') ||
            errMsg.contains('api key not valid') ||
            errMsg.contains('invalid api key') ||
            errMsg.contains('socketexception') ||
            errMsg.contains('network') ||
            errMsg.contains('connection')) {
          print('Fatal network or API key error: $e. Aborting model loop.');
          break;
        }
        if (_isQuotaError(e)) {
          print('Quota hit on $modelName, skipping...');
          continue;
        }
        if (_isServerBusyError(e)) {
          print('Server busy on $modelName, waiting 5s and retrying...');
          await Future.delayed(const Duration(seconds: 5));
          try {
            final model = _buildModel(modelName);
            final bytes = await File(imagePath).readAsBytes();
            final content = [
              Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
            ];
            final response = await model.generateContent(content);
            final text = response.text;
            if (text != null && text.trim().isNotEmpty) {
              final cleaned = _cleanJson(text);
              final decoded = jsonDecode(cleaned);
              if (decoded is List) return decoded;
            }
          } catch (_) {
            print('Retry failed on $modelName, skipping...');
          }
          continue;
        }
        print('Unknown error on $modelName: $e, skipping...');
        continue;
      }
    }
    print('All models exhausted.');
    return null;
  }
}
