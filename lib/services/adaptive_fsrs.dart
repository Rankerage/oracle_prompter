import 'dart:math';

/// 🧠 Adaptive FSRS — 사용자 수준·취향 반영
///
/// FSRS 핸들을 사용자 데이터에 맞춰 자동 조율.
/// 학습 속도·취향·난이도 모두 반영.
class AdaptiveFSRS {
  static final AdaptiveFSRS _i = AdaptiveFSRS._();
  factory AdaptiveFSRS() => _i;
  AdaptiveFSRS._();

  // ─── Per-subject parameters ────────────────────

  final Map<String, _SubjectParams> _subjects = {};

  _SubjectParams _get(String s) => _subjects.putIfAbsent(s, () => _SubjectParams());

  // ─── Record feedback ───────────────────────────

  /// Record a card response: known=true, unknown=false
  void record(String subject, bool known, {int? responseMs}) {
    final p = _get(subject);
    p.total++;
    if (known) p.correct++;
    if (responseMs != null) {
      p.totalResponseMs += responseMs;
      p.responseCount++;
    }

    // Adjust retention target based on rate
    _adapt(subject);
  }

  void _adapt(String subject) {
    final p = _get(subject);
    if (p.total < 5) return;

    final rate = p.correct / p.total;

    // 너무 잘하면 → 더 긴 간격 (지루함 방지)
    if (rate > 0.9) {
      p.intervalMultiplier = (p.intervalMultiplier * 1.2).clamp(0.5, 5.0);
      p.desiredRetention = (p.desiredRetention - 0.02).clamp(0.7, 0.95);
    }
    // 너무 못하면 → 더 짧은 간격 (좌절 방지)
    else if (rate < 0.6) {
      p.intervalMultiplier = (p.intervalMultiplier * 0.8).clamp(0.5, 5.0);
      p.desiredRetention = (p.desiredRetention + 0.02).clamp(0.7, 0.95);
    }
    // 딱 좋으면 → 유지
    else {
      // slight adjustment toward 0.85 target
      p.desiredRetention += (0.85 - p.desiredRetention) * 0.1;
    }

    // Interest weight: higher = show more of this subject
    p.interestWeight = (rate * 0.6 + p.interestWeight * 0.4).clamp(0.1, 2.0);
  }

  // ─── Getters ──────────────────────────────────

  /// How much to show this subject (higher = more)
  double interestWeight(String subject) => _get(subject).interestWeight;

  /// Desired retention rate (0.7-0.95)
  double desiredRetention(String subject) => _get(subject).desiredRetention;

  /// Interval multiplier
  double intervalMultiplier(String subject) => _get(subject).intervalMultiplier;

  /// Accuracy rate
  double accuracy(String subject) {
    final p = _get(subject);
    return p.total > 0 ? p.correct / p.total : 0;
  }

  /// Average response time (ms)
  int avgResponseMs(String subject) {
    final p = _get(subject);
    return p.responseCount > 0 ? p.totalResponseMs ~/ p.responseCount : 800;
  }

  /// Which subjects should be prioritized
  List<String> prioritySubjects() {
    final entries = _subjects.entries.toList()
      ..sort((a, b) => b.value.interestWeight.compareTo(a.value.interestWeight));
    return entries.map((e) => e.key).toList();
  }

  /// Summary
  String summary(String subject) {
    final p = _get(subject);
    return '$subject: 정답률 ${(accuracy(subject)*100).round()}%, '
        '관심도 ${interestWeight(subject).toStringAsFixed(1)}, '
        '간격 ${intervalMultiplier(subject).toStringAsFixed(1)}x';
  }
}

class _SubjectParams {
  int total = 0, correct = 0;
  int totalResponseMs = 0, responseCount = 0;
  double interestWeight = 1.0;
  double desiredRetention = 0.85;
  double intervalMultiplier = 1.0;
}
