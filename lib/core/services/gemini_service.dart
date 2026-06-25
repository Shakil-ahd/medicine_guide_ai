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
    String scannedText,
  ) async {
    final prompt =
        'You are a medical AI assistant for Bangladesh. Analyze this OCR text from a medicine pack:\n'
        '"$scannedText"\n'
        'Return ONLY a valid JSON object (no markdown, no explanation) with this exact structure:\n'
        '{"name":"medicine name in English","genericName":"generic/chemical name",'
        '"manufacturer":"company name","indications":"ব্যবহার বাংলায়",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়","dosage":"মাত্রা বাংলায়",'
        '"instructions":"সেবনবিধি বাংলায়","price":"আনুমানিক মূল্য বাংলায়",'
        '"genericAlternatives":[{"name":"alternative name","manufacturer":"manufacturer","price":"price"}]}';

    for (final modelName in _models) {
      try {
        print('Trying model: $modelName');
        final model = _buildModel(modelName);
        final response = await model.generateContent([Content.text(prompt)]);
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
            final response = await model.generateContent(
              [Content.text(prompt)],
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
        'You are a medical AI assistant for Bangladesh. Read this handwritten prescription image carefully.\n'
        'Extract all medicines listed. For each medicine, provide additional details from your medical knowledge base.\n'
        'Return ONLY a valid JSON array (no markdown, no extra text) with this exact structure:\n'
        '[{"name":"medicine name","purpose":"কেন খেতে হবে বাংলায়",'
        '"dosage":"কীভাবে খেতে হবে বাংলায় (যেমন: ১+০+১ (সকালে ও রাতে ১টি করে))",'
        '"duration":"কতদিন বাংলায়",'
        '"genericName":"generic/chemical name of the medicine in English",'
        '"manufacturer":"Bangladesh company name (manufacturer) in English",'
        '"sideEffects":"পার্শ্বপ্রতিক্রিয়া বাংলায়",'
        '"price":"আনুমানিক মূল্য বাংলায় (যেমন: ৳২.৫ / ট্যাবলেট)",'
        '"genericAlternatives":[{"name":"alternative name","manufacturer":"manufacturer","price":"price"}]}]';

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
