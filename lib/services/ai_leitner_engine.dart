import 'package:fsrs/fsrs.dart';

/// 🧠 Full AI Learning — FSRS with AI-tunable handles
///
/// FSRS (Free Spaced Repetition Scheduler) — Anki's next-gen algorithm.
/// 21 parameters. 4-level rating. AI can tune everything.
class AILeitnerEngine {
  final String _userId;
  final String _subject;
  late Scheduler _fsrs;

  // ─── AI-tunable FSRS handles ──────────────────

  double _desiredRetention = 0.9;   // 0.7~0.97. Main handle.
  int _maximumInterval = 36500;     // days
  bool _enableFuzzing = true;
  List<double> _parameters = [      // 21 model weights
    0.2172, 1.1771, 3.2602, 16.1507, 7.0114, 0.57, 2.0966, 0.0069,
    1.5261, 0.112, 1.0178, 1.849, 0.1133, 0.3127, 2.2934, 0.2191,
    3.0004, 0.7536, 0.3332, 0.1437, 0.2,
  ];

  AILeitnerEngine({required String userId, required String subject})
      : _userId = userId, _subject = subject {
    _rebuild();
  }

  void _rebuild() {
    _fsrs = Scheduler(
      parameters: _parameters,
      desiredRetention: _desiredRetention,
      maximumInterval: _maximumInterval,
      enableFuzzing: _enableFuzzing,
    );
  }

  // ─── AI tunes any handle ──────────────────────

  void tune({
    double? desiredRetention,
    List<double>? parameters,
  }) {
    if (desiredRetention != null) {
      _desiredRetention = desiredRetention.clamp(0.7, 0.97);
    }
    if (parameters != null && parameters.length == 21) {
      _parameters = parameters;
    }
    _rebuild();
  }

  /// Map O/X double-tap confidence to FSRS rating
  Rating _oxToRating(int confidence) => switch (confidence) {
    >= 2 => Rating.easy,    // ○→○ = strong yes
    1 => Rating.good,        // ✕→○ = learned
    -1 => Rating.hard,       // ○→✕ = unsure
    _ => Rating.again,       // ✕→✕ = strong no
  };

  /// Review a card. Returns (nextDue, retrievability)
  ({DateTime due, double retrievability}) review(Card card, int confidence) {
    final rating = _oxToRating(confidence);
    final result = _fsrs.reviewCard(card, rating);
    final retrievability = _fsrs.getCardRetrievability(result.card);
    return (due: result.card.due, retrievability: retrievability);
  }

  /// Current probability of remembering a card (0~1)
  double retrievability(Card card) => _fsrs.getCardRetrievability(card);

  // ─── Context for LLM ──────────────────────────

  String get contextForAI => '''
FSRS Scheduler for $_subject (user: $_userId)
Desired retention: ${(_desiredRetention * 100).round()}%
Maximum interval: $_maximumInterval days
Fuzzing: $_enableFuzzing
21 parameters (AI can optimize all).
Current params: ${_parameters.take(5).map((p) => p.toStringAsFixed(3)).join(', ')}...
''';
}
