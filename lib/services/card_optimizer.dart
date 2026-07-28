import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/conversation_card.dart';

/// 🎯 Card-Based Continuous Optimizer
///
/// Periodically asks users about every tunable parameter.
/// Uses Leitner spacing — confirmed preferences stop being asked.
class CardOptimizer {
  static final CardOptimizer _i = CardOptimizer._();
  factory CardOptimizer() => _i;
  CardOptimizer._();

  final Map<String, _Tunable> _tunables = {};
  int _coachingCount = 0;
  static const _askAfterNCoaching = 5; // Ask after every N coaching events

  // ─── Registration ──────────────────────────────

  void register(String id, String label, double current, double min, double max, double step,
      {required String cardStatement, required String backTemplate, void Function(double)? onChanged}) {
    _tunables[id] = _Tunable(
      id: id, label: label, value: current,
      min: min, max: max, step: step,
      cardStatement: cardStatement, backTemplate: backTemplate,
      onChanged: onChanged,
    );
  }

  // ─── Trigger after coaching ────────────────────

  void onCoachingEvent() {
    _coachingCount++;
    // Don't ask here — card queue handles timing
  }

  /// Get next tunable to ask about (Leitner-filtered)
  _Tunable? _nextToAsk() {
    final candidates = _tunables.values.where((t) => t.shouldAsk).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.priority.compareTo(b.priority));
    return candidates.first;
  }

  /// Ask the next optimization question (call periodically)
  void askNext(BuildContext ctx) {
    final tunable = _nextToAsk();
    if (tunable == null) return;

    final isUp = tunable.value < (tunable.max - tunable.step);
    final direction = isUp ? '늘려' : '줄여';
    final newValue = isUp
        ? (tunable.value + tunable.step).clamp(tunable.min, tunable.max)
        : (tunable.value - tunable.step).clamp(tunable.min, tunable.max);

    showCard(ctx,
      type: CardType.preference,
      statement: tunable.cardStatement.replaceAll('{direction}', direction),
      backAnswer: tunable.backTemplate
          .replaceAll('{current}', tunable.value.toStringAsFixed(1))
          .replaceAll('{new}', newValue.toStringAsFixed(1)),
      pos: '○', neg: '✕',
      onResult: (confidence) {
        if (confidence >= 0) {
          tunable.value = newValue;
          tunable.onChanged?.call(newValue);
          tunable.confirm(); // Move up Leitner box
        } else {
          tunable.deny(); // Stay or move down
        }
        tunable.save();
      },
    );
  }

  // ─── Pre-built tunables ────────────────────────

  void initDefaults() {
    register('coaching_frequency', '코칭 빈도', 3.0, 1.0, 10.0, 1.0,
      cardStatement: '코칭을 조금 더 자주 해드려도 될까요?',
      backTemplate: '지금은 대화 {current}회마다 코칭해드려요.\n더 자주 필요하시면 ○를 눌러주세요.');

    register('coaching_detail', '코칭 상세도', 2.0, 1.0, 5.0, 1.0,
      cardStatement: '코칭 내용을 좀 더 자세히 설명해드릴까요?',
      backTemplate: '지금은 핵심만 간단히 알려드리고 있어요.\n더 자세히 설명해드릴까요?');

    register('voice_speed', '음성 속도', 2.0, 1.0, 5.0, 1.0,
      cardStatement: '목소리 속도를 조금 더 빠르게 할까요?',
      backTemplate: '지금 속도면 편하게 들리실 거예요.\n더 빠르게 원하시면 ○를 눌러주세요.');

    register('card_frequency', '카드 빈도', 3.0, 1.0, 8.0, 1.0,
      cardStatement: '이런 카드를 조금 더 자주 보여드려도 될까요?',
      backTemplate: '너무 자주 물어보면 피곤하실 수 있어요.\n더 자주 원하시면 ○를 눌러주세요.');

    register('vision_interval', '화면 분석 간격', 4.0, 2.0, 15.0, 1.0,
      cardStatement: '화면 분석 간격을 넓혀도 될까요?',
      backTemplate: '더 자주 분석하면 배터리를 더 써요.\n배터리를 아끼려면 ○를 눌러주세요.');

    register('graph_detail', '그래프 상세도', 3.0, 1.0, 5.0, 1.0,
      cardStatement: '마인드 그래프를 좀 더 자세히 보여드릴까요?',
      backTemplate: '노드가 많으면 복잡해 보일 수 있어요.\n더 자세히 보시려면 ○를 눌러주세요.');
  }

  /// Was the last coaching helpful?
  void askCoachingQuality(BuildContext ctx, String lastTip) {
    showCard(ctx,
      type: CardType.checkup,
      statement: '방금 코칭, 도움이 되셨나요?',
      backAnswer: '피드백 감사합니다. 앞으로 더 나은 타이밍에 더 좋은 내용으로 찾아뵐게요.',
      pos: '○', neg: '✕',
      onResult: (confidence) {
        if (confidence < 0) {
          // User said No — adjust immediately
          _tunables['coaching_frequency']?.value =
              (_tunables['coaching_frequency']!.value + 1).clamp(1.0, 10.0);
        }
      },
    );
  }
}

// ─── Internal ────────────────────────────────────

class _Tunable {
  final String id;
  final String label;
  double value;
  final double min, max, step;
  final String cardStatement;
  final String backTemplate;
  final void Function(double)? onChanged;
  int _leitnerBox = 1;
  final int priority; // Higher = ask first

  _Tunable({
    required this.id, required this.label, required this.value,
    required this.min, required this.max, required this.step,
    required this.cardStatement, required this.backTemplate,
    this.onChanged, this.priority = 5,
  });

  bool get shouldAsk => _leitnerBox < 5;

  void confirm() => _leitnerBox = (_leitnerBox + 2).clamp(1, 5);
  void deny() => _leitnerBox = (_leitnerBox - 1).clamp(1, 5);

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('opt_${id}_val', value);
    prefs.setInt('opt_${id}_box', _leitnerBox);
  }

  static Future<void> loadAll(Map<String, _Tunable> tunables) async {
    final prefs = await SharedPreferences.getInstance();
    for (final t in tunables.values) {
      t.value = prefs.getDouble('opt_${t.id}_val') ?? t.value;
      t._leitnerBox = prefs.getInt('opt_${t.id}_box') ?? 1;
    }
  }
}
