import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// STT 서비스 - 실시간 음성 인식
class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _initialized = false;
  StreamController<String>? _textController;
  Stream<String>? get textStream => _textController?.stream;
  bool get isListening => _isListening;

  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return _initialized;
  }

  /// 듣기 시작
  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'ko_KR',
  }) async {
    if (!_initialized) {
      final ok = await init();
      if (!ok) return;
    }
    if (_isListening) return;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  /// 듣기 중지
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _textController?.close();
  }
}
