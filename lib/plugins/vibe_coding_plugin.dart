import '../core/tikitaka_plugin.dart';
import '../widgets/conversation_card.dart';
import 'package:flutter/material.dart';

/// 🔧 VibeCoding Plugin — 개발 환경 설정을 카드로
///
/// "진정한 바이브코딩을 위해"
/// WSL, Termux, VPS에 Hermes Agent 설치를 카드 대화로 안내.
/// 터미널 명령어 보여주지 않음. 확인만.
class VibeCodingPlugin extends TikiTakaPlugin {
  @override String get name => 'VibeCoding';
  @override String get description => '개발 환경 설정 가이드. WSL·Termux·VPS·Hermes 설치';
  @override List<String> get capabilities => ['dev', 'setup', 'install', 'hermes'];
  bool _enabled = false;
  @override bool get isEnabled => _enabled;

  // ─── Setup guides ──────────────────────────────

  static const _guides = {
    'wsl': _WslGuide(),
    'termux': _TermuxGuide(),
    'vps': _VpsGuide(),
    'hermes': _HermesGuide(),
  };

  @override Future<void> init() async { _enabled = true; }

  @override Future<String?> handle(String task, Map<String, dynamic> context) async {
    final ctx = context['context'] as BuildContext?;
    if (ctx == null) return null;

    if (task.contains('wsl')) { _WslGuide().start(ctx); return 'WSL 설정을 시작합니다'; }
    if (task.contains('termux')) { _TermuxGuide().start(ctx); return 'Termux 설정을 시작합니다'; }
    if (task.contains('vps') || task.contains('서버')) { _VpsGuide().start(ctx); return 'VPS 설정을 시작합니다'; }
    if (task.contains('hermes')) { _HermesGuide().start(ctx); return 'Hermes 설치를 시작합니다'; }
    return null;
  }

  @override Future<void> dispose() async { _enabled = false; }
}

/// Base class for all setup guides
abstract class _SetupGuide {
  final List<_Step> _steps = [];
  int _current = 0;

  void start(BuildContext ctx) => _showStep(ctx);

  void _showStep(BuildContext ctx) {
    if (_current >= _steps.length) {
      showCard(ctx, type: CardType.news,
        statement: '설정이 완료되었어요.',
        backAnswer: '도움이 필요하시면 언제든 다시 불러주세요.',
        pos: '○', neg: '✕');
      return;
    }
    final step = _steps[_current];
    showCard(ctx, type: CardType.checkup,
      statement: step.check, backAnswer: step.help,
      pos: '○', neg: '✕',
      onResult: (c) {
        if (c >= 1) {
          _current++;
          _showStep(ctx);
        }
        // If ✕, help was shown. Repeat same step.
      });
  }
}

class _Step { final String check, help; const _Step(this.check, this.help); }

// ─── WSL Guide ───────────────────────────────────

class _WslGuide extends _SetupGuide {
  _WslGuide() {
    _steps.addAll([
      _Step('Windows 10/11을 사용하고 계시나요?',
          'WSL은 Windows 10 버전 2004 이상에서만 설치할 수 있어요.\n설정 → 시스템 → 정보에서 버전을 확인하세요.'),
      _Step('PowerShell을 관리자 권한으로 열어보셨나요?',
          '시작 메뉴에서 PowerShell을 검색하고, 오른쪽 클릭 → 관리자 권한으로 실행을 선택하세요.'),
      _Step('wsl --install 명령어를 실행하셨나요?',
          'PowerShell에 wsl --install 이라고 입력하고 Enter를 누르세요.\n컴퓨터가 다시 시작됩니다.'),
      _Step('재부팅 후 Ubuntu 창이 열렸나요?',
          '사용자 이름과 비밀번호를 설정하라는 창이 나오면 성공입니다.\n아무거나 입력하세요. 잊어버리면 안 돼요!'),
      _Step('Ubuntu에서 sudo apt update를 실행하셨나요?',
          'Ubuntu 창에 sudo apt update 라고 입력하고 Enter.\n비밀번호를 물어보면 방금 설정한 비밀번호를 입력하세요.'),
    ]);
  }
}

// ─── Termux Guide ────────────────────────────────

class _TermuxGuide extends _SetupGuide {
  _TermuxGuide() {
    _steps.addAll([
      _Step('F-Droid에서 Termux를 설치하셨나요?',
          'Play Store 말고 F-Droid에서 받으세요. Play Store 버전은 오래됐어요.\nf-droid.org에서 F-Droid 앱을 먼저 설치한 후 Termux를 검색하세요.'),
      _Step('Termux를 열고 pkg update를 실행하셨나요?',
          'Termux 앱을 열면 검은 화면이 나와요. pkg update 라고 입력하고 Enter.'),
      _Step('termux-setup-storage를 실행하셨나요?',
          '저장소 접근 권한을 허용해야 파일을 주고받을 수 있어요.'),
    ]);
  }
}

// ─── VPS Guide ───────────────────────────────────

class _VpsGuide extends _SetupGuide {
  _VpsGuide() {
    _steps.addAll([
      _Step('VPS 서비스를 선택하셨나요?',
          '처음이시면 DigitalOcean이나 Vultr를 추천드려요.\n가장 저렴한 플랜(월 $4~6)으로도 충분합니다.'),
      _Step('Ubuntu 24.04 이미지로 서버를 생성하셨나요?',
          '서버 생성 시 운영체제로 Ubuntu 24.04 LTS를 선택하세요.'),
      _Step('SSH 키를 설정하셨나요?',
          '비밀번호보다 SSH 키가 더 안전해요. 서비스에서 자동으로 생성해주는 경우가 많아요.'),
      _Step('서버에 접속해보셨나요?',
          'ssh root@서버IP 를 터미널에 입력하세요. "Are you sure?"라고 물으면 yes.'),
    ]);
  }
}

// ─── Hermes Guide ────────────────────────────────

class _HermesGuide extends _SetupGuide {
  _HermesGuide() {
    _steps.addAll([
      _Step('Python 3.11 이상이 설치되어 있나요?',
          '터미널에 python3 --version 이라고 입력해보세요.\n없으면 각 환경에 맞게 설치 가이드를 다시 실행해주세요.'),
      _Step('pip가 설치되어 있나요?',
          'pip3 --version 이라고 입력해보세요.\n보통 Python과 함께 설치됩니다.'),
      _Step('가상환경을 만들고 싶으세요?',
          'python3 -m venv hermes-env 라고 입력하면 hermes-env 폴더가 생겨요.\nsource hermes-env/bin/activate 로 활성화할 수 있어요.'),
      _Step('pip install hermes-agent 실행하셨나요?',
          'pip install hermes-agent 라고 입력하면 자동으로 설치됩니다.\n인터넷 속도에 따라 1~2분 걸려요.'),
      _Step('hermes setup 실행하셨나요?',
          'hermes setup 이라고 입력하면 초기 설정이 시작됩니다.\nAPI 키는 나중에 입력해도 돼요. 건너뛰기 하세요.'),
      _Step('hermes 명령어가 작동하나요?',
          '터미널에 hermes 라고만 입력해보세요. 대화가 시작되면 성공!'),
    ]);
  }
}
