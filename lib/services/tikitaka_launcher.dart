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
    // Card 1: Welcome
    await _show('AI와 티키타카, 시작해볼까요?',
      '짧은 패스를 주고받듯 대화하는 AI예요.\n○나 ✕만 누르면 됩니다.',
      '○', '✕');

    // Card 2: Mic (optional)
    await _show('마이크를 허용하시면\n목소리로도 대화할 수 있어요.',
      '설정 → 앱 → TikiTaka → 권한 → 마이크\n\n허용하지 않아도 카드는 사용할 수 있어요.',
      '허용', '나중에');

    // Card 3: Philosophy
    await _show('TikiTaka에는 정답도 오답도 없어요.\n그냥 "안다"와 "아직"만 있어요.',
      '부담 없이 ○와 ✕를 눌러주세요.\n일주일이면 당신을 완벽히 알게 돼요.',
      '시작!', '✕');
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
