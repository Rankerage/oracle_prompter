import 'fsrs_bridge.dart';

/// 🎯 Next Card Engine with Content Switching
///
/// AI can switch subjects mid-session. User can too.
/// Balance: 70% current subject, 30% variety (humor, news, check-in).
/// Every 10 cards, ask: "계속할까요? 다른 걸로 넘어갈까요?"
class NextCardEngine {
  static final NextCardEngine _i = NextCardEngine._();
  factory NextCardEngine() => _i;
  NextCardEngine._();

  final _rng = DateTime.now().millisecondsSinceEpoch;
  String? _currentSubject;
  int _cardsInSubject = 0;
  int _totalCards = 0;

  // ─── Content switching ─────────────────────────

  /// AI decides next card type and subject
  ({CardSource source, String? subject}) nextCard({
    String? activeSubject,
    FSRSBridge? fsrs,
    bool userWantsSwitch = false,
  }) {
    _totalCards++;

    // User explicitly asked for switch
    if (userWantsSwitch && activeSubject != null) {
      final variety = _varietyPick();
      _cardsInSubject = 0;
      return (source: variety.$1, subject: variety.$2);
    }

    // AI-initiated switch: every ~10 cards, offer variety
    if (_totalCards % 10 == 0 && _totalCards > 0) {
      final variety = _varietyPick();
      return (source: CardSource.nudge, subject: '${activeSubject ?? ""} 계속?');
    }

    // 70% stay on current subject
    if (activeSubject != null && _rng % 100 < 70) {
      _cardsInSubject++;
      _currentSubject = activeSubject;
      // FSRS priority within subject
      if (fsrs != null && fsrs.dueCount > 0) {
        return (source: CardSource.fsrsReview, subject: activeSubject);
      }
      return (source: CardSource.learning, subject: activeSubject);
    }

    // 30% variety
    _currentSubject = null;
    return _varietyPick();
  }

  (CardSource, String?) _varietyPick() {
    final options = [
      (CardSource.engagement, (null as String?)),
      (CardSource.engagement, null),
      (CardSource.general, '뉴스'),
      (CardSource.general, '상식'),
    ];
    final pick = options[_rng % options.length];
    return pick;
  }

enum CardSource { fsrsReview, learning, engagement, nudge, general }

class CardPriority {
  final CardSource type;
  final String data;
  final int priority; // 10=urgent, 1=low
  const CardPriority({required this.type, required this.data, required this.priority});
}
