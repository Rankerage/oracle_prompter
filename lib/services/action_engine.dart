import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/conversation_card.dart';

/// ⚡ Action Engine — 질문을 넘어 실행까지
///
/// 모든 액션은 카드 확인 후 실행.
/// 사용자는 여전히 ○✕만 누름.
class ActionEngine {
  static const _channel = MethodChannel('com.oracleprompter/action');

  // ─── 실행 가능한 액션들 ─────────────────────────

  /// 검색
  static Future<void> search(String query) async {
    final url = Uri.https('www.google.com', '/search', {'q': query});
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 유튜브 재생
  static Future<void> youtube(String query) async {
    final url = Uri.https('www.youtube.com', '/results', {'search_query': query});
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 지도 열기
  static Future<void> maps(String query) async {
    final url = Uri.https('www.google.com', '/maps/search/$query');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 타이머 설정
  static Future<void> timer(int seconds) async {
    final url = Uri.parse('intent:#Intent;action=android.intent.action.SET_TIMER;'
        'S.android.intent.extra.alarm.LENGTH=$seconds;end');
    try {
      await launchUrl(url);
    } catch (_) {
      await _channel.invokeMethod('setTimer', {'seconds': seconds});
    }
  }

  /// 알람 설정
  static Future<void> alarm(int hour, int minute, String? label) async {
    final msg = label ?? 'TikiTaka 알람';
    final url = Uri.parse('intent:#Intent;action=android.intent.action.SET_ALARM;'
        'S.android.intent.extra.alarm.HOUR=$hour;'
        'i.android.intent.extra.alarm.MINUTES=$minute;'
        'S.android.intent.extra.alarm.MESSAGE=$msg;end');
    try {
      await launchUrl(url);
    } catch (_) {
      await _channel.invokeMethod('setAlarm', {'hour': hour, 'minute': minute});
    }
  }

  /// 🔔 리마인더 — Google Tasks/Keep 연동
  static Future<void> reminder(String title, {String? note, int? hour, int? minute}) async {
    // Try Google Tasks intent
    final url = Uri.parse('intent:#Intent;action=android.intent.action.INSERT;'
        'S.title=$title;'
        'S.notes=${note ?? ''};end');
    try {
      await launchUrl(url);
    } catch (_) {
      await copyToClipboard('리마인더: $title');
    }
  }

  /// 📅 캘린더 일정 추가
  static Future<void> calendarEvent(String title, {String? location, int? hour, int? minute}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, hour ?? 12, minute ?? 0)
        .millisecondsSinceEpoch;
    final url = Uri.parse('intent:#Intent;action=android.intent.action.INSERT;'
        'v.android.intent.extra.EVENT_BEGIN_TIME=$start;'
        'S.title=$title;'
        'S.eventLocation=${location ?? ''};end');
    try {
      await launchUrl(url);
    } catch (_) {
      await copyToClipboard('일정: $title');
    }
  }

  /// 🎵 음악 검색/재생
  static Future<void> music(String query) async {
    final url = Uri.parse('intent:#Intent;action=android.media.action.MEDIA_PLAY_FROM_SEARCH;'
        'S.query=$query;end');
    try {
      await launchUrl(url);
    } catch (_) {
      // Fallback: YouTube
      await youtube(query);
    }
  }

  /// 메모 저장
  static Future<void> note(String text) async {
    try {
      await _channel.invokeMethod('saveNote', {'text': text});
    } catch (_) {
      // Clipboard fallback
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  /// 클립보드 복사
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// 공유
  static Future<void> share(String text) async {
    await _channel.invokeMethod('share', {'text': text});
  }

  /// 손전등
  static Future<void> flashlight(bool on) async {
    try {
      await _channel.invokeMethod('flashlight', {'on': on});
    } catch (_) {}
  }

  // ─── 카드 기반 요청 처리 ───────────────────────

  static Future<bool> execute(BuildContext ctx, String request) async {
    final r = request.toLowerCase();

    // Search
    if (r.startsWith('검색 ') || r.startsWith('찾아줘 ')) {
      final query = request.substring(request.indexOf(' ') + 1);
      return _confirm(ctx, '$query 검색', 'Google에서 검색할게요.', () => search(query));
    }

    // YouTube
    if (r.contains('유튜브') || r.contains('youtube')) {
      final query = request.replaceAll(RegExp(r'유튜브|youtube|\s*찾아줘\s*|\s*틀어줘\s*'), '');
      return _confirm(ctx, 'YouTube 검색', '$query 검색할게요.', () => youtube(query));
    }

    // Maps
    if (r.contains('지도') || r.contains('길찾기') || r.contains('위치')) {
      final query = request.replaceAll(RegExp(r'지도|길찾기|위치|\s*알려줘\s*'), '');
      return _confirm(ctx, '지도 검색', '$query 찾을게요.', () => maps(query));
    }

    // Timer
    if (r.contains('타이머') || r.contains('몇 분')) {
      final mins = RegExp(r'(\d+)\s*분').firstMatch(request);
      final secs = mins != null ? int.parse(mins.group(1)!) * 60 : 300;
      return _confirm(ctx, '${secs ~/ 60}분 타이머', '타이머가 설정됐어요.', () => timer(secs));
    }

    // Alarm
    if (r.contains('알람') || r.contains('몇 시')) {
      final time = RegExp(r'(\d{1,2})\s*시\s*(\d{1,2})?\s*분?').firstMatch(request);
      if (time != null) {
        final h = int.parse(time.group(1)!);
        final m = int.tryParse(time.group(2) ?? '0') ?? 0;
        return _confirm(ctx, '$h시 ${m}분 알람', '알람이 설정됐어요.', () => alarm(h, m, 'TikiTaka 알람'));
      }
    }

    // Reminder
    if (r.contains('리마인더') || r.contains('알려줘') && r.contains('나중에')) {
      final content = request.replaceAll(RegExp(r'리마인더|알려줘|나중에'), '').trim();
      return _confirm(ctx, '리마인더 등록', '등록했어요.', () => reminder(content));
    }

    // Calendar
    if (r.contains('일정') || r.contains('캘린더') || r.contains('약속')) {
      final content = request.replaceAll(RegExp(r'일정|캘린더|약속|추가|등록'), '').trim();
      return _confirm(ctx, '일정 추가', '캘린더에 추가했어요.', () => calendarEvent(content));
    }

    // Music
    if (r.contains('음악') || r.contains('노래') || r.contains('틀어줘')) {
      final query = request.replaceAll(RegExp(r'음악|노래|틀어줘|들려줘'), '').trim();
      return _confirm(ctx, '음악 검색', '$query 찾을게요.', () => music(query));
    }

    // Note
    if (r.startsWith('메모 ') || r.startsWith('기록 ')) {
      final text = request.substring(request.indexOf(' ') + 1);
      return _confirm(ctx, '메모 저장', '클립보드에 복사했어요.', () async {
        await copyToClipboard(text);
      });
    }

    // Copy
    if (r.startsWith('복사 ')) {
      final text = request.substring(3);
      return _confirm(ctx, '복사', '클립보드에 복사했어요.', () => copyToClipboard(text));
    }

    // Flashlight
    if (r.contains('손전등') || r.contains('플래시')) {
      final on = r.contains('켜');
      return _confirm(ctx, '손전등 ${on ? "켜기" : "끄기"}', '', () => flashlight(on));
    }

    return false; // No action matched
  }

  static Future<bool> _confirm(BuildContext ctx, String title, String back, Future<void> Function() action) async {
    final completer = Completer<bool>();
    showCard(ctx, type: CardType.preference,
      statement: '$title 할까요?',
      backAnswer: back.isEmpty ? '실행했어요.' : back,
      pos: '○', neg: '✕',
      onResult: (c) async {
        if (c >= 1) {
          await action();
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      });
    return completer.future;
  }
}
