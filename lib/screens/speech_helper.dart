import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class SpeechHelper {
  static final FlutterTts _tts = FlutterTts();
  static bool _isSpeaking = false;
  static bool _isInitialized = false;

  static Future<void> initializeTts() async {
    if (!_isInitialized) {
      try {
        await _tts.setLanguage('en-US'); // Set a default language
        await _tts.setSpeechRate(0.5); // Adjust speed if needed
        await _tts.setVolume(1.0); // Set volume
        await _tts.setPitch(1.0); // Set pitch
        _isInitialized = true;
        developer.log('TTS initialized successfully', name: 'SpeechHelper');
      } catch (e) {
        developer.log('TTS initialization failed: $e', name: 'SpeechHelper');
      }
    }
  }

  static Future<void> speak(String text) async {
    if (_isSpeaking || text.isEmpty) return;

    developer.log('Attempting to speak: $text', name: 'SpeechHelper');
    await stop(); // Ensure any previous speech is stopped

    try {
      await initializeTts(); // Ensure TTS is initialized
      _isSpeaking = true;
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        developer.log('Speech completed: $text', name: 'SpeechHelper');
      });
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        developer.log('Speech error: $msg', name: 'SpeechHelper');
      });
      _tts.setCancelHandler(() {
        _isSpeaking = false;
        developer.log('Speech cancelled: $text', name: 'SpeechHelper');
      });
      var result = await _tts.speak(text);
      if (result != 1) {
        _isSpeaking = false;
        developer.log('Speak failed with result: $result',
            name: 'SpeechHelper');
      }
    } catch (e) {
      _isSpeaking = false;
      developer.log('Speak exception: $e', name: 'SpeechHelper');
    }
  }

  static Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      developer.log('Speech stopped', name: 'SpeechHelper');
    }
  }

  static bool get isSpeaking => _isSpeaking;

  static void dispose() {
    _tts.stop();
    _isSpeaking = false;
    _isInitialized = false;
    developer.log('TTS disposed', name: 'SpeechHelper');
  }
}
