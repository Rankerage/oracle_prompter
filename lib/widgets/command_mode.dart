import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎙️ Command Mode — triggered by ▲ on any card
///
/// Users can issue voice/text commands:
///  "그래프 보여줘" → navigate to Mind tab
///  "카메라 켜줘" → open Sight mode  
///  "통역해줘" → start live translation
///
/// O.P never uses question words in response.
class CommandMode extends StatefulWidget {
  final void Function(String command)? onCommand;
  const CommandMode({super.key, this.onCommand});
  @override
  State<CommandMode> createState() => _CommandModeState();
}

class _CommandModeState extends State<CommandMode> {
  final _ctrl = TextEditingController();
  String _result = '';
  bool _loading = false;
  bool _voiceMode = false;

  static const _commands = {
    '그래프': 'graph',
    '마인드': 'graph',
    '카메라': 'camera', '켜줘': 'camera',
    '통역': 'translate',
    '일기': 'journal',
    '설정': 'settings',
    '모드': 'mode',
    '멈춰': 'stop', '중지': 'stop',
    '도움': 'help',
  };

  void _submit() {
    final input = _ctrl.text.trim();
    if (input.isEmpty) return;

    setState(() { _loading = true; _ctrl.clear(); });
    HapticFeedback.mediumImpact();

    // Parse command
    final cmd = _parseCommand(input);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = switch (cmd) {
          'graph' => '마인드 그래프를 보여드릴게요.',
          'camera' => '시선 모드를 켤게요.',
          'translate' => '통역을 시작할게요.',
          'journal' => '일기장을 열어드릴게요.',
          'settings' => '설정 화면으로 이동할게요.',
          'mode' => '모드 전환 패널을 열어드릴게요.',
          'stop' => '알겠습니다. 조용히 있을게요.',
          'help' => '명령하신 대로 도와드릴게요.',
          _ => '"$input" — 확인했습니다.',
        };
      });
      widget.onCommand?.call(cmd);
    });
  }

  String _parseCommand(String input) {
    final lower = input.toLowerCase();
    for (final entry in _commands.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 340, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF152025), Color(0xFF0D0D1A)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6AC9D4).withAlpha(60)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6AC9D4), Color(0xFF4A9AB4)]),
              borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('▲', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))),
            const SizedBox(width: 10),
            const Text('무엇을 도와드릴까요?', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),

          const SizedBox(height: 14),
          // Hint chips
          Wrap(spacing: 6, runSpacing: 6, children: [
            _chip('그래프 보여줘', 'graph'),
            _chip('카메라 켜줘', 'camera'),
            _chip('통역해줘', 'translate'),
            _chip('일기 보여줘', 'journal'),
            _chip('설정 열어줘', 'settings'),
          ]),

          const SizedBox(height: 12),
          // Result
          if (_result.isNotEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withAlpha(6), borderRadius: BorderRadius.circular(12)),
              child: Text(_result, style: const TextStyle(color: Color(0xFF6AC9D4), fontSize: 13))),

          if (_result.isNotEmpty) const SizedBox(height: 12),
          // Input
          TextField(
            controller: _ctrl, autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: _voiceMode ? '듣고 있어요...' : '명령을 입력하세요...',
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              filled: true, fillColor: Colors.white.withAlpha(8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: Icon(_voiceMode ? Icons.mic : Icons.keyboard, color: const Color(0xFF6AC9D4), size: 20),
                  onPressed: () => setState(() => _voiceMode = !_voiceMode)),
                if (_loading)
                  const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6AC9D4))))
                else
                  IconButton(icon: const Icon(Icons.send_rounded, color: Color(0xFF6AC9D4), size: 20), onPressed: _submit),
              ]),
            ),
            onSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 12),
          // ▼ Back
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(width: 44, height: 44, decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white.withAlpha(8),
              border: Border.all(color: Colors.white.withAlpha(20))),
              child: const Center(child: Text('▼', style: TextStyle(color: Color(0xFF888888), fontSize: 18)))),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, String cmd) => GestureDetector(
    onTap: () { _ctrl.text = label; _submit(); },
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF6AC9D4).withAlpha(15),
        borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF6AC9D4).withAlpha(40))),
      child: Text(label, style: const TextStyle(color: Color(0xFF6AC9D4), fontSize: 11))),
  );

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

void showCommandMode(BuildContext context, {void Function(String)? onCommand}) {
  showDialog(context: context, barrierColor: Colors.black.withAlpha(200),
    builder: (_) => CommandMode(onCommand: onCommand));
}
