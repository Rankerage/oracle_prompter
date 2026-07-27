import 'dart:async';
import 'package:flutter/services.dart';

/// On-device STT using sherpa-onnx
///
/// sherpa_onnx Dart package wraps the C++ ONNX runtime.
/// Supports SenseVoice (Korean), Moonshine (ultra-light), Whisper.
class OnDeviceSttService {
  static const _channel = MethodChannel('sherpa_onnx');
  bool _isInitialized = false;
  bool _isListening = false;
  StreamController<String>? _textController;

  Stream<String>? get textStream => _textController?.stream;
  bool get isListening => _isListening;

  /// Initialize with Korean model
  Future<bool> init({String modelPath = 'default'}) async {
    if (_isInitialized) return true;
    try {
      await _channel.invokeMethod('init', {
        'model': modelPath,
        'language': 'ko',
      });
      _isInitialized = true;
      _textController = StreamController<String>.broadcast();

      _channel.setMethodCallHandler((call) {
        if (call.method == 'onResult') {
          final text = call.arguments as String?;
          if (text != null && text.isNotEmpty) {
            _textController?.add(text);
          }
        }
        return Future.value();
      });

      return true;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized || _isListening) return;
    try {
      await _channel.invokeMethod('start');
      _isListening = true;
    } catch (_) {}
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _channel.invokeMethod('stop');
      _isListening = false;
    } catch (_) {}
  }

  void dispose() {
    stopListening();
    _textController?.close();
  }
}
