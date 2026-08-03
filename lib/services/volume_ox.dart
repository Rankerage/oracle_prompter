import 'package:flutter/services.dart';

/// 📳 VolumeOX — 볼륨 버튼을 OX로 사용
///
/// 이어폰 낀 상태에서 화면 안 보고도 학습 가능.
/// Volume Up = ○ (taka), Volume Down = ✕ (tiki)
class VolumeOX {
  static final VolumeOX _i = VolumeOX._();
  factory VolumeOX() => _i;
  VolumeOX._();

  bool _enabled = false;
  void Function()? _onO;
  void Function()? _onX;

  /// Enable volume-as-OX mode
  void enable({required void Function() onO, required void Function() onX}) {
    _onO = onO; _onX = onX; _enabled = true;
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  void disable() {
    _enabled = false;
    HardwareKeyboard.instance.removeHandler(_handleKey);
  }

  bool _handleKey(KeyEvent event) {
    if (!_enabled) return false;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        _onO?.call();
        return true; // consume event
      }
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        _onX?.call();
        return true;
      }
    }
    return false;
  }

  bool get isEnabled => _enabled;

  void dispose() => disable();
}
