import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medicine_guide_ai/core/config/secrets.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: Secrets.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<Map<String, dynamic>?> fetchMedicineDetails(String scannedText) async {
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

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        return jsonDecode(text) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
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

    try {
      final bytes = await File(imagePath).readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        return jsonDecode(text) as List<dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
