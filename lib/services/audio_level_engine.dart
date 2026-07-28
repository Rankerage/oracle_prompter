/// 🎧 Audio Level Engine — 소리만 듣고 ○✕ 반응
///
/// 절대 텍스트 먼저 보여주지 않음. 소리만.
/// 절대 따라 말하게 하지 않음. 귀찮으면 다 실패.
/// 오직 "들리는가?" 만 묻는다.
class AudioLevelEngine {
  int _level = 1; // 1~10
  int _streak = 0;
  int _failStreak = 0;

  // ─── Level parameters ──────────────────────────

  double get speed => 1.0 + (_level - 1) * 0.15; // 1.0x ~ 2.35x
  int get wordCount => 3 + _level; // 4~13 words
  double get noiseLevel => (_level - 1) * 0.05; // 0.0 ~ 0.45
  int get pauseMs => 2000 - (_level * 100); // 1900ms ~ 1000ms

  String get levelLabel => switch (_level) {
    <= 2 => '기초',
    <= 4 => '초급',
    <= 6 => '중급',
    <= 8 => '상급',
    _ => '원어민',
  };

  // ─── Response → level adjustment ───────────────

  void onCorrect() {
    _streak++;
    _failStreak = 0;
    if (_streak >= 3) {
      _level = (_level + 1).clamp(1, 10);
      _streak = 0;
    }
  }

  void onWrong() {
    _failStreak++;
    _streak = 0;
    if (_failStreak >= 2) {
      _level = (_level - 1).clamp(1, 10);
      _failStreak = 0;
    }
  }

  // ─── Generate prompt for LLM ────────────────────

  String get prompt => '''
Generate an English listening test sentence.
- Speed: ${speed.toStringAsFixed(1)}x natural
- Length: $wordCount words
- Difficulty: $levelLabel (level $_level/10)
- Background: ${(noiseLevel * 100).round()}% ambient noise

Return ONLY the English sentence. No translation. No explanation.
Do NOT include any markdown or quotes.''';
}

/// 📖 Learning Rule — displayed once when user starts listening mode
const listeningRule = '''
듣기 훈련 규칙:

1. 의미를 이해하려고 하지 마세요.
2. 소리가 구분되어 들리는지만 판단하세요.
3. 절대 따라 말하지 마세요. (쉐도잉 금지)
4. ○는 "들려요", ✕는 "안 들려요" 입니다.
5. 틀려도 괜찮아요. 자동으로 난이도가 조절됩니다.
''';
