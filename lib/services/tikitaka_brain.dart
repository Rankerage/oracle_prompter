import 'adaptive_fsrs.dart';
import 'content_fsrs.dart';
import 'card_factory.dart';
import 'markdown_vault.dart';
import 'smart_adjuster.dart';
import 'persona_engine.dart';
import 'daily_insight.dart';

/// 🧠 TikiTaka Brain — 학습기록 → LLM 분석 → 가중치 업그레이드
///
/// 1. 모든 사용자 반응 수집
/// 2. 통계로 가공
/// 3. LLM에게 전달할 컨텍스트 생성
/// 4. LLM의 제안을 받아 가중치 업데이트
class TikiTakaBrain {
  static final TikiTakaBrain _i = TikiTakaBrain._();
  factory TikiTakaBrain() => _i;
  TikiTakaBrain._();

  final _fsrs = AdaptiveFSRS();
  final _content = ContentFSRS();
  final _vault = MarkdownVault();
  final _adjuster = SmartAdjuster();
  final _persona = PersonaEngine();
  final _insight = DailyInsight();
  final _history = <_LogEntry>[];

  // ─── Recording ─────────────────────────────────

  void recordCard({
    required String subject, required bool known,
    DateTime? time, int? responseMs,
  }) {
    final now = time ?? DateTime.now();
    _fsrs.record(subject, known, responseMs: responseMs);
    _vault.record(subject, known, responseMs: responseMs);
    _adjuster.record(subject:subject, known:known,
        responseMs:responseMs??800, hourOfDay:now.hour);
    _persona.record(subject:subject, known:known,
        hour:now.hour, responseMs:responseMs??800);
    _history.add(_LogEntry(
      time: now, subject: subject, known: known, responseMs: responseMs,
    ));
    if (_history.length > 1000) _history.removeRange(0, 100);
  }

  void recordSubjectChange(String from, String to) {
    _history.add(_LogEntry(
      time: DateTime.now(),
      subject: '→$to',
      known: true,
    ));
  }

  // ─── Statistics ────────────────────────────────

  /// Session summary
  Map<String, dynamic> get stats {
    final recent = _history.where((e) =>
      e.time.isAfter(DateTime.now().subtract(const Duration(hours: 24)))).toList();
    final bySubject = <String, int>{};
    for (final e in recent) {
      bySubject[e.subject] = (bySubject[e.subject] ?? 0) + 1;
    }
    return {
      'today': recent.length,
      'bySubject': bySubject,
      'subjects': _subjects.map((s) => {
        'subject': s,
        'accuracy': _fsrs.accuracy(s),
        'interest': _fsrs.interestWeight(s),
        'interval': _fsrs.intervalMultiplier(s),
        'retention': _fsrs.desiredRetention(s),
        'avgResponseMs': _fsrs.avgResponseMs(s),
        'deckSize': CardFactory.deckSize(s),
        'useFSRS': _content.useFSRS(s),
      }).toList(),
      'priority': _fsrs.prioritySubjects(),
    };
  }

  // ─── LLM Context Builder ───────────────────────

  /// Build a prompt for the LLM to analyze and suggest upgrades
  String buildLLMContext() => _insight.buildLLMPrompt();

  /// Top insight to show the user
  String get topInsight => _insight.topInsight;

  /// User persona
  String get personaName => _persona.personaName;

  /// Generate user-facing insight cards
  List<String> get userInsights => _insight.generateUserInsights();

  // ─── LLM Feedback → Apply ──────────────────────

  /// Apply LLM's suggestions
  void applyAdjustments(Map<String, dynamic> json) {
    // Example: {"adjustments": [{"subject":"영어","action":"moreCards","value":50}]}
    // This would trigger CardFactory.generateFromLLM()
    if (json['newCards'] is List) {
      for (final nc in json['newCards']) {
        final subject = nc['subject'] as String;
        final cards = (nc['cards'] as List).cast<String>();
        _content.addNewCards(subject, cards);
      }
    }
  }

  // ─── Subject suggestion ────────────────────────

  static const _subjects = ['영어','영어듣기','신조어','수학','상식','유머','뉴스','팔로우'];

  /// What subject should the user try next?
  String suggestNextSubject() {
    final priority = _fsrs.prioritySubjects();
    // Find the highest priority subject with cards available
    for (final s in priority) {
      if (CardFactory.deckSize(s) > 0) return s;
    }
    return '영어';
  }

  /// Is user bored? (high accuracy, fast responses → need new content)
  bool get isBored {
    final eng = _fsrs.accuracy('영어');
    final avg = _fsrs.avgResponseMs('영어');
    return eng > 0.85 && avg < 500;
  }

  /// Is user struggling? (low accuracy → need easier content)
  bool get isStruggling {
    final eng = _fsrs.accuracy('영어');
    return eng < 0.4 && _history.length > 20;
  }

  /// Should we introduce a new subject?
  String? get newSubjectToIntroduce {
    final tried = _history.map((e) => e.subject).toSet();
    for (final s in _subjects) {
      if (!tried.contains(s) && CardFactory.deckSize(s) > 0) return s;
    }
    return null;
  }
}

class _LogEntry {
  final DateTime time;
  final String subject;
  final bool known;
  final int? responseMs;
  const _LogEntry({
    required this.time, required this.subject,
    required this.known, this.responseMs,
  });
}
