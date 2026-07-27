import 'package:flutter/material.dart';

/// 🔋 전원 모드
enum PowerMode {
  /// 절전 — 화면 OFF + 무음 5분. STT만 5초 버퍼, 그래프 30초
  saving('🌙 절전', '배터리 12h+'),

  /// 일반 — 기본 동작. 실시간 STT, 그래프 5초, Vision 15초
  normal('⚡ 일반', '배터리 6-8h'),

  /// 성능 — 충전 중. 전체 기능 최대 주기
  performance('🚀 성능', '배터리 2-4h');

  final String label;
  final String batteryHint;
  const PowerMode(this.label, this.batteryHint);
}

/// 🔋 전원 관리 Provider
class PowerManager extends ChangeNotifier {
  PowerMode _currentMode = PowerMode.normal;
  bool _isCharging = false;
  DateTime _lastUserInteraction = DateTime.now();
  bool _screenOn = true;

  // 설정
  bool _micWhenScreenOff = true;
  bool _wifiOnlyApi = false;
  int _visionIntervalMs = 15000; // 15초
  int _graphIntervalMs = 5000; // 5초
  bool _preferOnDevice = true;

  // Getters
  PowerMode get currentMode => _currentMode;
  bool get isCharging => _isCharging;
  bool get micWhenScreenOff => _micWhenScreenOff;
  bool get wifiOnlyApi => _wifiOnlyApi;
  int get visionIntervalMs => _visionIntervalMs;
  int get graphIntervalMs => _graphIntervalMs;
  bool get preferOnDevice => _preferOnDevice;

  /// 전원 모드 자동 평가
  void evaluate() {
    final now = DateTime.now();
    final idle = now.difference(_lastUserInteraction).inMinutes;

    if (_isCharging) {
      _setMode(PowerMode.performance);
    } else if (!_screenOn && idle >= 5) {
      _setMode(PowerMode.saving);
    } else {
      _setMode(PowerMode.normal);
    }
  }

  void _setMode(PowerMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  // 충전 상태 변경 (OS에서 알림)
  void onChargingChanged(bool charging) {
    _isCharging = charging;
    evaluate();
  }

  // 화면 ON/OFF
  void onScreenStateChanged(bool on) {
    _screenOn = on;
    if (!on) _lastUserInteraction = DateTime.now();
    evaluate();
  }

  // 사용자 상호작용 기록
  void onUserInteraction() {
    _lastUserInteraction = DateTime.now();
  }

  // 설정 변경
  void setMicWhenScreenOff(bool value) {
    _micWhenScreenOff = value;
    notifyListeners();
  }

  void setWifiOnlyApi(bool value) {
    _wifiOnlyApi = value;
    notifyListeners();
  }

  void setVisionInterval(int ms) {
    _visionIntervalMs = ms.clamp(4000, 60000);
    notifyListeners();
  }

  void setGraphInterval(int ms) {
    _graphIntervalMs = ms.clamp(2000, 30000);
    notifyListeners();
  }

  void setPreferOnDevice(bool value) {
    _preferOnDevice = value;
    notifyListeners();
  }
}
