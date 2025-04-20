// lib/flutter_speech_recognition_windows.dart
import 'dart:async';
import 'package:flutter/services.dart';

class FlutterSpeechRecognitionWindows {
  static const MethodChannel _channel =
      MethodChannel('flutter_speech_recognition_windows');
  static final StreamController<String> _speechStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get onSpeechResult => _speechStreamController.stream;

  static Future<bool> initialize() async {
    try {
      return await _channel.invokeMethod('initialize');
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  static Future<void> startListening() async {
    try {
      await _channel.invokeMethod('startListening');
    } catch (e) {
      print('Error starting speech recognition: $e');
    }
  }

  static Future<void> stopListening() async {
    try {
      await _channel.invokeMethod('stopListening');
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  static void handleSpeechResult(String result) {
    _speechStreamController.add(result);
  }
}
