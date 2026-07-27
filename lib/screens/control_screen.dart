import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/oracle_provider.dart';
import '../providers/app_providers.dart';
import '../providers/ai_config_provider.dart';
import '../providers/power_manager.dart';
import '../services/tts_service.dart';
import '../models/oracle_mode.dart';
import '../models/ai_provider.dart';
import '../widgets/ai_provider_sheet.dart';

/// 🎛️ 제어 탭 — 통화·이펙트·녹음·세션·설정
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final oracle = context.watch<OracleProvider>();
    final journal = context.watch<JournalProvider>();
    final aiConfig = context.watch<AiConfigProvider>();
    final power = context.watch<PowerManager>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 통화 제어 (서브기능) ---
          _sectionHeader('📞 통화', '대화의 일부'),
          _buildCallControls(context, oracle),

          const SizedBox(height: 20),

          // --- 오디오 이펙트 ---
          _sectionHeader('🎵 오디오 이펙트', '${oracle.activeEffects.length}개 활성'),
          _buildEffectGrid(oracle),

          const SizedBox(height: 20),

          // --- 핫키 상태 ---
          _sectionHeader('🎮 스텔스 핫키', '볼륨 버튼 제어'),
          _buildHotkeyPanel(context, oracle),

          const SizedBox(height: 20),

          // --- 녹음/녹화 ---
          _sectionHeader('⏺️ 녹음·녹화', '모든 소리 기록'),
          _buildRecordingControls(oracle),

          const SizedBox(height: 20),

          // --- 세션 관리 ---
          _sectionHeader('📁 세션', journal.activeSessionId ?? '세션 없음'),
          _buildSessionControls(context, journal),

          const SizedBox(height: 20),

          // --- 모드 선택 ---
          _sectionHeader('🎯 대화 모드', oracle.currentMode.label),
          _buildModeSelector(context, oracle),

          const SizedBox(height: 20),

          // --- AI Provider 설정 ---
          _sectionHeader('🧠 AI 엔진', aiConfig.config.providerType.label),
          _buildAiProviderSection(aiConfig),

          const SizedBox(height: 20),

          // --- 전원 관리 ---
          _sectionHeader('🔋 전원', power.currentMode.label),
          _buildPowerSection(power),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCallControls(BuildContext context, OracleProvider oracle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _callButton(context, oracle, '1단계 방어', Icons.shield, const Color(0xFFD4A574),
                () {
                  oracle.setHotkeyLevel(1);
                  HapticFeedback.mediumImpact();
                  context.read<TtsService>().whisper('1단계 방어 작동');
                }),
              const SizedBox(width: 10),
              _callButton(context, oracle, '긴급 탈출', Icons.warning_amber, Colors.red.shade400,
                () {
                  oracle.emergencyEscape();
                  HapticFeedback.heavyImpact();
                  context.read<TtsService>().alert('긴급 탈출!');
                }),
              const SizedBox(width: 10),
              _callButton(context, oracle, '원상 복구', Icons.restart_alt, Colors.green.shade400,
                () {
                  oracle.restoreNormal();
                  HapticFeedback.lightImpact();
                  context.read<TtsService>().whisper('원상 복구');
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _callButton(BuildContext context, OracleProvider oracle, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectGrid(OracleProvider oracle) {
    final effects = AudioEffect.values;
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: effects.map((effect) {
        final isActive = oracle.activeEffects.contains(effect);
        return GestureDetector(
          onTap: () => oracle.toggleEffect(effect),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFD4A574).withAlpha(25)
                  : Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive
                  ? const Color(0xFFD4A574).withAlpha(120)
                  : Colors.white.withAlpha(15)),
            ),
            child: Text(effect.label, style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHotkeyPanel(BuildContext context, OracleProvider oracle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        children: [
          _hotkeyRow('볼륨 ▼ 2회', '1단계 방어', const Color(0xFFD4A574)),
          const SizedBox(height: 8),
          _hotkeyRow('볼륨 ▼ 3초 꾹', '긴급 탈출', Colors.red.shade400),
          const SizedBox(height: 8),
          _hotkeyRow('볼륨 ▲ 2회', '원상 복구', Colors.green.shade400),
        ],
      ),
    );
  }

  Widget _hotkeyRow(String gesture, String action, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(gesture, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 10),
        Text(action, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ],
    );
  }

  Widget _buildRecordingControls(OracleProvider oracle) {
    return StatefulBuilder(
      builder: (context, setLocalState) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 녹음 토글
                GestureDetector(
                  onTap: () => setLocalState(() => _isRecording = !_isRecording),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red.shade900 : const Color(0xFFD4A574).withAlpha(30),
                      border: Border.all(color: _isRecording ? Colors.red.shade400 : const Color(0xFFD4A574).withAlpha(100), width: 2),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isRecording ? Colors.red.shade400 : const Color(0xFFD4A574),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isRecording ? '녹음 중...' : '탭하여 녹음 시작',
                        style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('폰이 켜져 있는 동안 모든 소리를 기록',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 녹화 옵션 (추가기능)
            Row(
              children: [
                Icon(Icons.videocam, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('화면 녹화 (추가)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const Spacer(),
                Switch(
                  value: false,
                  onChanged: (_) {},
                  activeColor: const Color(0xFFD4A574),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionControls(BuildContext context, JournalProvider journal) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => journal.createSession('새 세션 ${journal.sessions.length + 1}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('+ 새 세션', style: TextStyle(
                        color: Color(0xFFD4A574), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => journal.endSession(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withAlpha(80),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('세션 종료', style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (journal.sessions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...journal.sessions.take(3).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(s.isActive ? Icons.fiber_manual_record : Icons.circle_outlined,
                    size: 8, color: s.isActive ? Colors.green.shade400 : Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(s.title, style: TextStyle(
                    color: s.isActive ? Colors.white : Colors.grey.shade600, fontSize: 12)),
                  const Spacer(),
                  Text(s.createdAt.toString().substring(5, 16),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, OracleProvider oracle) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: OracleMode.values.map((mode) {
        final isSelected = oracle.currentMode == mode;
        return GestureDetector(
          onTap: () {
            oracle.setMode(mode);
            context.read<TtsService>().sayModeEntry(mode);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4A574).withAlpha(25)
                  : Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected
                  ? const Color(0xFFD4A574).withAlpha(150)
                  : Colors.white.withAlpha(15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mode.label, style: TextStyle(
                  color: isSelected ? const Color(0xFFD4A574) : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── AI Provider 설정 ─────────────────────────────────

  Widget _buildAiProviderSection(AiConfigProvider aiConfig) {
    return GestureDetector(
      onTap: () => _showAiProviderDialog(aiConfig),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Color(0xFF0A0A0A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aiConfig.config.providerType.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    aiConfig.isApiMode
                        ? '${aiConfig.config.apiModel ?? "모델 선택"} · t=${aiConfig.config.temperature}'
                        : aiConfig.config.onDeviceModel?.label ?? '온디바이스 모델 선택',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void _showAiProviderDialog(AiConfigProvider aiConfig) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => AiProviderSheet(aiConfig: aiConfig),
    );
  }

  // ─── 전원 관리 ───────────────────────────────────────

  Widget _buildPowerSection(PowerManager power) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        children: [
          // 현재 모드
          Row(
            children: [
              _powerModeIndicator(power.currentMode),
              const SizedBox(width: 8),
              Text(power.currentMode.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text(power.currentMode.batteryHint,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          // 옵션
          _powerOption('화면 OFF 시 마이크', power.micWhenScreenOff, (v) => power.setMicWhenScreenOff(v)),
          _powerOption('Wi-Fi only API', power.wifiOnlyApi, (v) => power.setWifiOnlyApi(v)),
          _powerOption('온디바이스 우선', power.preferOnDevice, (v) => power.setPreferOnDevice(v)),
        ],
      ),
    );
  }

  Widget _powerModeIndicator(PowerMode mode) {
    final color = switch (mode) {
      PowerMode.saving => Colors.blue.shade400,
      PowerMode.normal => const Color(0xFFD4A574),
      PowerMode.performance => Colors.red.shade400,
    };
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 6)],
      ),
    );
  }

  Widget _powerOption(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD4A574),
          ),
        ],
      ),
    );
  }
}
