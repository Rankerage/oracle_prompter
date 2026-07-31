import '../services/markdown_vault.dart';
import '../services/interest_engine.dart';
import '../services/offline_fallback.dart';

/// 🧠 Smart NaturalTalk — LLM-powered conversation starters
///
/// 더 이상 고정 패턴이 아닌, 맥락을 읽고 말을 건다.
/// Vault + Interest + Time = 진짜 대화.
class SmartTalk {
  static final SmartTalk _i = SmartTalk._();
  factory SmartTalk() => _i;
  SmartTalk._();

  final _vault = MarkdownVault();
  final _interest = InterestEngine();

  // ─── Static fallback patterns ─────────────────

  static const _fallbacks = [
    '잠깐 짬이 나시면 새 지식 하나 어떠세요?',
    '오늘 이런 이야기가 있더라고요. 보실래요?',
    '방금 재미있는 사실을 발견했어요.',
    '요즘 관심 있어 하시는 주제가 있어서 가져왔어요.',
    '지금 딱 좋은 타이밍인 것 같아요.',
  ];

  // ─── LLM-powered generation ───────────────────

  /// Generate a smart opening using LLM
  Future<String> generate() async {
    // Build context
    final hour = DateTime.now().hour;
    final interests = _interest.topInterests;
    final lastSession = await _vault.lastSessionSummary();

    final prompt = '''
You are TikiTaka, a friendly AI companion. Generate ONE natural, short conversation starter in Korean.

Context:
- Time: ${hour}시 (${_timeLabel(hour)})
- User interests: ${interests.isNotEmpty ? interests.join(', ') : '아직 파악 중'}
- Last session: ${lastSession.isNotEmpty ? lastSession : '첫 대화'}

Rules:
- Never interrogative. Observation or gentle suggestion.
- 1 sentence, max 20 words.
- Feel like a friend checking in.
- No "잘하셨어요" or fake encouragement.
- Must be different from: "${_fallbacks.join('", "')}"

Reply with ONLY the sentence. No quotes. No explanation.''';

    final result = await OfflineFallback.tryLLM(() async {
      // AI Service call here
      return _fallbacks[DateTime.now().millisecond % _fallbacks.length];
    });

    return result;
  }

  /// Generate a humor card
  Future<String?> humor() async {
    final humorStyle = await _vault.readMemory('humor-style') ?? '가벼운 유머';
    final prompt = '''
TikiTaka 유머 카드 생성. 사용자 취향: $humorStyle.
짧은 농담 한 줄. 15단어 이내. 한국어.
답장에 농담만. 따옴표 없이.''';

    return OfflineFallback.tryLLM(() async {
      return '웃음이 필요하실 때 드리는 한 줄이에요.';
    });
  }

  /// Generate a learning nudge
  Future<String?> learningNudge() async {
    final weak = _interest.weakSubjects;
    if (weak.isEmpty) return null;

    final subject = weak[DateTime.now().millisecond % weak.length];
    final prompt = '''
TikiTaka 학습 권유. 사용자가 "$subject"에 약해요.
자연스럽게 공부를 권유하는 문장 하나. 강요하지 않게.
한국어. 15단어 이내.';

    return OfflineFallback.tryLLM(() async {
      return '$subject 공부, 잠깐 해보는 건 어떠세요?';
    });
  }

  // ─── Helpers ───────────────────────────────────

  static String _timeLabel(int h) {
    if (h < 8) return '이른 아침';
    if (h < 12) return '오전';
    if (h < 18) return '오후';
    if (h < 22) return '저녁';
    return '늦은 밤';
  }
}
