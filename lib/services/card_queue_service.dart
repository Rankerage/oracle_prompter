import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/conversation_card.dart';

/// 🃏 Leitner-based conversation card scheduler
///
/// Cards appear at optimal moments based on:
/// - User's response history (Leitner spacing)
/// - App lifecycle (not during calls, not too frequent)
/// - Context (API balance low, model change, new feature)
class CardQueueService {
  static final CardQueueService _instance = CardQueueService._();
  factory CardQueueService() => _instance;
  CardQueueService._();

  final List<_QueuedCard> _queue = [];
  final Map<String, _LeitnerState> _leitner = {};
  Timer? _timer;
  DateTime _lastShown = DateTime.now();
  bool _isShowing = false;
  bool _isCallActive = false;

  /// Minimum interval between cards (seconds)
  static const minInterval = 120;

  /// Start background card evaluation
  void start(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!_isShowing && !_isCallActive) {
        _evaluate(context);
      }
    });
    // Initial cards for new users
    _enqueueInitialCards();
  }

  void stop() => _timer?.cancel();

  void onCallStarted() => _isCallActive = true;
  void onCallEnded() => _isCallActive = false;

  // ─── Card Enqueue ──────────────────────────────

  void _enqueueInitialCards() {
    _enqueue('voice_preference', '이 목소리, 듣기 편하실 거예요.',
        positive: '좋다', negative: '싫다', priority: 10);
    _enqueue('mic_permission', '대화 내용을 기억하려면 마이크 권한이 필요해요.',
        positive: '허용', negative: '나중에', priority: 9);
    _enqueue('ai_default', '인터넷 없이도 작동하는 온디바이스 AI를 사용하고 있어요.',
        positive: '알겠다', negative: 'API 연결', priority: 8);
  }

  void _enqueue(String id, String statement, {
    String positive = '예', String negative = '아니오',
    int priority = 5, Color? accentColor,
  }) {
    // Don't re-enqueue if already in queue or recently shown
    if (_queue.any((c) => c.id == id)) return;
    final ls = _leitner[id];
    if (ls != null && !ls.shouldShow()) return;

    _queue.add(_QueuedCard(
      id: id, statement: statement,
      positiveLabel: positive, negativeLabel: negative,
      priority: priority, accentColor: accentColor,
    ));
    _queue.sort((a, b) => b.priority.compareTo(a.priority));
  }

  // ─── Evaluation ─────────────────────────────────

  void _evaluate(BuildContext context) {
    final now = DateTime.now();
    if (now.difference(_lastShown).inSeconds < minInterval) return;
    if (_queue.isEmpty) return;

    final card = _queue.removeAt(0);
    _isShowing = true;
    _lastShown = now;

    showConversationCard(
      context,
      statement: card.statement,
      positiveLabel: card.positiveLabel,
      negativeLabel: card.negativeLabel,
      accentColor: card.accentColor,
      onChoice: (accepted) {
        _recordResponse(card.id, accepted);
        _isShowing = false;
      },
    );
  }

  // ─── Leitner Spacing ────────────────────────────

  void _recordResponse(String id, bool accepted) {
    final ls = _leitner.putIfAbsent(id, () => _LeitnerState());
    ls.record(accepted);
    _saveLeitner();
  }

  /// Context-triggered card (API balance low, model changed, etc.)
  void showContextCard(BuildContext context, String id, String statement, {
    String positive = '예', String negative = '아니오',
    Color? accentColor,
  }) {
    if (_isShowing || _isCallActive) {
      _enqueue(id, statement, positive: positive, negative: negative,
          accentColor: accentColor, priority: 10);
      return;
    }

    _isShowing = true;
    showConversationCard(
      context,
      statement: statement,
      positiveLabel: positive,
      negativeLabel: negative,
      accentColor: accentColor,
      onChoice: (accepted) {
        _recordResponse(id, accepted);
        _isShowing = false;
      },
    );
  }

  Future<void> _saveLeitner() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _leitner.entries) {
      prefs.setInt('leitner_${entry.key}_box', entry.value.box);
      prefs.setInt('leitner_${entry.key}_shown', entry.value.timesShown);
      prefs.setString('leitner_${entry.key}_last', entry.value.lastShown?.toIso8601String() ?? '');
    }
  }

  Future<void> loadLeitner() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith('leitner_'))) {
      final parts = key.split('_');
      if (parts.length < 3) continue;
      final id = parts.sublist(1, parts.length - 1).join('_');
      final field = parts.last;
      // Load state (simplified)
    }
  }

  bool get hasCardsQueued => _queue.isNotEmpty;
}

// ─── Internal Models ──────────────────────────────

class _QueuedCard {
  final String id;
  final String statement;
  final String positiveLabel;
  final String negativeLabel;
  final int priority;
  final Color? accentColor;

  const _QueuedCard({
    required this.id, required this.statement,
    required this.positiveLabel, required this.negativeLabel,
    required this.priority, this.accentColor,
  });
}

/// Leitner spaced repetition state
///
/// Box 1: every time (new)
/// Box 2: every 3rd time
/// Box 3: every 5th time
/// Box 4: every 10th time
/// Box 5: never again (learned)
class _LeitnerState {
  int box = 1;
  int timesShown = 0;
  DateTime? lastShown;

  void record(bool accepted) {
    timesShown++;
    lastShown = DateTime.now();
    if (accepted) {
      box = min(5, box + 1); // Promote
    } else {
      box = max(1, box - 1); // Demote
    }
  }

  bool shouldShow() {
    if (box >= 5) return false; // Learned, don't ask again
    final intervals = [1, 3, 5, 10, 999];
    return timesShown == 0 || (timesShown % intervals[box - 1] == 0);
  }
}
