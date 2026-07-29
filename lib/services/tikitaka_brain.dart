import '../services/markdown_vault.dart';
import '../services/interest_engine.dart';
import '../services/fsrs_bridge.dart';
import '../services/ai_leitner_engine.dart';

/// 🧠 TikiTaka Brain — the central intelligence
///
/// Connects all subsystems to create a truly smart companion.
/// Every decision passes through here.
class TikiTakaBrain {
  static final TikiTakaBrain _i = TikiTakaBrain._();
  factory TikiTakaBrain() => _i;
  TikiTakaBrain._();

  final MarkdownVault _vault = MarkdownVault();
  final InterestEngine _interest = InterestEngine();
  final Map<String, FSRSBridge> _subjects = {};

  bool _initialized = false;

  Future<void> init() async {
    await _vault.init();
    _initialized = true;
  }

  // ─── Cross-session memory ──────────────────────

  /// Recall past context: "What did I tell you about X last time?"
  Future<String> recall(String topic) async {
    final memories = await _vault.readMemories();
    if (memories.contains(topic)) {
      // Extract relevant lines
      final lines = memories.split('\n').where((l) => l.contains(topic)).take(3);
      return lines.isNotEmpty
          ? '이전에 $topic에 대해 말씀하신 내용이 있어요:\n${lines.join('\n')}'
          : '';
    }
    return '';
  }

  // ─── Smart card generation ─────────────────────

  /// Generate a context-aware card statement
  Future<String> generateCard() async {
    // 1. Check if any subject needs review
    for (final subj in _subjects.keys) {
      final due = _subjects[subj]!.dueCount;
      if (due > 0) {
        return '$subj 복습 카드가 $due장 있어요. 지금 하실래요?';
      }
    }

    // 2. Check interest profile
    final profile = _interest.profile;
    if (profile.contains('영어') && _interest.learningNudge != null) {
      return _interest.learningNudge!;
    }

    // 3. Check humor
    if (_interest.humorCard != null) return _interest.humorCard!;

    // 4. Check profile gaps
    final gap = _interest.getProfileCard();
    if (gap != null) return gap;

    // 5. Default
    return '새로운 것을 알려드릴까요?';
  }

  // ─── Record and learn ──────────────────────────

  Future<void> onCardResponse(String statement, int confidence) async {
    // Log to vault
    await _vault.logCardResponse(statement, confidence);

    // Update interest profile
    if (statement.contains('영어')) {
      _interest.recordInterest('영어', confidence >= 1);
      if (confidence >= 1) _interest.recordLearningStart();
    }
    if (statement.contains('유머') || statement.contains('재미')) {
      _interest.recordHumorReaction(confidence >= 1);
    }

    // Update memory fact if strong signal
    if (confidence >= 2) {
      await _vault.writeMemory('preferences', '사용자가 "$statement"에 ○를 눌렀습니다.');
    }
  }

  // ─── Subject management ────────────────────────

  FSRSBridge getSubject(String subject) {
    return _subjects.putIfAbsent(subject,
        () => FSRSBridge(userId: 'default', subject: subject));
  }

  // ─── LLM context builder ───────────────────────

  Future<String> getLLMContext() async {
    final vault = await _vault.buildLLMContext();
    final interests = _interest.profile;
    final subjects = _subjects.entries
        .map((e) => e.value.stats)
        .join('\n');
    return '''
$vault

## 관심사 프로필
$interests

## 학습 현황
$subjects
''';
  }

  // ─── Stats ─────────────────────────────────────

  String get stats => '''
TikiTaka Brain 상태:
저장소: ${_initialized ? "활성" : "미초기화"}
관심사: ${_interest.topInterests.length}개 파악
학습 과목: ${_subjects.length}개
''';
}
