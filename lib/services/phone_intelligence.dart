import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 📱 폰 화면 캡처 서비스 (MediaProjection API)
///
/// Android 5.0+ MediaProjection을 통해
/// 폰 자체 화면을 캡처하여 Vision AI로 분석.
/// 카메라 없이도 "사용자가 보고 있는 앱"을 AI가 인식.
class ScreenCaptureService {
  bool _isCapturing = false;
  Timer? _captureTimer;
  StreamController<Uint8List>? _frameController;

  Stream<Uint8List>? get frameStream => _frameController?.stream;
  bool get isCapturing => _isCapturing;

  /// 화면 캡처 시작 (MediaProjection 권한 필요)
  Future<bool> startCapture({
    required void Function(Uint8List frame) onFrame,
    int intervalMs = 4000,
  }) async {
    // 1. 사용자에게 MediaProjection 권한 요청
    //    → Android OS 다이얼로그: "화면 캡처를 허용하시겠습니까?"
    //    → flutter_screen_recording 또는 media_projection 패키지 사용

    // 2. 권한 획득 후 주기적 캡처 시작
    _isCapturing = true;
    _captureTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) async {
      if (!_isCapturing) return;

      try {
        // MediaProjection → VirtualDisplay → ImageReader → JPEG bytes
        final frame = await _grabScreenFrame();
        if (frame != null) {
          onFrame(frame);
        }
      } catch (e) {
        debugPrint('Screen capture error: $e');
      }
    });

    return true;
  }

  /// 실제 화면 프레임 캡처 (Platform Channel 호출)
  Future<Uint8List?> _grabScreenFrame() async {
    // TODO: MethodChannel → Android MediaProjection
    // Android 네이티브 코드:
    //   val mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data)
    //   val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
    //   val virtualDisplay = mediaProjection.createVirtualDisplay(
    //     "O.P Screen Capture", width, height, dpi,
    //     DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
    //     imageReader.surface, null, null)
    //   val image = imageReader.acquireLatestImage()
    //   val bitmap = imageToBitmap(image)
    //   val stream = ByteArrayOutputStream()
    //   bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream)
    //   return stream.toByteArray()

    // 현재는 Flatform Channel 스텁
    return null;
  }

  void stopCapture() {
    _isCapturing = false;
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  void dispose() {
    stopCapture();
    _frameController?.close();
  }
}

/// 📊 앱 사용 패턴 추적 서비스 (UsageStatsManager)
///
/// Android 5.0+ UsageStatsManager API를 통해
/// 사용자가 어떤 앱을 얼마나 사용하는지 추적.
class AppUsageTracker {
  List<AppUsageRecord> _usageRecords = [];
  bool _hasPermission = false;

  List<AppUsageRecord> get usageRecords => List.unmodifiable(_usageRecords);
  bool get hasPermission => _hasPermission;

  /// 사용 통계 권한 요청
  Future<bool> requestPermission() async {
    // Android: Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
    // → 사용자가 설정에서 O.P의 Usage Access를 허용해야 함
    // TODO: MethodChannel → UsageStatsManager
    _hasPermission = true;
    return true;
  }

  /// 오늘의 앱 사용 패턴 조회
  Future<List<AppUsageRecord>> getTodayUsage() async {
    // Android:
    //   val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    //   val now = System.currentTimeMillis()
    //   val stats = usageStatsManager.queryUsageStats(
    //     UsageStatsManager.INTERVAL_DAILY,
    //     now - 24 * 60 * 60 * 1000, now)
    //   stats.forEach { stat ->
    //     records.add(AppUsageRecord(
    //       packageName = stat.packageName,
    //       appName = resolveAppName(stat.packageName),
    //       timeInForeground = stat.totalTimeInForeground,
    //       lastUsed = stat.lastTimeUsed,
    //     ))
    //   }

    // 데모 데이터
    _usageRecords = [
      AppUsageRecord('com.kakao.talk', '카카오톡', const Duration(hours: 2, minutes: 15), DateTime.now().subtract(const Duration(minutes: 5))),
      AppUsageRecord('com.google.android.youtube', 'YouTube', const Duration(hours: 1, minutes: 45), DateTime.now().subtract(const Duration(minutes: 30))),
      AppUsageRecord('com.twitter.android', 'X (Twitter)', const Duration(minutes: 55), DateTime.now().subtract(const Duration(hours: 1))),
      AppUsageRecord('com.android.chrome', 'Chrome', const Duration(minutes: 40), DateTime.now().subtract(const Duration(minutes: 15))),
      AppUsageRecord('com.oracleprompter.oracle_prompter', 'OraclePrompter', const Duration(minutes: 20), DateTime.now()),
    ];

    return _usageRecords;
  }

  /// 앱 사용 패턴 → 마크다운 보고서 생성
  String generateReport() {
    final sorted = List<AppUsageRecord>.from(_usageRecords)
      ..sort((a, b) => b.timeInForeground.compareTo(a.timeInForeground));

    final buffer = StringBuffer();
    buffer.writeln('# 오늘의 앱 사용 리포트');
    buffer.writeln();
    buffer.writeln('> 생성: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('## 사용 시간 TOP 5');
    buffer.writeln();
    buffer.writeln('| 앱 | 시간 | 마지막 사용 |');
    buffer.writeln('|---|---|---|');
    for (final record in sorted.take(5)) {
      buffer.writeln('| ${record.appName} | ${_formatDuration(record.timeInForeground)} | ${_formatTime(record.lastUsed)} |');
    }
    buffer.writeln();
    buffer.writeln('## 패턴 분석');
    buffer.writeln();

    final total = sorted.fold<Duration>(Duration.zero, (sum, r) => sum + r.timeInForeground);
    buffer.writeln('- 총 사용 시간: ${_formatDuration(total)}');
    buffer.writeln('- 사용 앱 수: ${sorted.length}개');

    return buffer.toString();
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}시간 ${d.inMinutes % 60}분';
    return '${d.inMinutes}분';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// 앱 사용 기록
class AppUsageRecord {
  final String packageName;
  final String appName;
  final Duration timeInForeground;
  final DateTime lastUsed;

  const AppUsageRecord(this.packageName, this.appName, this.timeInForeground, this.lastUsed);
}
