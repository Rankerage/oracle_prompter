import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_setup.dart';
import '../services/tts_service.dart';

/// 🚀 온보딩 플로우 — 3단계로 모든 설정 완료
///
/// Step 1: 기기 사양 확인 → 호환성 체크
/// Step 2: 하드웨어 설정 마법사 → 권한·블루투스·배터리
/// Step 3: 완료 → "Hi friend!!" 인사 + 메인 화면으로
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  DeviceSpec? _spec;
  final _wizard = HardwareWizard();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkDevice();
  }

  Future<void> _checkDevice() async {
    setState(() => _isChecking = true);
    _spec = await DeviceSpec.fromDevice();
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _buildStep0_DeviceCheck(),
      1 => _buildStep1_HardwareWizard(),
      2 => _buildStep2_Complete(),
      _ => const SizedBox(),
    };
  }

  // ─── Step 0: 기기 사양 확인 ───────────────────────

  Widget _buildStep0_DeviceCheck() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // O.P 로고
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFD4A574).withAlpha(60), blurRadius: 24)],
            ),
            child: const Center(
              child: Text('O.P', style: TextStyle(
                color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 30)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('OraclePrompter', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          Text('AI 귓속말 대화 코치', style: TextStyle(
            color: Colors.grey.shade500, fontSize: 14)),

          const Spacer(flex: 1),

          // 사양 체크
          if (_isChecking)
            const CircularProgressIndicator(color: Color(0xFFD4A574))
          else if (_spec != null) ...[
            _specCard('RAM', '${_spec!.ramMB} MB', _spec!.ramMB >= DeviceSpec.minimum.ramMB),
            const SizedBox(height: 8),
            _specCard('Android', '${_spec!.androidVersion}', _spec!.androidVersion >= DeviceSpec.minimum.androidVersion),
            const SizedBox(height: 8),
            _specCard('마이크', _spec!.hasMicrophone ? '있음' : '없음', _spec!.hasMicrophone),
            const SizedBox(height: 8),
            _specCard('64-bit', _spec!.is64Bit ? '지원' : '미지원', _spec!.is64Bit),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _spec!.meetsMinimum
                    ? const Color(0xFF7CCE8C).withAlpha(20)
                    : Colors.red.shade900.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_spec!.meetsMinimum ? Icons.check_circle : Icons.warning,
                    color: _spec!.meetsMinimum ? const Color(0xFF7CCE8C) : Colors.red.shade400, size: 20),
                  const SizedBox(width: 8),
                  Text(_spec!.tier, style: TextStyle(
                    color: _spec!.meetsMinimum ? const Color(0xFF7CCE8C) : Colors.red.shade300,
                    fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ],

          const Spacer(flex: 2),

          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_spec?.meetsMinimum ?? false) ? () => setState(() => _step = 1) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: const Color(0xFF0A0A0A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('다음: 하드웨어 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _specCard(String label, String value, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 8),
          Icon(ok ? Icons.check_circle : Icons.cancel, size: 18,
            color: ok ? const Color(0xFF7CCE8C) : Colors.red.shade400),
        ],
      ),
    );
  }

  // ─── Step 1: 하드웨어 설정 마법사 ─────────────────

  Widget _buildStep1_HardwareWizard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 진행률
          Row(
            children: [
              const Text('⚙️ 하드웨어 설정', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const Spacer(),
              Text('${_wizard.completedCount}/${_wizard.totalCount}',
                style: const TextStyle(color: Color(0xFFD4A574), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text('원활한 사용을 위해 아래 설정을 완료해주세요',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 12),
          // 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _wizard.progress,
              backgroundColor: Colors.white.withAlpha(15),
              color: const Color(0xFFD4A574),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // 설정 목록
          Expanded(
            child: ListView.builder(
              itemCount: _wizard.settings.length,
              itemBuilder: (context, i) => _buildSettingTile(_wizard.settings[i]),
            ),
          ),
          // 완료 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _wizard.allDone || _wizard.completedCount >= 4
                  ? () => setState(() => _step = 2)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: const Color(0xFF0A0A0A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_wizard.allDone ? '모두 완료! 다음' : '필수 항목을 완료해주세요',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(HardwareSetting setting) {
    final color = setting.isReady ? const Color(0xFF7CCE8C) : const Color(0xFFD4A574);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _handleSetting(setting),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: setting.isReady
                ? const Color(0xFF7CCE8C).withAlpha(12)
                : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: setting.isReady
                ? const Color(0xFF7CCE8C).withAlpha(60)
                : Colors.white.withAlpha(12)),
          ),
          child: Row(
            children: [
              Icon(setting.icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(setting.name, style: TextStyle(
                      color: setting.isReady ? const Color(0xFF7CCE8C) : Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(setting.description, style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ),
              _settingActionIcon(setting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingActionIcon(HardwareSetting setting) {
    if (setting.isReady) return const Icon(Icons.check_circle, color: Color(0xFF7CCE8C), size: 22);
    return switch (setting.type) {
      SettingType.permission => Icon(Icons.shield_outlined, color: Colors.grey.shade500, size: 20),
      SettingType.toggle => Icon(Icons.toggle_off_outlined, color: Colors.grey.shade500, size: 20),
      SettingType.action => Icon(Icons.open_in_new, color: Colors.grey.shade500, size: 18),
      SettingType.info => Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
    };
  }

  void _handleSetting(HardwareSetting setting) {
    switch (setting.id) {
      case 'mic':
        _requestPermission('마이크', setting);
        break;
      case 'notifications':
        _requestPermission('알림', setting);
        break;
      case 'camera':
        _requestPermission('카메라', setting);
        break;
      case 'location':
        _requestPermission('위치', setting);
        break;
      case 'storage':
        _requestPermission('저장소', setting);
        break;
      case 'bluetooth':
        _showBluetoothGuide(setting);
        break;
      case 'battery':
        _showBatteryGuide(setting);
        break;
      case 'overlay':
        _showOverlayGuide(setting);
        break;
    }
  }

  void _requestPermission(String name, HardwareSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text('$name 권한', style: const TextStyle(color: Colors.white)),
        content: Text('$name 권한을 허용하시겠습니까?\n\n다음 화면에서 "허용"을 눌러주세요.',
          style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              _wizard.markReady(setting.id);
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574)),
            child: const Text('허용', style: TextStyle(color: Color(0xFF0A0A0A))),
          ),
        ],
      ),
    );
  }

  void _showBluetoothGuide(HardwareSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('블루투스 이어폰 연결', style: TextStyle(color: Colors.white)),
        content: Text(
          '1. 이어폰을 페어링 모드로 전환\n'
          '2. 설정 → 블루투스 → 기기 선택\n'
          '3. 연결되면 자동 인식됩니다',
          style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
          ElevatedButton(
            onPressed: () {
              _wizard.markReady(setting.id);
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574)),
            child: const Text('연결 완료', style: TextStyle(color: Color(0xFF0A0A0A))),
          ),
        ],
      ),
    );
  }

  void _showBatteryGuide(HardwareSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('배터리 최적화 해제', style: TextStyle(color: Colors.white)),
        content: Text(
          'O.P는 24시간 백그라운드 세션을 위해\n배터리 최적화 예외가 필요합니다.\n\n'
          '설정 → 앱 → OraclePrompter → 배터리 → 최적화 해제',
          style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('나중에')),
          ElevatedButton(
            onPressed: () {
              // TODO: Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
              _wizard.markReady(setting.id);
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574)),
            child: const Text('설정 열기', style: TextStyle(color: Color(0xFF0A0A0A))),
          ),
        ],
      ),
    );
  }

  void _showOverlayGuide(HardwareSetting setting) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('화면 위 표시 권한', style: TextStyle(color: Colors.white)),
        content: Text(
          '화면 공유 모드에 필요합니다.\n\n'
          '설정 → 앱 → OraclePrompter →\n다른 앱 위에 표시 → 허용',
          style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('나중에')),
          ElevatedButton(
            onPressed: () {
              _wizard.markReady(setting.id);
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574)),
            child: const Text('설정 열기', style: TextStyle(color: Color(0xFF0A0A0A))),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: 완료 ──────────────────────────────

  Widget _buildStep2_Complete() {
    // 최초 실행 완료 저장
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('onboarding_complete', true);
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          // 완료 애니메이션
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: const Color(0xFFD4A574).withAlpha(80), blurRadius: 32)],
                  ),
                  child: const Center(
                    child: Text('O.P', style: TextStyle(
                      color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 36)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Hi friend!!', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 8),
          Text('I am your OraclePrompter.\nI am always with you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontStyle: FontStyle.italic, height: 1.5)),

          const Spacer(flex: 2),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<TtsService>().whisper('Hi friend!! I am your OraclePrompter. I am always with you.');
                widget.onComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: const Color(0xFF0A0A0A),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
