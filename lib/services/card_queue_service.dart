import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/conversation_card.dart';
import 'card_generator.dart';

/// 🃏 Card Queue with confidence-weighted Leitner
class CardQueueService {
  static final CardQueueService _i = CardQueueService._();
  factory CardQueueService() => _i;
  CardQueueService._();

  final List<_QCard> _queue = [];
  final Map<String, _Leitner> _leitner = {};
  Timer? _timer;
  DateTime _lastShown = DateTime.now();
  bool _showing = false;
  bool _inCall = false;
  BuildContext? _ctx;
  static const minInterval = 60;

  void start(BuildContext ctx) {
    _ctx = ctx;
    _load();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 40), (_) {
      if (!_showing && !_inCall) _eval();
    });
    _seed();
  }

  void stop() => _timer?.cancel();
  void onCallStart() => _inCall = true;
  void onCallEnd() => _inCall = false;

  // ─── Seed with generated cards ─────────────────

  void _seed() {
    // Add 3 generated cards to queue
    for (int i = 0; i < 3; i++) {
      final c = CardContentGenerator.nextCard();
      final ls = _leitner[c.statement] ?? _Leitner();
      if (ls.shouldShow) {
        _queue.add(_QCard(statement: c.statement, backAnswer: c.backAnswer,
            type: c.type, pos: c.positiveLabel, neg: c.negativeLabel));
      }
    }
  }

  // ─── External triggers ─────────────────────────

  void showApiBalanceLow() => _show(CardType.preference,
      'API 잔액이 부족해요. 무료 온디바이스로 전환할까요?',
      '온디바이스 AI는 인터넷 없이 작동해요.', '전환', '충전');

  void showMoodCheck() => _show(CardType.checkup,
      '지금 기분이 괜찮으세요?', '항상 응원하고 있어요.', '좋다', '아니다');

  void _show(CardType type, String stmt, String back, String pos, String neg) {
    final ctx = _ctx; if (ctx == null || _showing || _inCall) return;
    _showing = true;
    showCard(ctx, type: type, statement: stmt, backAnswer: back,
        pos: pos, neg: neg, onResult: (c) {
          _record(stmt, c);
          _showing = false;
        });
  }

  // ─── Evaluation ────────────────────────────────

  void _eval() {
    final ctx = _ctx; if (ctx == null) return;
    if (DateTime.now().difference(_lastShown).inSeconds < minInterval) return;

    // Refill queue if empty
    if (_queue.isEmpty) _seed();
    if (_queue.isEmpty) return;

    final card = _queue.removeAt(0);
    _showing = true;
    _lastShown = DateTime.now();

    showCard(ctx, type: card.type, statement: card.statement,
        backAnswer: card.backAnswer, pos: card.pos, neg: card.neg,
        onResult: (confidence) {
          _record(card.statement, confidence);
          _showing = false;
        });
  }

  // ─── Confidence-weighted Leitner ───────────────

  void _record(String statement, int confidence) {
    final ls = _leitner.putIfAbsent(statement, () => _Leitner());
    ls.record(confidence); // +2 strong yes, +1 learned, -1 unsure, -2 strong no
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in _leitner.entries) {
      prefs.setInt('c_${e.key.hashCode}_b', e.value.box);
      prefs.setInt('c_${e.key.hashCode}_n', e.value.timesShown);
    }
  }

  Future<void> _load() async { /* load from SharedPreferences */ }
}

class _QCard {
  final String statement, backAnswer, pos, neg;
  final CardType type;
  const _QCard({required this.statement, required this.backAnswer,
      required this.type, required this.pos, required this.neg});
}

class _Leitner {
  int box = 1;
  int timesShown = 0;
  bool get shouldShow => box < 5;

  /// confidence: +2 strong yes, +1 learned, -1 unsure, -2 strong no
  void record(int confidence) {
    timesShown++;
    if (confidence >= 2) box = (box + 2).clamp(1, 5);   // Fast promote
    else if (confidence >= 1) box = (box + 1).clamp(1, 5);
    else if (confidence <= -2) box = (box - 1).clamp(1, 5); // Demote
    else box = box.clamp(1, 5); // unsure, stay
  }
}
