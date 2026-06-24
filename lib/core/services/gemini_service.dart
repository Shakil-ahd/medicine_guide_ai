import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';
import 'package:medicine_guide_ai/core/constants/constants.dart';

class GeminiService {
  static const List<String> _modelFallbacks = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-2.0-flash-lite',
  ];

  static const int _maxRetryWaitSeconds = 15;

  GeminiService() {
    _checkApiKeyAndModels();
  }

  GenerativeModel _buildModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: Secrets.geminiApiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<void> _checkApiKeyAndModels() async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(
        "${AppConstants.modelsUrl}?key=${Secrets.geminiApiKey}",
      );
      final request = await client.getUrl(uri);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final models = json['models'] as List? ?? [];
      final modelNames = models.map((m) => m['name'] as String).toList();
      print("API Key Status Code: ${response.statusCode}");
      print("Available Models: $modelNames");
    } catch (e) {
      print("Failed to verify API key: $e");
    }
  }

  bool _isQuotaError(String message) {
    return message.contains('429') ||
        message.contains('503') ||
        message.contains('quota') ||
        message.contains('UNAVAILABLE') ||
        message.contains('rate') ||
        message.contains('retry');
  }

  double _parseRetrySeconds(String message) {
    final match = RegExp(
      r'retry in ([\d.]+)s',
      caseSensitive: false,
    ).firstMatch(message);
    return double.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  Future<T?> _withRetry<T>(
    Future<T?> Function(GenerativeModel model) fn,
  ) async {
    for (final modelName in _modelFallbacks) {
      final model = _buildModel(modelName);
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          return await fn(model);
        } catch (e) {
          final message = e.toString();
          if (!_isQuotaError(message)) {
            print('Non-retryable error on $modelName: $e');
            break;
          }
          final retrySecs = _parseRetrySeconds(message);
          if (retrySecs > _maxRetryWaitSeconds) {
            print(
              'Retry wait ${retrySecs}s > limit on $modelName. '
              'Switching model...',
            );
            break;
          }
          final waitSecs = retrySecs > 0 ? retrySecs.ceil() : 10;
          print('Quota on $modelName attempt ${attempt + 1}. Waiting ${waitSecs}s...');
          await Future.delayed(Duration(seconds: waitSecs));
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchMedicineDetails(
    String scannedText,
  ) async {
    final prompt = '''
You are a medical AI assistant. Analyze the following raw OCR text scanned from a medicine box or strip:
"$scannedText"
Extract the primary medicine name and structure the response as a JSON object containing details of this medicine. The output must be valid JSON in Bengali, matching this schema:
{
  "name": "Name of the medicine in English",
  "genericName": "Generic name/chemical components in English",
  "manufacturer": "Name of pharmaceutical company in English",
  "indications": "Indications in Bengali",
  "sideEffects": "Common side effects in Bengali",
  "dosage": "Typical dosage instructions in Bengali",
  "instructions": "Consumption guidelines (e.g., after food) in Bengali",
  "price": "Estimated unit price in Bengali",
  "genericAlternatives": [
    {
      "name": "Cheaper alternative medicine name",
      "manufacturer": "Alternative manufacturer",
      "price": "Alternative unit price"
    }
  ]
}
''';

    return _withRetry<Map<String, dynamic>>((model) async {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        return jsonDecode(text) as Map<String, dynamic>;
      }
      return null;
    });
  }

  Future<List<dynamic>?> parsePrescription(String imagePath) async {
    final prompt = '''
You are a medical AI assistant. Scan this handwritten doctor's prescription image. Extract all the prescribed medicines, their purposes, dosages, and duration.
Output a JSON array of objects in Bengali, matching this schema:
[
  {
    "name": "Medicine name",
    "purpose": "Purpose of the medicine in Bengali (কেন খেতে হবে)",
    "dosage": "How to take the medicine in Bengali (কীভাবে খেতে হবে)",
    "duration": "Duration of intake in Bengali (কতদিন খেতে হবে)"
  }
]
''';

    return _withRetry<List<dynamic>>((model) async {
      final bytes = await File(imagePath).readAsBytes();
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
      ];
      final response = await model.generateContent(content);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        return jsonDecode(text) as List<dynamic>;
      }
      return null;
    });
  }
}
