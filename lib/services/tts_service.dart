// Windows-safe stub — flutter_tts not available
class TtsService {
  static final TtsService _i = TtsService._();
  factory TtsService() => _i;
  TtsService._();
  Future<void> speak(String text) async {}
  Future<void> whisper(String text) async {}
  Future<void> stop() async {}
  Future<void> setVolume(double v) async {}
  Future<void> setSpeechRate(double r) async {}
  Future<void> sayModeEntry(dynamic mode) async {}
}
