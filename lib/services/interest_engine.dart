import '../widgets/conversation_card.dart';

/// 🎯 Interest Engine — 사용자의 구미를 파악하는 엔진
///
/// 틈틈이 질문. 관심사 파악. 맞춤 컨텐츠 배달.
/// 한 달이면 "나보다 나를 더 잘 아는 앱" 완성.
class InterestEngine {
  static final InterestEngine _i = InterestEngine._();
  factory InterestEngine() => _i;
  InterestEngine._();

  // ─── User profile (accumulated over time) ─────

  final Map<String, double> _interests = {};
  double _humorPreference = 0.5;
  double _learningMotivation = 0.5;
  String? _favoriteTime;

  // ─── Proactive actions ─────────────────────────

  /// Mix a profile question into the card flow (1 in 15 cards)
  String? getProfileCard() {
    // Pick the most uncertain interest
    if (_interests.isEmpty) return ProfileChip.values.first.statement;
    final leastKnown = _interests.entries
        .where((e) => e.value < 0.3)
        .toList();
    leastKnown.sort((a, b) => a.value.compareTo(b.value));
    return leastKnown.isNotEmpty
        ? '${leastKnown.first.key}에 관심이 있으세요?'
        : null;
  }

  /// Deliver humor based on taste
  String? get humorCard {
    if (_humorPreference > 0.7) {
      return '재미있는 농담 하나 가져왔어요. 들어보실래요?';
    }
    return null;
  }

  /// Proactive learning suggestion
  String? get learningNudge {
    if (_learningMotivation > 0.5 && _interests.containsKey('영어')) {
      return '영어 단어 공부, 지금 시작하기 딱 좋은 시간이에요.';
    }
    return null;
  }

  /// Time-based greeting
  String? get timeGreeting {
    final hour = DateTime.now().hour;
    if (hour == _favoriteTime && _learningMotivation > 0.6) {
      return '평소에 공부 잘 되는 시간이에요. 오늘도 시작해볼까요?';
    }
    return null;
  }

  // ─── Record user feedback ─────────────────────

  void recordInterest(String topic, bool interested) {
    final current = _interests[topic] ?? 0.5;
    _interests[topic] = interested
        ? (current + 0.2).clamp(0.0, 1.0)
        : (current - 0.1).clamp(0.0, 1.0);
  }

  void recordHumorReaction(bool liked) {
    _humorPreference = liked
        ? (_humorPreference + 0.1).clamp(0.0, 1.0)
        : (_humorPreference - 0.1).clamp(0.0, 1.0);
  }

  void recordLearningStart() {
    _learningMotivation = (_learningMotivation + 0.15).clamp(0.0, 1.0);
  }

  // ─── Profile summary ──────────────────────────

  List<String> get topInterests => _interests.entries
      .where((e) => e.value > 0.6)
      .map((e) => e.key)
      .toList();

  String get profile => '''
관심사: ${topInterests.isNotEmpty ? topInterests.join(', ') : '수집 중...'}
유머 선호: ${(_humorPreference * 100).round()}%
학습 의욕: ${(_learningMotivation * 100).round()}%
잘 아는 시간: ${_favoriteTime ?? '파악 중...'}
''';
}
