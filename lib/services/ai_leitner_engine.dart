import 'dart:math';

/// 🧠 Full AI Learning — Leitner + AI Tunable Handles
///
/// Sebastian Leitner published the method in "So lernt man lernen" (1972).
/// No patent. Public domain. We implement from scratch.
///
/// EVERY parameter is a handle the AI can grip.
class AILeitnerEngine {
  final String _userId;
  final String _subject;

  // ─── All handles ──────────────────────────────

  int _numBoxes = 5;                    // 3~10 boxes
  double _promotionSpeed = 1.0;         // 0.5~2.0
  double _demotionSpeed = 1.0;          // 0.5~2.0
  int _promotionStreak = 3;             // 1~5
  int _demotionStreak = 2;              // 1~5
  double _baseInterval = 4.0;           // hours (box 1)
  double _intervalMultiplier = 2.0;     // 각 박스 간격 배수
  double _forgetRate = 0.3;             // 0.1~0.5
  double _fatigue = 0.0;                // 0~1
  int _optimalHour = 10;                // 0~23
  double _accuracy = 0.8;
  double _speed = 1.0;                  // 응답 속도 기반 조정
  int _maxCardsPerSession = 20;

  AILeitnerEngine({required String userId, required String subject})
      : _userId = userId, _subject = subject;

  // ─── AI tunes any handle ──────────────────────

  void tune({
    int? numBoxes, double? promotionSpeed, double? intervalMultiplier,
    int? promotionStreak, double? forgetRate, double? fatigue,
    double? baseInterval, int? maxCardsPerSession,
  }) {
    if (numBoxes != null) _numBoxes = numBoxes.clamp(3, 10);
    if (promotionSpeed != null) _promotionSpeed = promotionSpeed.clamp(0.5, 2.0);
    if (intervalMultiplier != null) _intervalMultiplier = intervalMultiplier.clamp(1.2, 4.0);
    if (promotionStreak != null) _promotionStreak = promotionStreak.clamp(1, 5);
    if (forgetRate != null) _forgetRate = forgetRate.clamp(0.1, 0.5);
    if (fatigue != null) _fatigue = fatigue.clamp(0.0, 1.0);
    if (baseInterval != null) _baseInterval = baseInterval.clamp(1.0, 24.0);
    if (maxCardsPerSession != null) _maxCardsPerSession = maxCardsPerSession.clamp(5, 100);
  }

  // ─── Dynamic box logic ────────────────────────

  int get numBoxes => _numBoxes;

  /// Cards this box can hold before spacing pushes some out
  int boxCapacity(int box) {
    // Higher boxes hold MORE cards (they're already well-learned)
    return (box * 10 * _promotionSpeed).round().clamp(10, 500);
  }

  /// Hours until next review for this box
  int nextInterval(int box) {
    final raw = _baseInterval * pow(_intervalMultiplier, box - 1);
    return (raw * (1 + _forgetRate)).round();
  }

  /// Should promote from box b to b+1?
  bool shouldPromote(int correctStreak) =>
      correctStreak >= (_promotionStreak / _promotionSpeed).round();

  /// Should demote from box b to b-1?
  bool shouldDemote(int wrongStreak) => wrongStreak >= _demotionStreak;

  /// Max cards to show this session (adjusted for fatigue)
  int get cardsThisSession =>
      (_maxCardsPerSession * (1 - _fatigue * 0.5)).round().clamp(3, _maxCardsPerSession);

  // ─── Context for LLM ──────────────────────────

  String get contextForAI => '''
Subject: $_subject
User: $_userId
Accuracy: ${(_accuracy * 100).round()}%
Boxes: $_numBoxes compartments
Promotion: $_promotionStreak correct → up (speed ${_promotionSpeed}x)
Interval base: ${_baseInterval}h, multiplier: ${_intervalMultiplier}x
Forget rate: $_forgetRate
Fatigue: ${(_fatigue * 100).round()}%
Optimal hour: ${_optimalHour}:00
Cards per session: $cardsThisSession
Adjust any parameter based on performance data.
''';
}
