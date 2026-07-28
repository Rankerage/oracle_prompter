/// 🧠 Full AI Learning — Leitner with AI-tunable handles
///
/// Traditional Leitner: fixed intervals. One-size-fits-all.
/// Full AI Learning:   AI adjusts every parameter per user.
class AILeitnerEngine {
  final String _userId;

  // ─── AI-tunable handles ────────────────────────
  double _promotionSpeed = 1.0;   // 0.5~2.0. Higher = promote faster
  double _demotionSpeed = 1.0;    // 0.5~2.0. Higher = demote faster
  double _intervalScale = 1.0;    // 0.5~2.0. Higher = longer gaps
  int _promotionThreshold = 3;    // consecutive correct to promote
  int _demotionThreshold = 2;     // consecutive wrong to demote
  double _forgetRate = 0.3;       // 0.1~0.5. How fast this user forgets
  double _fatigueFactor = 0.0;    // 0~1. Current mental fatigue
  int _optimalHour = 10;          // Best learning hour (from data)
  double _accuracy = 0.8;         // Rolling accuracy

  // ─── AI can tune these based on user patterns ──

  void tuneByAI({
    double? promotionSpeed,
    double? intervalScale,
    int? promotionThreshold,
    double? forgetRate,
    double? fatigueFactor,
  }) {
    if (promotionSpeed != null) _promotionSpeed = promotionSpeed.clamp(0.5, 2.0);
    if (intervalScale != null) _intervalScale = intervalScale.clamp(0.5, 2.0);
    if (promotionThreshold != null) _promotionThreshold = promotionThreshold.clamp(1, 5);
    if (forgetRate != null) _forgetRate = forgetRate.clamp(0.1, 0.5);
    if (fatigueFactor != null) _fatigueFactor = fatigueFactor.clamp(0.0, 1.0);
  }

  bool shouldPromote(int streak) => streak >= (_promotionThreshold / _promotionSpeed).round();
  bool shouldDemote(int failStreak) => failStreak >= _demotionThreshold;

  /// Get next review interval (hours)
  int nextInterval(int box) {
    final base = [0, 4, 24, 72, 168, 336, 720]; // 0h, 4h, 1d, 3d, 7d, 14d, 30d
    final i = (box.clamp(0, 6) * _intervalScale).round().clamp(0, 6);
    return (base[i] * (1 + _forgetRate)).round();
  }

  AILeitnerEngine(this._userId);

  /// For LLM context — explain current state
  String get contextForAI => '''
User learning profile:
- Accuracy: ${(_accuracy * 100).round()}%
- Promotion speed: ${_promotionSpeed.toStringAsFixed(1)}
- Forget rate: ${_forgetRate.toStringAsFixed(1)}
- Fatigue: ${(_fatigueFactor * 100).round()}%
- Best learning hour: ${_optimalHour}:00
- Current promotion threshold: $_promotionThreshold correct in a row
''';
}
