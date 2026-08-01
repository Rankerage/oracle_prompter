import 'package:flutter/material.dart';
import '../widgets/conversation_card.dart';

/// ⌨️ Slash Commands — TikiTaka text commands
///
/// Like Hermes' /new, /help.
/// User types /something via ▲ → AskMeCard.
class SlashCommands {
  static final SlashCommands _i = SlashCommands._();
  factory SlashCommands() => _i;
  SlashCommands._();

  static const _commands = {
    '/?': ('도움말 보기', '사용 가능한 모든 명령어를 보여드려요.'),
    '/help': ('도움말 보기', '/?와 같아요.'),
    '/study': ('학습 과목 변경', '/study 영어 → 영어 학습 시작\n/study 수학 → 수학 학습 시작\n/study 멈춰 → 학습 중지'),
    '/stop': ('현재 모드 중지', '진행 중인 학습이나 모드를 멈춰요.'),
    '/stats': ('학습 통계', '오늘·이번 주·이번 달 학습 기록을 보여드려요.'),
    '/volume': ('볼륨 조절', '/volume 50 → 50%로 설정\n/volume up → 10% 올리기\n/volume down → 10% 내리기'),
    '/reset': ('처음부터 다시', '온보딩을 다시 시작해요. 데이터는 유지돼요.'),
    '/about': ('TikiTaka 정보', '버전·라이선스·GitHub 정보를 보여드려요.'),
    '/model': ('AI 모델 변경', '기본 무료 모델 ↔ 유료 모델 전환 (곧 지원).'),
  };

  static const _helpCard = '''
사용 가능한 명령어:

/?          도움말
/study      학습 과목 변경
/stop       현재 모드 중지
/stats      학습 통계 보기
/volume     볼륨 조절
/reset      처음부터 다시 시작
/about      TikiTaka 정보
/model      AI 모델 변경

모든 명령은 ▲를 누르고 입력하거나,
채팅창에 직접 입력할 수 있어요.
''';

  // ─── Handle slash input ───────────────────────

  static String? handle(String input, BuildContext ctx) {
    if (!input.startsWith('/')) return null;

    final parts = input.trim().split(' ');
    final cmd = parts[0].toLowerCase();
    final arg = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    switch (cmd) {
      case '/?':
      case '/help':
        showCard(ctx, type: CardType.learning,
          statement: '명령어 도움말',
          backAnswer: _helpCard,
          pos: '○', neg: '✕');
        return '도움말을 보여드렸어요.';

      case '/study':
        if (arg == null || arg == '멈춰' || arg == '중지') {
          return '학습 모드를 중지했어요.';
        }
        return '${arg} 학습을 시작했어요.';

      case '/stop':
        return '현재 모드를 중지했어요.';

      case '/stats':
        showCard(ctx, type: CardType.checkup,
          statement: '📊 학습 통계',
          backAnswer: '오늘: (곧 표시됩니다)\n'
              '이번 주: (곧 표시됩니다)\n'
              '이번 달: (곧 표시됩니다)',
          pos: '○', neg: '✕');
        return '통계를 보여드렸어요.';

      case '/volume':
        if (arg == 'up') {
          return '볼륨을 올렸어요.';
        } else if (arg == 'down') {
          return '볼륨을 내렸어요.';
        }
        return '볼륨을 ${arg ?? "기본값"}%로 설정했어요.';

      case '/reset':
        showCard(ctx, type: CardType.preference,
          statement: '처음부터 다시 시작할까요?',
          backAnswer: '온보딩이 다시 시작돼요.\n학습 데이터는 유지됩니다.',
          pos: '다시 시작', neg: '취소');
        return '확인 카드를 보여드렸어요.';

      case '/about':
        showCard(ctx, type: CardType.news,
          statement: 'TikiTaka Alpha',
          backAnswer: '버전: 0.1.0\n'
              '라이선스: MIT\n'
              'GitHub: Rankerage/tikitaka\n'
              '웹사이트: tikitaka.study\n\n'
              'Made with NoStressAI ♥',
          pos: '○', neg: '✕');
        return '정보를 보여드렸어요.';

      case '/model':
        showCard(ctx, type: CardType.preference,
          statement: 'AI 모델을 변경하시겠어요?',
          backAnswer: '기본: 무료 모델 (TikiTaka 부담)\n'
              '고급: 월 \$3 (더 나은 성능)\n\n'
              '현재는 기본 모델만 지원해요.',
          pos: '○', neg: '✕');
        return '모델 정보를 보여드렸어요.';

      default:
        return '알 수 없는 명령어예요. /?를 입력해보세요.';
    }
  }

  // ─── Periodic reminder card ────────────────────

  static String reminderCard() {
    // Show every ~30 cards
    final tips = [
      '▲를 누르거나 /?를 입력하면 명령어 목록을 볼 수 있어요.',
      '/study 영어 라고 입력하면 영어 학습을 시작해요.',
      '/stats 로 학습 통계를 확인할 수 있어요.',
      '/volume 으로 소리 크기를 조절할 수 있어요.',
    ];
    return tips[DateTime.now().millisecond % tips.length];
  }
}
