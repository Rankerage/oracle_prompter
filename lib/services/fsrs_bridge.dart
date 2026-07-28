import 'dart:convert';
import 'package:fsrs/fsrs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🧠 FSRS + Card System Integration
///
/// Maps TokTok's ○✕ card flow → FSRS spaced repetition engine.
/// Handles serialization, due-card queue, and per-subject optimization.
class FSRSBridge {
  final String _userId;
  final String _subject;
  late Scheduler _fsrs;

  /// All cards for this subject. key = card text, value = FSRS Card
  final Map<String, Card> _cards = {};

  /// Cards due for review RIGHT NOW
  List<String> get dueCards =>
      _cards.entries
          .where((e) => e.value.due.isBefore(DateTime.now().toUtc()))
          .map((e) => e.key)
          .toList();

  int get totalCards => _cards.length;
  int get dueCount => dueCards.length;

  FSRSBridge({required String userId, required String subject})
      : _userId = userId, _subject = subject {
    _fsrs = Scheduler(desiredRetention: 0.9);
    _load();
  }

  // ─── Card lifecycle ────────────────────────────

  /// Add a new card to the deck
  Future<void> addCard(String question, String answer) async {
    final card = await Card.create();
    _cards[question] = card;
    await _save();
  }

  /// Get next due card (null if nothing due)
  ({String question, Card card})? nextDue() {
    final due = dueCards;
    if (due.isEmpty) return null;
    final q = due.first;
    return (question: q, card: _cards[q]!);
  }

  /// User reviewed a card. confidence: +2=easy, +1=good, -1=hard, -2=again
  Future<({DateTime nextDue, double retrievability})> review(
      String question, int confidence) async {
    final card = _cards[question];
    if (card == null) throw StateError('Card not found: $question');

    final rating = switch (confidence) {
      >= 2 => Rating.easy,
      1 => Rating.good,
      -1 => Rating.hard,
      _ => Rating.again,
    };

    final result = _fsrs.reviewCard(card, rating);
    _cards[question] = result.card;
    final r = _fsrs.getCardRetrievability(result.card);
    await _save();
    return (nextDue: result.card.due, retrievability: r);
  }

  /// Predict: if I test NOW, what's the recall probability?
  double retrievability(String question) {
    final card = _cards[question];
    return card != null ? _fsrs.getCardRetrievability(card) : 1.0;
  }

  // ─── AI tunable ────────────────────────────────

  void tuneRetention(double r) {
    _fsrs = Scheduler(
      parameters: _fsrs.parameters,
      desiredRetention: r.clamp(0.7, 0.97),
      maximumInterval: 36500,
      enableFuzzing: true,
    );
  }

  double get retention => _fsrs.desiredRetention;

  // ─── Persistence ───────────────────────────────

  static const _prefix = 'fsrs_';

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, String>{};
    for (final e in _cards.entries) {
      data[e.key] = jsonEncode(e.value.toMap());
    }
    await prefs.setString('${_prefix}${_userId}_$_subject', jsonEncode(data));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_prefix}${_userId}_$_subject');
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final e in data.entries) {
      _cards[e.key] = Card.fromMap(jsonDecode(e.value));
    }
  }

  // ─── Stats ─────────────────────────────────────

  double get averageRetrievability {
    if (_cards.isEmpty) return 1.0;
    double sum = 0;
    for (final c in _cards.values) {
      sum += _fsrs.getCardRetrievability(c);
    }
    return sum / _cards.length;
  }

  String get stats => '''
$_subject: ${_cards.length} cards
Due now: ${dueCount} cards
Avg recall: ${(averageRetrievability * 100).round()}%
Retention target: ${(retention * 100).round()}%
''';
}
