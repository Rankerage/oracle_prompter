import 'dart:io';
import 'package:flutter/material.dart';

/// 📱 기기 사양 체크 결과
class DeviceSpec {
  final int ramMB;
  final int storageGB;
  final int androidVersion;
  final bool hasBluetooth;
  final bool hasCamera;
  final bool hasMicrophone;
  final bool hasGPS;
  final bool is64Bit;

  const DeviceSpec({
    required this.ramMB,
    required this.storageGB,
    required this.androidVersion,
    required this.hasBluetooth,
    required this.hasCamera,
    required this.hasMicrophone,
    required this.hasGPS,
    required this.is64Bit,
  });

  /// OraclePrompter 최소 사양
  static const minimum = DeviceSpec(
    ramMB: 4096,
    storageGB: 16,
    androidVersion: 10,
    hasBluetooth: true,
    hasCamera: false, // 선택
    hasMicrophone: true,
    hasGPS: false, // 선택
    is64Bit: true,
  );

  /// 권장 사양
  static const recommended = DeviceSpec(
    ramMB: 8192,
    storageGB: 32,
    androidVersion: 13,
    hasBluetooth: true,
    hasCamera: true,
    hasMicrophone: true,
    hasGPS: true,
    is64Bit: true,
  );

  bool get meetsMinimum => ramMB >= minimum.ramMB
      && androidVersion >= minimum.androidVersion
      && hasMicrophone
      && is64Bit;

  bool get meetsRecommended => meetsMinimum
      && ramMB >= recommended.ramMB
      && androidVersion >= recommended.androidVersion
      && hasCamera
      && hasBluetooth;

  String get tier {
    if (meetsRecommended) return '🚀 성능 — 전체 기능';
    if (meetsMinimum) return '⚡ 일반 — 핵심 기능';
    return '⚠️ 최소 미달 — 제한적 사용';
  }

  /// 실제 기기 정보 수집 (MethodChannel 호출)
  static Future<DeviceSpec> fromDevice() async {
    // TODO: MethodChannel → Android Build, ActivityManager, PackageManager
    // val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
    // val memInfo = ActivityManager.MemoryInfo()
    // activityManager.getMemoryInfo(memInfo)
    // val totalRam = memInfo.totalMem / (1024 * 1024)

    return DeviceSpec(
      ramMB: Platform.isAndroid ? 6144 : 4096, // 데모값
      storageGB: 32,
      androidVersion: 13,
      hasBluetooth: true,
      hasCamera: true,
      hasMicrophone: true,
      hasGPS: true,
      is64Bit: true,
    );
  }
}

/// 🔧 하드웨어 설정 항목
class HardwareSetting {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final SettingType type;
  bool isReady;

  HardwareSetting({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    this.isReady = false,
  });
}

enum SettingType {
  permission,  // OS 권한
  toggle,      // ON/OFF 설정
  action,      // 사용자 액션 필요 (예: 블루투스 페어링)
  info,        // 정보 표시만
}

/// 🔧 하드웨어 설정 마법사 상태
class HardwareWizard extends ChangeNotifier {
  final List<HardwareSetting> _settings = [];
  int _completedCount = 0;

  List<HardwareSetting> get settings => List.unmodifiable(_settings);
  int get completedCount => _completedCount;
  int get totalCount => _settings.length;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0;
  bool get allDone => completedCount >= totalCount;

  HardwareWizard() {
    _initSettings();
  }

  void _initSettings() {
    _settings.addAll([
      HardwareSetting(id: 'mic', name: '마이크', description: '대화 인식 필수', icon: Icons.mic, type: SettingType.permission),
      HardwareSetting(id: 'bluetooth', name: '블루투스', description: '이어폰 귓속말', icon: Icons.headphones, type: SettingType.toggle),
      HardwareSetting(id: 'battery', name: '배터리 최적화 해제', description: '백그라운드 세션 유지', icon: Icons.battery_charging_full, type: SettingType.action),
      HardwareSetting(id: 'notifications', name: '알림', description: '세션 상태 표시', icon: Icons.notifications, type: SettingType.permission),
      HardwareSetting(id: 'camera', name: '카메라', description: '시선 모드용 (선택)', icon: Icons.camera_alt, type: SettingType.permission),
      HardwareSetting(id: 'location', name: '위치', description: '일기장 위치로그 (선택)', icon: Icons.location_on, type: SettingType.permission),
      HardwareSetting(id: 'storage', name: '저장소', description: 'Vault 마크다운 저장', icon: Icons.folder, type: SettingType.permission),
      HardwareSetting(id: 'overlay', name: '화면 위 표시', description: 'MediaProjection용', icon: Icons.layers, type: SettingType.action),
    ]);
  }

  void markReady(String id) {
    final setting = _settings.firstWhere((s) => s.id == id);
    if (!setting.isReady) {
      setting.isReady = true;
      _completedCount++;
      notifyListeners();
    }
  }

  void unmarkReady(String id) {
    final setting = _settings.firstWhere((s) => s.id == id);
    if (setting.isReady) {
      setting.isReady = false;
      _completedCount--;
      notifyListeners();
    }
  }
}
