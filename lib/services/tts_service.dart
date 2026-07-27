import 'package:flutter_tts/flutter_tts.dart';
import '../models/oracle_mode.dart';

/// TTS 서비스 - AI 코치의 귓속말 음성 출력
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('ko-KR');
    await _tts.setPitch(0.9); // 약간 낮은 톤 (은밀한 귓속말 느낌)
    await _tts.setSpeechRate(0.48); // 느리게 (차분한 귓속말)
    await _tts.setVolume(0.7);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
    _initialized = true;
  }

  /// 귓속말 모드로 말하기
  Future<void> whisper(String text) async {
    await init();
    await _tts.setPitch(0.85);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(0.6);
    await _tts.speak(text);
  }

  /// 일반 코치 모드로 말하기
  Future<void> speak(String text) async {
    await init();
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(0.75);
    await _tts.speak(text);
  }

  /// 긴급 알림
  Future<void> alert(String text) async {
    await init();
    await _tts.setPitch(0.95);
    await _tts.setSpeechRate(0.55);
    await _tts.setVolume(0.85);
    await _tts.speak(text);
  }

  /// 중지
  Future<void> stop() async {
    await _tts.stop();
  }

  /// 모드에 맞는 시작 멘트
  Future<void> sayModeEntry(OracleMode mode) async {
    final messages = {
      OracleMode.defense: '방어 모드 활성화. 볼륨 버튼 두 번으로 노이즈 공격을 시작하세요.',
      OracleMode.persuasion: '설득 모드입니다. 상대의 심리를 실시간 분석합니다.',
      OracleMode.refresh: '상쾌 모드. 대화 후 좋은 기분을 남겨드립니다.',
      OracleMode.translate: '통역 모드 준비 완료. 말씀하시면 실시간 통역합니다.',
    };
    await speak(messages[mode] ?? '오라클 프롬프터가 작동합니다.');
  }

  void dispose() {
    _tts.stop();
  }
}
