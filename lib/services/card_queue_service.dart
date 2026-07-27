import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/conversation_card.dart';

/// 🃏 Universal Card Scheduler with Leitner spacing
///
/// Cards for: preference • reminder • learning • news • checkup
/// Leitner: box 1→2→3→4→5 with spaced intervals
class CardQueueService {
  static final CardQueueService _instance = CardQueueService._();
  factory CardQueueService() => _instance;
  CardQueueService._();

  final List<_Card> _queue = [];
  final Map<String, _Leitner> _leitner = {};
  Timer? _timer;
  DateTime _lastShown = DateTime.now();
  bool _isShowing = false;
  bool _isCallActive = false;
  static const minInterval = 90; // seconds between cards
  BuildContext? _ctx;

  void start(BuildContext context) {
    _ctx = context;
    _loadLeitner();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!_isShowing && !_isCallActive) _evaluate();
    });
    _enqueueDefaults();
  }

  void stop() => _timer?.cancel();
  void onCallStart() => _isCallActive = true;
  void onCallEnd() => _isCallActive = false;

  // ─── Default cards ────────────────────────────

  void _enqueueDefaults() {
    // Preference
    _enqueue('voice_pref', CardType.preference,
        '이 목소리, 듣기 편하실 거예요.',
        '좋다', '싫다',
        back: '다음에 다른 목소리로 바꿔드릴게요.');
    // Learning
    _enqueue('geek', CardType.learning,
        'Geek이 무슨 뜻인지 아세요?',
        '안다', '모른다',
        back: 'Geek은 특정 분야에 깊이 빠져드는 사람을 뜻해요. 우리 모두의 모습이죠.');
    // Preference
    _enqueue('response_speed', CardType.preference,
        '답변이 좀 더 빠르면 좋겠어요.',
        '좋다', '지금이 좋다',
        back: '알겠습니다. 응답 속도를 조절할게요.');
    // Reminder template
    _enqueue('morning', CardType.reminder,
        '오늘 중요한 일정이 있어요.',
        '알겠다', '무시',
        back: '잊지 않으셨다니 다행이에요.');
  }

  void _enqueue(String id, CardType type, String statement,
      String positive, String negative, {String back = '', int priority = 5}) {
    if (_queue.any((c) => c.id == id)) return;
    final ls = _leitner[id];
    if (ls != null && !ls.shouldShow) return;

    _queue.add(_Card(id: id, type: type, statement: statement,
        positiveLabel: positive, negativeLabel: negative,
        backAnswer: back, priority: priority));
    _queue.sort((a, b) => b.priority.compareTo(a.priority));
  }

  // ─── Evaluation ───────────────────────────────

  void _evaluate() {
    final ctx = _ctx;
    if (ctx == null) return;
    final now = DateTime.now();
    if (now.difference(_lastShown).inSeconds < minInterval) return;
    if (_queue.isEmpty) return;

    final card = _queue.removeAt(0);
    _isShowing = true;
    _lastShown = now;

    showCard(ctx,
      type: card.type,
      statement: card.statement,
      backAnswer: card.backAnswer,
      positive: card.positiveLabel,
      negative: card.negativeLabel,
      onChoice: (accepted, type) {
        _record(card.id, accepted);
        _isShowing = false;
      },
      onDismiss: () => _isShowing = false,
    );
  }

  // ─── Context-triggered cards ──────────────────

  /// API balance low
  void showApiBalanceLow() {
    final ctx = _ctx; if (ctx == null) return;
    if (_isShowing || _isCallActive) return;
    _isShowing = true;
    showCard(ctx,
      type: CardType.preference,
      statement: 'API 잔액이 부족해요. 무료 온디바이스 AI로 전환할까요?',
      backAnswer: '온디바이스 AI는 인터넷 없이도 작동해요.',
      positive: '전환', negative: '충전',
      onChoice: (accepted, type) { _isShowing = false; },
      onDismiss: () => _isShowing = false,
    );
  }

  /// New feature discovery
  void showFeature(String feature, String description) {
    final ctx = _ctx; if (ctx == null) return;
    if (_isShowing || _isCallActive) return;
    _isShowing = true;
    showCard(ctx,
      type: CardType.news,
      statement: feature,
      backAnswer: description,
      positive: '알겠다', negative: '나중에',
      onChoice: (_, __) => _isShowing = false,
      onDismiss: () => _isShowing = false,
    );
  }

  /// Mood checkup
  void showMoodCheck() {
    final ctx = _ctx; if (ctx == null) return;
    if (_isShowing || _isCallActive) return;
    _isShowing = true;
    showCard(ctx,
      type: CardType.checkup,
      statement: '지금 기분이 괜찮으세요?',
      backAnswer: '알겠습니다. 항상 응원하고 있어요.',
      positive: '좋다', negative: '아니다',
      onChoice: (accepted, type) {
        _isShowing = false;
        // Record mood for journal
      },
      onDismiss: () => _isShowing = false,
    );
  }

  // ─── Leitner ──────────────────────────────────

  void _record(String id, bool accepted) {
    final ls = _leitner.putIfAbsent(id, () => _Leitner());
    ls.record(accepted);
    _saveLeitner();
  }

  Future<void> _saveLeitner() async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in _leitner.entries) {
      prefs.setInt('l_${e.key}_box', e.value.box);
      prefs.setInt('l_${e.key}_n', e.value.timesShown);
    }
  }

  Future<void> _loadLeitner() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith('l_'))) {
      final parts = key.split('_');
      if (parts.length < 2) continue;
      final id = parts[1];
      final field = parts[2];
      final ls = _leitner.putIfAbsent(id, () => _Leitner());
      final val = prefs.getInt(key) ?? 0;
      if (field == 'box') ls.box = val;
      if (field == 'n') ls.timesShown = val;
    }
  }
}

// ─── Internal ────────────────────────────────────

class _Card {
  final String id;
  final CardType type;
  final String statement;
  final String positiveLabel;
  final String negativeLabel;
  final String backAnswer;
  final int priority;
  const _Card({required this.id, required this.type, required this.statement,
      required this.positiveLabel, required this.negativeLabel,
      required this.backAnswer, required this.priority});
}

class _Leitner {
  int box = 1;
  int timesShown = 0;
  bool get shouldShow => box < 5;
  void record(bool accepted) {
    timesShown++;
    box = accepted ? min(5, box + 1) : max(1, box - 1);
  }
}
