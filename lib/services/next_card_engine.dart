import 'dart:math';
import 'fsrs_bridge.dart';
import 'interest_engine.dart';

/// 🎯 Next Card Engine — decides what card comes next
///
/// Mixes learning cards + engagement cards at the right ratio.
/// Triangle state manages who's asking.
class NextCardEngine {
  static final NextCardEngine _i = NextCardEngine._();
  factory NextCardEngine() => _i;
  NextCardEngine._();

  final _rng = Random();

  // ─── Triangle state ────────────────────────────

  bool _isUserTurn = false; // ▲=user asking, ▼=AI asking
  int _aiCardsSinceUserTurn = 0;
  static const _maxAiCardsBeforeNudge = 15;

  bool get isUserTurn => _isUserTurn;
  bool get isAiTurn => !_isUserTurn;

  /// User pressed triangle → toggle
  void toggleTurn() {
    _isUserTurn = !_isUserTurn;
    _aiCardsSinceUserTurn = 0;
  }

  /// AI answers user's question → auto-switch back
  void onUserQuestionAnswered() {
    _isUserTurn = false;
    _aiCardsSinceUserTurn = 0;
  }

  /// After many AI cards, nudge: "질문 있으세요?"
  bool get shouldNudgeUserToAsk =>
      !_isUserTurn && _aiCardsSinceUserTurn >= _maxAiCardsBeforeNudge;

  // ─── Card priority queue ────────────────────────

  CardPriority nextCard({String? activeSubject, FSRSBridge? fsrs}) {
    // 1. FSRS due cards (urgent review) — 60% chance
    if (fsrs != null && fsrs.dueCount > 0 && _rng.nextDouble() < 0.6) {
      final due = fsrs.dueCards;
      if (due.isNotEmpty) {
        _aiCardsSinceUserTurn++;
        return CardPriority(type: CardSource.fsrsReview, data: due.first, priority: 10);
      }
    }

    // 2. Active subject learning — 20% chance
    if (activeSubject != null && _rng.nextDouble() < 0.2) {
      _aiCardsSinceUserTurn++;
      return CardPriority(type: CardSource.learning, data: activeSubject, priority: 7);
    }

    // 3. Interest/engagement card — 15% chance
    final interest = InterestEngine();
    final interestCard = interest.getProfileCard() ?? interest.humorCard;
    if (interestCard != null && _rng.nextDouble() < 0.15) {
      _aiCardsSinceUserTurn++;
      return CardPriority(type: CardSource.engagement, data: interestCard, priority: 5);
    }

    // 4. Nudge user to ask (if too many AI cards)
    if (shouldNudgeUserToAsk) {
      return CardPriority(type: CardSource.nudge, data: '질문 있으세요?', priority: 3);
    }

    // 5. Default: new learning card
    _aiCardsSinceUserTurn++;
    return CardPriority(type: CardSource.general, data: '새로운 카드', priority: 1);
  }
}

enum CardSource { fsrsReview, learning, engagement, nudge, general }

class CardPriority {
  final CardSource type;
  final String data;
  final int priority; // 10=urgent, 1=low
  const CardPriority({required this.type, required this.data, required this.priority});
}
