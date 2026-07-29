/// 🗣️ Natural Conversation Starters — 거부감 없는 말걸기
///
/// Principles:
/// 1. Never interrogative. Always observation or gentle suggestion.
/// 2. Vary the pattern. Not the same opener every time.
/// 3. Match user's known interests.
/// 4. Feel like a friend, not a teacher.
class NaturalTalk {
  static final NaturalTalk _i = NaturalTalk._();
  factory NaturalTalk() => _i;
  NaturalTalk._();

  final _rng = DateTime.now().millisecondsSinceEpoch;
  int _lastPattern = -1;

  // ─── Starter patterns (rotate through them) ────

  String _nextPattern() {
    final patterns = [0, 1, 2, 3, 4, 5];
    patterns.shuffle();
    if (patterns.first == _lastPattern) {
      _lastPattern = patterns[1];
      return _patterns[patterns[1]]!();
    }
    _lastPattern = patterns.first;
    return _patterns[patterns.first]!();
  }

  // ─── Pattern generators ────────────────────────

  final Map<int, String Function()> _patterns = {
    // Pattern 0: Discovery — "방금 재미있는 표현을 발견했어요"
    0: () {
      final items = ['표현', '용어', '단어', '이야기', '사실'];
      return '방금 재미있는 ${items[_i._rng % items.length]}을 발견했어요.';
    },

    // Pattern 1: Observation — "요즘 부쩍 ~에 관심이 많으신 것 같아요"
    1: () {
      final topics = ['영어', '새로운 지식', 'IT', '트렌드'];
      return '요즘 부쩍 ${topics[_i._rng % topics.length]}에 관심이 많으신 것 같아요.';
    },

    // Pattern 2: Gentle invite — "잠깐 짬이 나시면 ~해보는 건 어떠세요?"
    2: () {
      final actions = ['새 단어 하나 보고 가기', '짧은 복습', '재미있는 상식 하나'];
      return '잠깐 짬이 나시면 ${actions[_i._rng % actions.length]} 해보는 건 어떠세요?';
    },

    // Pattern 3: Sharing — "오늘 이런 게 있더라고요"
    3: () => '오늘 이런 게 있더라고요. 잠깐 보실래요?',

    // Pattern 4: Reminder — "아까 배우셨던 그거, 기억나세요?"
    4: () => '아까 배우셨던 표현, 아직 기억나시는지 궁금해요.',

    // Pattern 5: Mood-based — "지금 딱 좋은 타이밍인 것 같아요"
    5: () => '지금 딱 좋은 타이밍인 것 같아요. 짧게 하나 해볼까요?',
  };

  // ─── Generate a card statement ──────────────────

  String generate({String? interest}) {
    final base = _nextPattern();
    if (interest != null && _rng % 3 == 0) {
      return '$base $interest에 관한 거예요.';
    }
    return base;
  }

  // ─── Response tone (card back) ──────────────────
  // Rule: no fake encouragement. No patronizing.
  // Just the facts. Just the next card.

  static String back(bool correct) => ''; // Nothing. The answer speaks for itself.

  // ─── Time-sensitive openers ─────────────────────

  static String timeBased() {
    final h = DateTime.now().hour;
    if (h < 8) return '좋은 아침이에요. 가볍게 하나 시작해볼까요?';
    if (h < 12) return '오전에 집중이 잘 되실 때 짧게 해보는 건 어떠세요?';
    if (h < 18) return '오후의 작은 쉼표로 하나 가져왔어요.';
    if (h < 22) return '하루 마무리 전에 하나 더 보시면 좋을 것 같아요.';
    return '늦은 시간이지만, 잠깐 봐도 괜찮으시면 하나 보여드릴게요.';
  }
}
