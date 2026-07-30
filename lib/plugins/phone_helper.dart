import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/conversation_card.dart';

/// 📱 PhoneHelper Plugin — 폰 사용법을 카드로
///
/// 볼륨, 배터리, 저장공간, 알림, 권한 등
/// 모든 폰 설정을 카드 가이드로.
class PhoneHelper {
  static const _channel = MethodChannel('com.oracleprompter/phone');

  // ─── 실제 가능한 것들 ──────────────────────────

  /// 볼륨 조절 (media volume only)
  static Future<int> getVolume() async {
    try {
      return await _channel.invokeMethod('getVolume');
    } catch (_) {
      return 50;
    }
  }

  static Future<void> setVolume(int level) async {
    try {
      await _channel.invokeMethod('setVolume', {'level': level.clamp(0, 100)});
    } catch (_) {}
  }

  /// 볼륨 올리기/내리기
  static Future<void> volumeUp() async {
    final current = await getVolume();
    await setVolume(current + 10);
  }

  static Future<void> volumeDown() async {
    final current = await getVolume();
    await setVolume(current - 10);
  }

  // ─── 카드 기반 요청 ────────────────────────────

  static void guide(BuildContext ctx, String request) {
    if (request.contains('볼륨')) {
      _handleVolume(ctx, request.contains('올려'));
    } else if (request.contains('핫스팟') || request.contains('테더링')) {
      _openAndGuide(ctx, 'hotspot', '핫스팟',
        '설정 → 연결 → 모바일 핫스팟 및 테더링',
        '화면에서 켜기만 누르시면 돼요.', '켰어요');
    } else if (request.contains('와이파이') || request.contains('wifi')) {
      _openAndGuide(ctx, 'wifi', 'Wi-Fi',
        '설정 → 연결 → Wi-Fi',
        '연결할 네트워크를 선택하세요.', '연결했어요');
    } else if (request.contains('블루투스')) {
      _openAndGuide(ctx, 'bluetooth', '블루투스',
        '설정 → 연결 → 블루투스',
        '화면에서 켜기만 누르시면 돼요.', '켰어요');
    } else if (request.contains('배터리')) {
      _guideBattery(ctx);
    } else if (request.contains('저장') || request.contains('용량')) {
      _guideStorage(ctx);
    } else if (request.contains('알림')) {
      _guideNotifications(ctx);
    }
  }

  /// Open settings + guide to last step
  static void _openAndGuide(BuildContext ctx, String setting, String label,
      String path, String lastStep, String confirmLabel) {
    showCard(ctx, type: CardType.preference,
      statement: '$label을 켜드릴게요.',
      backAnswer: '$path까지 이동했어요.\n\n$lastStep',
      pos: confirmLabel, neg: '취소',
      onResult: (c) async {
        if (c >= 1) {
          // Open settings page
          try {
            await _channel.invokeMethod('openSettings', {'setting': setting});
          } catch (_) {}
        }
      });
  }

  static void _handleVolume(BuildContext ctx, bool up) {
    showCard(ctx, type: CardType.preference,
      statement: '볼륨을 ${up ? "올릴" : "내릴"}까요?',
      backAnswer: up ? '볼륨을 올렸어요.' : '볼륨을 내렸어요.',
      pos: '○', neg: '✕',
      onResult: (c) async {
        if (c >= 1) {
          if (up) await volumeUp(); else await volumeDown();
        }
      });
  }

  // ─── 디바이스별 가이드 ─────────────────────────

  static void _guideBattery(BuildContext ctx) {
    final brand = _deviceBrand();
    final steps = switch (brand) {
      'samsung' => [
        '설정 → 디바이스 케어 → 배터리 → 앱 전원 관리 → TikiTaka → "최적화 안 함"',
        '또는 설정 → 애플리케이션 → TikiTaka → 배터리 → "제한 없음"',
      ],
      'xiaomi' => [
        '보안 앱 → 배터리 → 앱 배터리 세이버 → TikiTaka → "제한 없음"',
        '설정 → 앱 → TikiTaka → 배터리 세이버 → "제한 없음"',
        '보안 앱 → 권한 → 자동 시작 → TikiTaka 켜기',
      ],
      _ => [
        '설정 → 앱 → TikiTaka → 배터리 → "제한 없음"',
        '설정 → 배터리 → 백그라운드 사용 제한 → TikiTaka 제외',
      ],
    };

    // Show first step
    showCard(ctx, type: CardType.learning,
      statement: '배터리 최적화를 해제하면\nTikiTaka가 더 오래 함께할 수 있어요.',
      backAnswer: steps.join('\n\n'),
      pos: '○', neg: '✕');
  }

  static void _guideStorage(BuildContext ctx) {
    showCard(ctx, type: CardType.learning,
      statement: '저장 공간이 부족하세요?',
      backAnswer: 'TikiTaka의 데이터는 아주 작아요.\n보통 100MB 미만입니다.\n\n'
          '저장 공간은 주로 사진·영상·앱 캐시가 차지해요.\n'
          '설정 → 저장공간에서 확인할 수 있어요.',
      pos: '○', neg: '✕');
  }

  static void _guideNotifications(BuildContext ctx) {
    showCard(ctx, type: CardType.learning,
      statement: 'TikiTaka 알림을 켜두시면\n놓치는 말이 없어요.',
      backAnswer: '설정 → 앱 → TikiTaka → 알림 → 허용\n\n'
          '방해 금지 모드에서도 알림을 받으려면\n'
          '설정 → 알림 → 고급 → 방해 금지 예외 → TikiTaka 추가',
      pos: '○', neg: '✕');
  }

  static String _deviceBrand() {
    // Simplified — in production, use device_info_plus
    return 'default';
  }
}
