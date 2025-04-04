import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class SpeechHelper {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    debugPrint('Attempting to speak: $text');
    var result = await _tts.speak(text); // Skip language check for now
    debugPrint('Speak result: $result'); // 1 = success, 0 = failure
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
