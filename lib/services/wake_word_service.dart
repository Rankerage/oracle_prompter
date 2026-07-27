import 'dart:async';
import 'package:flutter/services.dart';
import '../models/ai_provider.dart';

/// Wake word detection service (Porcupine)
class WakeWordService {
  static const _channel = MethodChannel('porcupine_flutter');
  bool _isListening = false;

  /// Start listening for "O.P" wake word
  Future<bool> start({
    required void Function() onDetected,
  }) async {
    if (_isListening) return true;
    try {
      _channel.setMethodCallHandler((call) {
        if (call.method == 'onWakeWord') {
          onDetected();
        }
        return Future.value();
      });
      _isListening = true;
      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  Future<void> stop() async {
    _isListening = false;
  }

  bool get isListening => _isListening;
}

/// 웨이크워드 서비스 싱글톤
final wakeWord = WakeWordService();
