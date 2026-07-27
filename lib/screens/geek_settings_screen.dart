import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/power_manager.dart';
import '../providers/ai_config_provider.dart';
import '../services/session_service.dart';
import '../services/tts_service.dart';

/// 🔧 Geek Mode — Advanced settings for power users
class GeekSettingsScreen extends StatefulWidget {
  const GeekSettingsScreen({super.key});
  @override
  State<GeekSettingsScreen> createState() => _GeekSettingsScreenState();
}

class _GeekSettingsScreenState extends State<GeekSettingsScreen> {
  bool _isSessionRunning = false;
  final _checks = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final running = await SessionService.isRunning();
    if (mounted) setState(() => _isSessionRunning = running);
  }

  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerManager>();
    final ai = context.watch<AiConfigProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('🔧 Geek Mode', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF0A0A0A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('⚡ Foreground Service'),
            _toggleCard('24h Session', _isSessionRunning,
                (v) => v ? SessionService.start() : SessionService.stop(),
                subtitle: 'Keeps O.P alive in background'),
            const SizedBox(height: 12),

            _section('🔋 Power Tuning'),
            _sliderCard('Vision Interval', power.visionIntervalMs ~/ 1000, 4, 60, 'sec',
                (v) => power.setVisionInterval(v * 1000)),
            _sliderCard('Graph Interval', power.graphIntervalMs ~/ 1000, 2, 30, 'sec',
                (v) => power.setGraphInterval(v * 1000)),
            _toggleCard('Wi-Fi only API', power.wifiOnlyApi, power.setWifiOnlyApi,
                subtitle: 'Save cellular data'),
            _toggleCard('On-device first', power.preferOnDevice, power.setPreferOnDevice,
                subtitle: 'Use API only when needed'),
            const SizedBox(height: 12),

            _section('🧠 AI Engine'),
            _infoCard('Current', ai.config.providerType.label),
            _infoCard('Model', ai.isApiMode
                ? ai.config.apiModel ?? 'not set'
                : 'On-device (GGUF)'),
            const SizedBox(height: 12),

            _section('🔄 OS Workarounds'),
            _checkItem('Battery optimization', 'battery',
                () => _openSetting('battery')),
            _checkItem('Display over apps', 'overlay',
                () => _openSetting('overlay')),
            _checkItem('Usage access', 'usage',
                () => _openSetting('usage')),
            _checkItem('Notification access', 'notif',
                () => _openSetting('notif')),
            _checkItem('Autostart (MIUI/Xiaomi)', 'autostart',
                () => _openSetting('autostart')),
            const SizedBox(height: 12),

            _section('📦 Model Downloads'),
            _actionCard('Download GGUF model (Gemma 3 4B)',
                '~2.4GB. On-device LLM.',
                Icons.download, () {}),
            _actionCard('Download Korean STT model',
                '~80MB. sherpa-onnx SenseVoice.',
                Icons.mic, () {}),
            _actionCard('Install SherpaTTS (F-Droid)',
                'Natural Korean TTS via Piper.',
                Icons.speaker, () {}),
            const SizedBox(height: 12),

            _section('📋 Diagnostics'),
            _diagnosticCard(),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(
      color: Color(0xFFD4A574), fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _toggleCard(String label, bool value, Function(bool) onChanged, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: (v) { onChanged(v); setState(() {}); },
            activeColor: const Color(0xFFD4A574)),
        ],
      ),
    );
  }

  Widget _sliderCard(String label, int value, int min, int max, String unit, Function(int) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Expanded(
            child: Slider(
              value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
              activeColor: const Color(0xFFD4A574),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Text('$value$unit', style: const TextStyle(color: Color(0xFFD4A574), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF141414),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withAlpha(10)),
    ),
    child: Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    ),
  );

  Widget _checkItem(String label, String id, VoidCallback onTap) {
    final checked = _checks[id] ?? false;
    return GestureDetector(
      onTap: () { onTap(); setState(() => _checks[id] = true); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF7CCE8C).withAlpha(12) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: checked
              ? const Color(0xFF7CCE8C).withAlpha(60)
              : Colors.white.withAlpha(10)),
        ),
        child: Row(
          children: [
            Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18, color: checked ? const Color(0xFF7CCE8C) : Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(
                color: checked ? const Color(0xFF7CCE8C) : Colors.grey.shade400, fontSize: 13)),
            const Spacer(),
            const Icon(Icons.open_in_new, size: 14, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4A574), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }

  Widget _diagnosticCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          _diagRow('Session', _isSessionRunning ? '✅ Active' : '⏸️ Stopped'),
          _diagRow('STT Engine', 'sherpa-onnx (SenseVoice)'),
          _diagRow('LLM Engine', 'llama_cpp_dart'),
          _diagRow('TTS Engine', 'flutter_tts (Piper/SherpaTTS)'),
          _diagRow('Build', 'debug (Flutter 3.44)'),
        ],
      ),
    );
  }

  Widget _diagRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    ),
  );

  void _openSetting(String id) {
    // TODO: Open specific Android settings via Intent
    HapticFeedback.mediumImpact();
  }
}
