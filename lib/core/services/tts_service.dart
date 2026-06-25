import 'package:flutter_tts/flutter_tts.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("bn-BD");
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    double rate = 0.5;
    try {
      final savedRate = await DatabaseHelper.instance.getSetting('tts_speed');
      if (savedRate != null) {
        rate = double.tryParse(savedRate) ?? 0.5;
      }
    } catch (_) {}
    
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
