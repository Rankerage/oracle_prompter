/// 🎧 Self-Voice Coach — 상대방 말을 들을 필요 없음
///
/// 사용자의 목소리만 분석:
///  • 말이 빨라짐 → 진정하라는 신호
///  • 목소리 떨림 → 자신감 있게
///  • "음..." 같은 군말 → 말하기 패턴 교정
///  • 목소리 톤 변화 → 감정 상태 파악
///
/// 통화 상대방 음성 접근 불필요. 마이크만 있으면 됨.
class SelfVoiceCoach {
  double _lastSpeed = 0;
  int _fillerCount = 0;
  DateTime _lastCoaching = DateTime.now();

  /// Analyze user's own speech and return coaching tip (if any)
  String? analyze({
    required String transcript,
    required double speed,       // words per second
    required double pitch,       // voice pitch deviation
    required double energy,      // voice energy/volume
  }) {
    // Rate limit: max one tip per 15 seconds
    if (DateTime.now().difference(_lastCoaching).inSeconds < 15) return null;

    // Speed check
    if (speed > 4.0 && speed > _lastSpeed * 1.3) {
      _lastCoaching = DateTime.now();
      _lastSpeed = speed;
      return '말이 빨라지고 있어요. 천천히 말씀하세요.';
    }

    // Filler words
    final fillers = ['음', '어', '그', '저', '뭐랄까', '그러니까'];
    for (final f in fillers) {
      if (transcript.contains(f)) _fillerCount++;
    }
    if (_fillerCount >= 3) {
      _fillerCount = 0;
      _lastCoaching = DateTime.now();
      return '군말이 많아지고 있어요. 잠시 쉬고 말씀하세요.';
    }

    // Pitch tremor → nervousness
    if (pitch > 0.3) {
      _lastCoaching = DateTime.now();
      return '목소리가 떨리고 있어요. 심호흡 한 번 하세요.';
    }

    // Voice energy drop → losing confidence
    if (energy < 0.2) {
      _lastCoaching = DateTime.now();
      return '목소리가 작아지고 있어요. 자신 있게 말씀하세요.';
    }

    _lastSpeed = speed;
    return null;
  }
}
