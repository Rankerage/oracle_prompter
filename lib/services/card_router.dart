import 'package:flutter/material.dart';
import 'conversation_card.dart';

/// 🃏 Routes ALL binary decisions through cards
///
/// Replaces dialogs, toggles, and confirmations.
class CardRouter {
  static final CardRouter _i = CardRouter._();
  factory CardRouter() => _i;
  CardRouter._();

  final List<_DecisionLog> _history = [];
  List<_DecisionLog> get history => List.unmodifiable(_history);

  /// Ask a binary decision via card
  void ask(BuildContext ctx, {
    required CardType type,
    required String statement,
    required String back,
    String pos = '○',
    String neg = '✕',
    void Function(int confidence)? onResult,
  }) {
    showCard(ctx,
      type: type,
      statement: statement,
      backAnswer: back,
      pos: pos, neg: neg,
      onResult: (c) {
        _history.add(_DecisionLog(statement: statement, confidence: c));
        onResult?.call(c);
      },
    );
  }

  /// A/B Test card — compare two options
  void askAB(BuildContext ctx, {
    required String statement,
    required String optionA, required String optionB,
    required String backA, required String backB,
    void Function(bool pickedA)? onResult,
  }) {
    showCard(ctx,
      type: CardType.preference,
      statement: statement,
      backAnswer: '',
      pos: optionA, neg: optionB,
      onResult: (c) => onResult?.call(c >= 0),
    );
  }

  // ─── Pre-built cards ──────────────────────────

  void confirmDelete(BuildContext ctx, String item, VoidCallback onConfirm) {
    ask(ctx,
      type: CardType.checkup,
      statement: '$item 정보를 지울까요?',
      back: '삭제되었습니다. 필요하면 다시 말씀해주세요.',
      pos: '지우기', neg: '유지',
      onResult: (c) { if (c >= 1) onConfirm(); },
    );
  }

  void offerFeature(BuildContext ctx, String feature, String desc, VoidCallback onAccept) {
    ask(ctx,
      type: CardType.news,
      statement: '$feature 기능을 써보시겠어요?',
      back: desc,
      pos: '써볼래요', neg: '나중에',
      onResult: (c) { if (c >= 1) onAccept(); },
    );
  }

  void suggestSwitch(BuildContext ctx, String from, String to, VoidCallback onSwitch) {
    ask(ctx,
      type: CardType.preference,
      statement: '$from보다 $to 방식이 더 나을 것 같아요. 바꿔볼까요?',
      back: '변경되었습니다. 언제든 되돌릴 수 있어요.',
      pos: '바꾸기', neg: '유지',
      onResult: (c) { if (c >= 1) onSwitch(); },
    );
  }

  void notifyReady(BuildContext ctx, String what, VoidCallback onView) {
    ask(ctx,
      type: CardType.reminder,
      statement: '$what 준비됐어요. 지금 보시겠어요?',
      back: '바로가기 알겠습니다.',
      pos: '보기', neg: '나중에',
      onResult: (c) { if (c >= 1) onView(); },
    );
  }
}

class _DecisionLog {
  final String statement;
  final int confidence;
  final DateTime time = DateTime.now();
  const _DecisionLog({required this.statement, required this.confidence});
}
