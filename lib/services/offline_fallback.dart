import '../widgets/conversation_card.dart';
import 'package:flutter/material.dart';

/// 🛡️ Offline Fallback + Error Recovery
///
/// LLM 연결 실패해도 앱이 죽지 않는다.
/// 오프라인에서도 기본 기능 작동.
class OfflineFallback {
  static final OfflineFallback _i = OfflineFallback._();
  factory OfflineFallback() => _i;
  OfflineFallback._();

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  set isOnline(bool v) => _isOnline = v;

  // ─── Built-in cards (no LLM needed) ──────────

  static const _builtInCards = [
    ('영어 단어 공부를 시작해볼까요?', '자주 쓰는 단어부터 알려드릴게요.'),
    ('오늘 하루 어떠셨어요?', '잠시 돌아보는 것도 좋은 습관이에요.'),
    ('새로운 IT 소식이 있어요.', 'AI 분야에서 재미있는 발전이 있었어요.'),
    ('잠깐 스트레칭 하실래요?', '목과 어깨를 10초만 풀어보세요.'),
    ('오늘 배운 것 중에 기억나는 게 있나요?', '복습은 망각을 막는 가장 좋은 방법이에요.'),
  ];

  String get randomCard {
    return _builtInCards[_builtInCards.hashCode.abs() % _builtInCards.length].$1;
  }

  // ─── Error recovery card ─────────────────────

  static void showConnectionLost(BuildContext ctx) {
    showCard(ctx, type: CardType.reminder,
      statement: '인터넷 연결을 확인할 수 없어요.',
      backAnswer: '걱정 마세요. 기본 기능은 계속 사용할 수 있어요.\n'
          '인터넷이 연결되면 더 풍부한 대화가 가능해져요.',
      pos: '○', neg: '✕');
  }

  // ─── Permission denied ───────────────────────

  static void showMicDenied(BuildContext ctx) {
    showCard(ctx, type: CardType.reminder,
      statement: '마이크 허용이 필요해요.',
      backAnswer: '설정 → 앱 → TikiTaka → 권한 → 마이크 허용\n\n'
          '마이크가 없어도 카드 대화는 가능해요.',
      pos: '설정 열기', neg: '나중에');
  }

  // ─── LLM error — graceful degradation ────────

  static void showLLMError(BuildContext ctx, String error) {
    showCard(ctx, type: CardType.reminder,
      statement: '잠시 연결이 원활하지 않아요.',
      backAnswer: '곧 복구될 거예요. 그동안 기본 카드로 대화를 이어갈게요.',
      pos: '○', neg: '✕');
    _i._isOnline = false;
  }

  /// Wrapper: try LLM call, fall back to built-in
  static Future<String> tryLLM(Future<String> Function() call) async {
    try {
      final result = await call();
      _i._isOnline = true;
      return result;
    } catch (_) {
      _i._isOnline = false;
      return _builtInCards[_builtInCards.hashCode.abs() % _builtInCards.length].$1;
    }
  }
}
