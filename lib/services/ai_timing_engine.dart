import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/conversation_card.dart';

/// 🧠 AI Timing Engine — decides WHEN to ask, not just how often
///
/// Rules (ordered by priority):
/// 1. NEVER during active call or conversation
/// 2. NEVER when user shows stress signals (fast speech, negative words)
/// 3. NEVER within 2 minutes of the last card
/// 4. IDEAL: right after a coaching event that was well-received
/// 5. IDEAL: at natural conversation pause (silence > 5 seconds)
/// 6. FALLBACK: every N coaching events, weighted by context
class AITimingEngine {
  static final AITimingEngine _i = AITimingEngine._();
  factory AITimingEngine() => _i;
  AITimingEngine._();

  DateTime _lastCard = DateTime.now();
  DateTime _lastSpeech = DateTime.now();
  int _coachingSinceAsk = 0;
  bool _inConversation = false;
  double _stressLevel = 0.0; // 0.0 = calm, 1.0 = stressed
  double _batteryLevel = 1.0;
  int _hour = 12;

  // ─── Signals ───────────────────────────────────

  /// Call/meeting started — block all cards
  void onConversationStart() => _inConversation = true;

  /// Call ended — good time to ask
  void onConversationEnd() {
    _inConversation = false;
    // Natural pause after call = good timing
    _coachingSinceAsk = 99; // Force-eligible
  }

  /// User spoke (from STT)
  void onSpeech({double speed = 1.0, String? sentiment}) {
    _lastSpeech = DateTime.now();
    // Fast speech + negative words = stress
    if (speed > 1.5 && (sentiment?.contains('부정') ?? false)) {
      _stressLevel = (_stressLevel + 0.3).clamp(0.0, 1.0);
    } else {
      _stressLevel = (_stressLevel * 0.9).clamp(0.0, 1.0); // Decay
    }
  }

  /// Silence detected (from VAD)
  void onSilence(Duration duration) {
    // Long silence = natural pause = good timing
    if (duration.inSeconds > 5) {
      _coachingSinceAsk = 99; // Boost
    }
  }

  /// Coaching was delivered
  void onCoachingDelivered() => _coachingSinceAsk++;

  /// Coaching was well-received (user acted on it)
  void onCoachingAccepted() {
    _coachingSinceAsk += 5; // Extra boost — ask sooner after good coaching
  }

  /// Battery update
  void onBattery(double level) => _batteryLevel = level;

  /// Current hour (0-23)
  void onHour(int h) => _hour = h;

  // ─── Decision ──────────────────────────────────

  /// Should we show a card RIGHT NOW?
  bool shouldAsk() {
    // RULE 1: Never during conversation
    if (_inConversation) return false;

    // RULE 2: Never when stressed
    if (_stressLevel > 0.6) return false;

    // RULE 3: Minimum interval (2 minutes)
    if (DateTime.now().difference(_lastCard).inMinutes < 2) return false;

    // RULE 4: Don't ask at night (2am–7am)
    if (_hour >= 2 && _hour < 7) return false;

    // RULE 5: Don't ask when battery is critical
    if (_batteryLevel < 0.1) return false;

    // RULE 6: Ask after enough coaching events (base threshold)
    final threshold = _calcThreshold();
    if (_coachingSinceAsk < threshold) return false;

    return true;
  }

  /// Calculate dynamic threshold based on context
  int _calcThreshold() {
    int base = 5; // Base: ask every 5 coaching events

    // Adjust for stress: stressed users get asked less
    if (_stressLevel > 0.3) base += 3;

    // Adjust for battery: low battery = ask less
    if (_batteryLevel < 0.3) base += 2;

    // Adjust for time of day: morning = more receptive
    if (_hour >= 8 && _hour < 12) base -= 1;

    // Adjust for silence: after long silence = ask sooner (handled by boost)

    return base.clamp(2, 15);
  }

  /// Mark card as shown
  void onCardShown() {
    _lastCard = DateTime.now();
    _coachingSinceAsk = 0;
  }

  /// Get a human-readable reason (for debugging)
  String get blockReason {
    if (_inConversation) return '통화 중';
    if (_stressLevel > 0.6) return '스트레스 감지됨';
    if (DateTime.now().difference(_lastCard).inMinutes < 2) return '방금 물어봄';
    if (_hour >= 2 && _hour < 7) return '야간';
    if (_batteryLevel < 0.1) return '배터리 부족';
    if (_coachingSinceAsk < _calcThreshold()) return '아직 ${_calcThreshold() - _coachingSinceAsk}회 남음';
    return '질문 가능';
  }
}
