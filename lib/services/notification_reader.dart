import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/conversation_card.dart';
import 'package:flutter/material.dart';

/// 🔔 Notification Reader — 타앱 알림을 카드로
///
/// NotificationListenerService 공식 API 사용.
/// Play Store 허용. 사용자가 수동으로 권한 부여.
class NotificationReader {
  static const _channel = MethodChannel('com.oracleprompter/notifications');
  static bool _enabled = false;
  static final List<_NotificationItem> _recent = [];

  static bool get isEnabled => _enabled;

  /// 권한 확인
  static Future<void> checkPermission() async {
    try {
      final result = await _channel.invokeMethod('isNotificationListenerEnabled');
      _enabled = result == true;
    } catch (_) {
      _enabled = false;
    }
  }

  /// 설정 화면으로 안내
  static Future<void> openSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }

  /// 새로운 알림 수신 (네이티브에서 호출)
  static void onNotificationReceived(String packageName, String title, String text) {
    _recent.insert(0, _NotificationItem(
      package: packageName,
      title: title,
      text: text,
      time: DateTime.now(),
    ));
    if (_recent.length > 20) _recent.removeLast();
  }

  /// 최근 알림 목록
  static List<_NotificationItem> get recent => List.unmodifiable(_recent);

  /// 중요 알림 필터링
  static _NotificationItem? get importantNotification {
    final keywords = ['배송', '회의', '약속', '결제', '알람', '리마인더', '일정'];
    for (final n in _recent) {
      final combined = '${n.title} ${n.text}'.toLowerCase();
      if (keywords.any((k) => combined.contains(k))) return n;
    }
    return null;
  }

  // ─── 카드 기반 인터랙션 ─────────────────────────

  static void showEnableCard(BuildContext ctx) {
    showCard(ctx, type: CardType.preference,
      statement: '알림 읽기 권한을 허용하시면\n중요한 알림을 놓치지 않아요.',
      backAnswer: '설정 → 알림 접근 허용 → TikiTaka 켜기\n\n'
          'TikiTaka는 알림 내용을 외부로 전송하지 않아요.',
      pos: '설정 열기', neg: '나중에',
      onResult: (c) async {
        if (c >= 1) await openSettings();
      });
  }

  static void showLatestCard(BuildContext ctx) {
    final important = importantNotification;
    if (important == null) return;

    showCard(ctx, type: CardType.reminder,
      statement: '${_appName(important.package)}에서\n새 알림이 왔어요.',
      backAnswer: '${important.title}\n\n${important.text}',
      pos: '확인', neg: '✕');
  }

  static String _appName(String package) => switch (package) {
    'com.kakao.talk' => '카카오톡',
    'com.google.android.gm' => 'Gmail',
    'com.android.mms' => '메시지',
    'com.whatsapp' => 'WhatsApp',
    'com.instagram.android' => 'Instagram',
    _ => package.split('.').last,
  };
}

class _NotificationItem {
  final String package, title, text;
  final DateTime time;
  const _NotificationItem({
    required this.package, required this.title,
    required this.text, required this.time,
  });
}
