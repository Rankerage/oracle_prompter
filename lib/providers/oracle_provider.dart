import 'package:flutter/material.dart';
import '../models/oracle_mode.dart';

/// OraclePrompter 핵심 상태 관리
class OracleProvider extends ChangeNotifier {
  // --- 현재 상태 ---
  bool _isActive = false;
  OracleMode _currentMode = OracleMode.defense;
  List<AudioEffect> _activeEffects = [];
  int _hotkeyLevel = 0; // 0=off, 1=mild, 2=emergency

  // --- AI 코치 ---
  String? _lastCoachingTip;
  bool _isCoaching = false;

  // --- 설정 ---
  double _masterVolume = 0.8;
  bool _earpieceOnly = true;
  String _coachVoice = 'whisper';

  // --- 프리셋 ---
  final List<Preset> _presets = [];
  final Map<String, Preset> _hotkeyPresets = {};

  // Getters
  bool get isActive => _isActive;
  OracleMode get currentMode => _currentMode;
  List<AudioEffect> get activeEffects => List.unmodifiable(_activeEffects);
  int get hotkeyLevel => _hotkeyLevel;
  String? get lastCoachingTip => _lastCoachingTip;
  bool get isCoaching => _isCoaching;
  double get masterVolume => _masterVolume;
  bool get earpieceOnly => _earpieceOnly;
  String get coachVoice => _coachVoice;
  List<Preset> get presets => List.unmodifiable(_presets);
  Map<String, Preset> get hotkeyPresets => Map.unmodifiable(_hotkeyPresets);

  // --- 액션 ---

  /// 전체 시스템 ON/OFF
  void toggleActive() {
    _isActive = !_isActive;
    if (!_isActive) {
      _hotkeyLevel = 0;
      _activeEffects = [];
    }
    notifyListeners();
  }

  /// 모드 변경
  void setMode(OracleMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  /// 핫키 레벨 설정 (볼륨 버튼 2회 = level 1, 3초 길게 = level 2)
  void setHotkeyLevel(int level) {
    _hotkeyLevel = level;
    _isActive = level > 0;
    notifyListeners();
  }

  /// 긴급 탈출 (레벨 2)
  void emergencyEscape() {
    _hotkeyLevel = 2;
    _isActive = true;
    _activeEffects = [
      AudioEffect.howlingEcho,
      AudioEffect.whiteNoise,
      AudioEffect.downsampling,
    ];
    notifyListeners();
  }

  /// 원상 복구
  void restoreNormal() {
    _hotkeyLevel = 0;
    _isActive = false;
    _activeEffects = [];
    notifyListeners();
  }

  /// 이펙트 토글
  void toggleEffect(AudioEffect effect) {
    if (_activeEffects.contains(effect)) {
      _activeEffects.remove(effect);
    } else {
      _activeEffects.add(effect);
    }
    notifyListeners();
  }

  /// 코칭 팁 수신
  void receiveCoachingTip(String tip) {
    _lastCoachingTip = tip;
    _isCoaching = true;
    notifyListeners();
  }

  void clearCoachingTip() {
    _isCoaching = false;
    notifyListeners();
  }

  /// 볼륨 조절
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 이어폰 전용 모드
  void toggleEarpieceOnly() {
    _earpieceOnly = !_earpieceOnly;
    notifyListeners();
  }

  /// 프리셋 저장
  void savePreset(Preset preset) {
    _presets.add(preset);
    notifyListeners();
  }

  /// 핫키 프리셋 설정 (예: "vol_down_2" → Preset)
  void setHotkeyPreset(String hotkey, Preset preset) {
    _hotkeyPresets[hotkey] = preset;
    notifyListeners();
  }
}
