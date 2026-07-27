import 'dart:async';

/// ─── Hermes-style Tool 추상 클래스 ───
///
/// 모든 폰 센서/데이터 접근은 이 인터페이스를 통해 이루어짐.
/// Hermes의 `tool` 시스템을 O.P에 이식.

abstract class OPTool {
  /// 도구 이름 (예: "mic_in", "camera", "call_log")
  String get name;

  /// 도구 설명
  String get description;

  /// 필요한 Android 권한 목록
  List<String> get requiredPermissions;

  /// 도구 실행
  /// [params]: 도구별 파라미터
  /// 반환: 결과 데이터 맵
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params);

  /// 도구 사용 가능 여부 (권한, 센서 유무 등)
  Future<bool> isAvailable();
}

/// Tool 실행 컨텍스트
class ToolContext {
  final Map<String, OPTool> _tools = {};

  void register(OPTool tool) => _tools[tool.name] = tool;
  OPTool? get(String name) => _tools[name];
  List<OPTool> get all => _tools.values.toList();

  Future<Map<String, dynamic>> callTool(String name, Map<String, dynamic> params) async {
    final tool = _tools[name];
    if (tool == null) throw Exception('Tool not found: $name');
    return tool.execute(params);
  }
}

/// Tool 실행 결과 로그
class ToolCall {
  final String toolName;
  final Map<String, dynamic> params;
  final Map<String, dynamic>? result;
  final DateTime timestamp;
  final String? error;

  const ToolCall({
    required this.toolName,
    required this.params,
    this.result,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'tool': toolName,
        'params': params,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
      };
}

// ─── 구체 Tool 구현체 (스텁) ───

class MicTool extends OPTool {
  @override String get name => 'mic_in';
  @override String get description => '마이크 입력 → STT 변환';
  @override List<String> get requiredPermissions => ['RECORD_AUDIO'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    // sherpa-onnx STT 실행
    return {'text': '(STT 결과)', 'language': 'ko'};
  }

  @override Future<bool> isAvailable() async => true;
}

class TtsTool extends OPTool {
  @override String get name => 'tts_out';
  @override String get description => '텍스트 → 음성 귓속말 출력';
  @override List<String> get requiredPermissions => [];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    final text = params['text'] as String? ?? '';
    // Piper TTS 실행
    return {'spoken': true, 'text': text};
  }

  @override Future<bool> isAvailable() async => true;
}

class CameraTool extends OPTool {
  @override String get name => 'camera';
  @override String get description => '카메라 촬영 → Vision AI 분석';
  @override List<String> get requiredPermissions => ['CAMERA'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'frame': 'base64_jpeg', 'analysis': 'pending'};
  }

  @override Future<bool> isAvailable() async => true;
}

class ScreenCaptureTool extends OPTool {
  @override String get name => 'screen_capture';
  @override String get description => 'MediaProjection → 폰 화면 캡처';
  @override List<String> get requiredPermissions => ['SYSTEM_ALERT_WINDOW'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'frame': 'base64_jpeg', 'app': '현재 실행 중인 앱'};
  }

  @override Future<bool> isAvailable() async => true;
}

class LocationTool extends OPTool {
  @override String get name => 'location';
  @override String get description => 'GPS 위치 조회';
  @override List<String> get requiredPermissions => ['ACCESS_FINE_LOCATION'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'lat': 37.5665, 'lng': 126.9780, 'name': '서울'};
  }

  @override Future<bool> isAvailable() async => true;
}

class CallLogTool extends OPTool {
  @override String get name => 'call_log';
  @override String get description => '통화 기록 조회';
  @override List<String> get requiredPermissions => ['READ_CALL_LOG'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'calls': []};
  }

  @override Future<bool> isAvailable() async => true;
}

class SmsTool extends OPTool {
  @override String get name => 'sms';
  @override String get description => '문자 메시지 조회';
  @override List<String> get requiredPermissions => ['READ_SMS'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'messages': []};
  }

  @override Future<bool> isAvailable() async => true;
}

class CalendarTool extends OPTool {
  @override String get name => 'calendar';
  @override String get description => '캘린더 일정 조회';
  @override List<String> get requiredPermissions => ['READ_CALENDAR'];

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    return {'events': []};
  }

  @override Future<bool> isAvailable() async => true;
}
