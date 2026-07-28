import 'dart:async';
import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/card_queue_service.dart';
import '../widgets/conversation_card.dart';

/// 🚀 Card-First Launcher — 모델 없이도 작동하는 부트스트랩
///
/// Hermes CLI의 문제: 모델 없으면 완전 먹통.
/// O.P의 해결: 카드 시스템은 순수 Dart. 모델 없이도 작동.
class CardFirstLauncher {
  final BuildContext _context;
  final List<_CardStep> _steps = [];
  int _current = 0;
  bool _done = false;

  CardFirstLauncher(this._context);

  Future<bool> run() async {
    _steps.addAll([
      _CardStep('OraclePrompter에 오신 것을 환영합니다.',
          back: '지금 바로 시작하실 수 있어요. 아무 설정도 필요 없습니다.\n일주일만 같이 지내면 완벽해져요.',
          pos: '시작', neg: '나중에', type: CardType.preference),
      _CardStep('마이크 권한이 필요해요.',
          back: '음성으로 명령하고 대화할 수 있게 해드릴게요.',
          pos: '허용', neg: '나중에', type: CardType.preference),
    ]);

    return _showNext();
  }

  Future<bool> _showNext() async {
    if (_current >= _steps.length) {
      _done = true;
      // Start services even without model
      await SessionService.start();
      return true;
    }

    final step = _steps[_current];
    final completer = Completer<bool>();

    showCard(_context,
      type: step.type,
      statement: step.statement,
      backAnswer: step.back,
      pos: step.pos, neg: step.neg,
      onResult: (confidence) {
        _current++;
        completer.complete(true);
      },
    );

    await completer.future;
    return _showNext(); // Recursively show next card
  }
}

class _CardStep {
  final String statement, back, pos, neg;
  final CardType type;
  const _CardStep(this.statement, {required this.back,
      this.pos = '네', this.neg = '아니오', this.type = CardType.preference});
}

/// Check if basic functions are available (model not needed)
class BasicMode {
  static const available = [
    '🃏 Card conversations',
    '⚙️ Settings changes',
    '📖 View journal (if saved)',
    '⏰ Timers & reminders',
    '🔧 Geek Mode settings',
    '📱 App usage (if permission granted)',
  ];

  static const unavailable = [
    '🧠 Real-time conversation analysis',
    '🎧 Whisper coaching during calls',
    '💬 Oracle AI chat',
    '👁️ Sight mode (Vision AI)',
    '📊 MindGraph prediction',
  ];

  static bool get canOperate => true; // Always true. Cards don't need models.
}
