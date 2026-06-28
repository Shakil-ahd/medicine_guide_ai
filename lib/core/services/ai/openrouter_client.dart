import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';

class OpenRouterClient {
  static const Duration _timeout = Duration(seconds: 25);

  bool get hasKeys => Secrets.openRouterApiKey.trim().isNotEmpty;

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

    debugPrint('[AI Service] Try OpenRouter API...');

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final client = HttpClient();
      final uri = Uri.parse(AppConstants.openRouterApiUrl);

      final models = [
        'openrouter/free',
        'nvidia/nemotron-nano-12b-v2-vl:free',
        'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
      ];

      for (final modelName in models) {
        try {
          debugPrint('[OpenRouterClient] Trying model=$modelName');
          final request = await client.postUrl(uri).timeout(_timeout);

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
          final response = await request.close().timeout(_timeout);
          final responseBody = await response.transform(utf8.decoder).join();

          if (response.statusCode == 200) {
            final decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
            final choices = decodedResponse['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final content = choices[0]['message']['content'] as String?;
              if (content != null && content.trim().isNotEmpty) {
                final cleaned = _cleanJson(content);
                final decodedContent = jsonDecode(cleaned) as Map<String, dynamic>;
                debugPrint('[AI Service] ✓ OpenRouter API Success (Model: $modelName)');
                client.close();
                return decodedContent;
              }
            }
          } else {
            debugPrint(
              '[OpenRouterClient] Model $modelName returned error: ${response.statusCode} - $responseBody',
            );
          }
        } catch (e) {
          debugPrint('[OpenRouterClient] Error with model $modelName: $e');
        }
      }
      client.close();
    } catch (e) {
      debugPrint('[OpenRouterClient] Exception: $e');
    }
    return null;
  }

  Future<List<dynamic>?> parsePrescription(
    String imagePath,
    String prompt,
  ) async {
    if (!hasKeys) return null;

    debugPrint('[AI Service] Try OpenRouter API...');

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final client = HttpClient();
      final uri = Uri.parse(AppConstants.openRouterApiUrl);

      final models = [
        'openrouter/free',
        'nvidia/nemotron-nano-12b-v2-vl:free',
        'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
      ];

      for (final modelName in models) {
        try {
          debugPrint('[OpenRouterClient] Trying model=$modelName');
          final request = await client.postUrl(uri).timeout(_timeout);

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
          final response = await request.close().timeout(_timeout);
          final responseBody = await response.transform(utf8.decoder).join();

          if (response.statusCode == 200) {
            final decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
            final choices = decodedResponse['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final content = choices[0]['message']['content'] as String?;
              if (content != null && content.trim().isNotEmpty) {
                final cleaned = _cleanJson(content);
                final decodedContent = jsonDecode(cleaned) as List<dynamic>;
                debugPrint('[AI Service] ✓ OpenRouter API Success (Model: $modelName)');
                client.close();
                return decodedContent;
              }
            }
          } else {
            debugPrint(
              '[OpenRouterClient] Model $modelName returned error: ${response.statusCode} - $responseBody',
            );
          }
        } catch (e) {
          debugPrint('[OpenRouterClient] Error with model $modelName: $e');
        }
      }
      client.close();
    } catch (e) {
      debugPrint('[OpenRouterClient] Exception: $e');
    }
    return null;
  }
}
