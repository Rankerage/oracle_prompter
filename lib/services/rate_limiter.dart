import 'dart:async';

/// 🛡️ Hard Rate Limiter — prevents runaway LLM calls
///
/// Last line of defense. No logic can bypass this.
class RateLimiter {
  static final RateLimiter _i = RateLimiter._();
  factory RateLimiter() => _i;
  RateLimiter._();

  int _totalCalls = 0;
  int _callsThisMinute = 0;
  int _callsThisHour = 0;
  DateTime _minuteStart = DateTime.now();
  DateTime _hourStart = DateTime.now();
  bool _paused = false;
  String _pauseReason = '';
  Timer? _resetTimer;

  // ─── Limits ────────────────────────────────────

  static const maxPerMinute = 10;   // Never more than 10 LLM calls/minute
  static const maxPerHour = 100;    // Never more than 100 LLM calls/hour
  static const maxConsecutiveErrors = 5; // After 5 errors in a row, pause

  int _consecutiveErrors = 0;

  /// Returns true if call is allowed. False = blocked.
  bool canCall({String reason = ''}) {
    final now = DateTime.now();

    // Reset counters if minute/hour rolled over
    if (now.difference(_minuteStart).inSeconds >= 60) {
      _minuteStart = now;
      _callsThisMinute = 0;
    }
    if (now.difference(_hourStart).inMinutes >= 60) {
      _hourStart = now;
      _callsThisHour = 0;
    }

    if (_paused) return false;
    if (_callsThisMinute >= maxPerMinute) return false;
    if (_callsThisHour >= maxPerHour) return false;

    _totalCalls++;
    _callsThisMinute++;
    _callsThisHour++;
    return true;
  }

  /// Called when LLM returns error
  void onError() {
    _consecutiveErrors++;
    if (_consecutiveErrors >= maxConsecutiveErrors) {
      _pause('연속 오류 ${maxConsecutiveErrors}회. 5분간 일시중지.');
      Timer(const Duration(minutes: 5), () {
        _resume();
      });
    }
  }

  /// Called when LLM succeeds
  void onSuccess() {
    _consecutiveErrors = 0;
  }

  void _pause(String reason) {
    _paused = true;
    _pauseReason = reason;
  }

  void _resume() {
    _paused = false;
    _pauseReason = '';
    _consecutiveErrors = 0;
  }

  // ─── Stats ─────────────────────────────────────

  String get status => _paused
      ? '⏸️ $_pauseReason'
      : '🟢 ${_callsThisMinute}/$maxPerMinute (min) ${_callsThisHour}/$maxPerHour (hr)';

  int get totalCalls => _totalCalls;

  /// Emergency kill switch — user holds volume down for 5 seconds
  void emergencyStop() {
    _pause('비상 정지. 앱을 재시작할 때까지 모든 API 호출 차단.');
  }

  void emergencyResume() => _resume();
}
