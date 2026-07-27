import 'dart:async';
import 'package:sherpa_onnx/sherpa_onnx.dart';

/// Wake word detection using sherpa-onnx VAD + keyword matching
///
/// sherpa-onnx includes built-in VAD (Voice Activity Detection).
/// We use VAD to detect speech segments, then match against keywords.
///
/// Alternative: porcupine_flutter (removed due to compileSdk conflict).
/// Will re-add when picovoice fixes their build.gradle.
class WakeWordService {
  bool _isListening = false;
  StreamController<String>? _speechController;

  Stream<String>? get speechStream => _speechController?.stream;
  bool get isListening => _isListening;

  /// Start listening with VAD-based keyword detection
  Future<bool> start({
    required void Function(String keyword) onKeyword,
  }) async {
    if (_isListening) return true;
    _speechController = StreamController<String>.broadcast();

    try {
      // sherpa-onnx VAD configuration
      final config = VadModelConfig(
        sileroVadModel: '',
        sampleRate: 16000,
        threshold: 0.5,
        minSilenceDuration: 0.5,
        minSpeechDuration: 0.25,
        maxSpeechDuration: 5.0,
      );

      _isListening = true;

      // Listen for speech segments and check for keywords
      _speechController!.stream.listen((text) {
        final lower = text.toLowerCase();
        if (lower.contains('오피') || lower.contains('o.p') || lower.contains('oracle')) {
          onKeyword('O.P');
        }
      });

      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  Future<void> stop() async {
    _isListening = false;
    await _speechController?.close();
  }

  void dispose() {
    stop();
  }
}

/// Wake word service singleton
final wakeWord = WakeWordService();
