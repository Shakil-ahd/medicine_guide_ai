import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';

class GroqClient {
  static const String _model = 'llama-3.2-11b-vision-preview';
  static const Duration _timeout = Duration(seconds: 25);

  bool get hasKeys => Secrets.groqApiKey.trim().isNotEmpty;

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
    if (!hasKeys) return null;

    debugPrint('[AI Service] Try Groq API...');

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final client = HttpClient();
      final uri = Uri.parse(AppConstants.groqApiUrl);

      debugPrint('[GroqClient] Trying model=$_model');
      final request = await client.postUrl(uri).timeout(_timeout);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer ${Secrets.groqApiKey.trim()}');

      final requestBody = jsonEncode({
        'model': _model,
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
      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = decodedResponse['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            final cleaned = _cleanJson(content);
            final decodedContent = jsonDecode(cleaned) as Map<String, dynamic>;
            debugPrint('[AI Service] ✓ Groq API Success (Model: $_model)');
            return decodedContent;
          }
        }
      } else {
        debugPrint('[GroqClient] API returned error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('[GroqClient] Exception: $e');
    }
    return null;
  }

  Future<List<dynamic>?> parsePrescription(
    String imagePath,
    String prompt,
  ) async {
    if (!hasKeys) return null;

    debugPrint('[AI Service] Try Groq API...');

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final client = HttpClient();
      final uri = Uri.parse(AppConstants.groqApiUrl);

      debugPrint('[GroqClient] Trying model=$_model');
      final request = await client.postUrl(uri).timeout(_timeout);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer ${Secrets.groqApiKey.trim()}');

      final requestBody = jsonEncode({
        'model': _model,
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
      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = decodedResponse['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            final cleaned = _cleanJson(content);
            final decodedContent = jsonDecode(cleaned) as List<dynamic>;
            debugPrint('[AI Service] ✓ Groq API Success (Model: $_model)');
            return decodedContent;
          }
        }
      } else {
        debugPrint('[GroqClient] API returned error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('[GroqClient] Exception: $e');
    }
    return null;
  }
}
