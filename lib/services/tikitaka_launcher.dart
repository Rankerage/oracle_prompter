import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/conversation_card.dart';

/// 🚀 TikiTaka First Launch — single card, then go
///
/// No wizard. No setup. No account.
/// Just one card: "AI를 배우고 싶으세요?"
/// Tap ○ → AI starts talking.
class TikiTakaLauncher {
  final BuildContext _ctx;

  TikiTakaLauncher(this._ctx);

  Future<void> run() async {
    // Only one card. Welcome + start.
    await _show(
      'AI와 티키타카, 시작해볼까요?',
      '짧은 패스를 주고받듯 대화하는 AI예요.\n○나 ✕만 누르면 됩니다.\n일주일이면 당신을 완벽히 알게 돼요.',
      '○', '✕',
    );
    // Done. AI starts talking immediately.
  }

  Future<void> _show(String statement, String back, String pos, String neg) async {
    final completer = Completer<void>();
    showCard(_ctx,
      type: CardType.preference,
      statement: statement, backAnswer: back,
      pos: pos, neg: neg,
      onResult: (_) => completer.complete(),
    );
    return completer.future;
  }
}
