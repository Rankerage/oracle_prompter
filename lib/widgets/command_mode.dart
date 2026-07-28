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
    '그래프': ('graph', 95),
    '마인드': ('graph', 95),
    '카메라': ('camera', 95), '켜줘': ('camera', 70),
    '통역': ('translate', 95),
    '일기': ('journal', 95),
    '설정': ('settings', 90),
    '멈춰': ('stop', 95), '중지': ('stop', 95),
    '도움': ('help', 90),
    '영어': ('english', 85),
    '신조어': ('slang', 85),
    '공부': ('learn', 60), // ambiguous — could be anything
    '학습': ('learn', 60),
    '들려': ('audio', 60), '소리': ('audio', 60),
    '질문': ('ask', 70),
    '모드': ('mode', 85),
    '대화': ('chat', 70),
    '요약': ('summarize', 80),
  };

  void _submit() {
    final input = _ctrl.text.trim();
    if (input.isEmpty) return;

    setState(() { _loading = true; _ctrl.clear(); });
    HapticFeedback.mediumImpact();

    final (cmd, _) = _parse(input);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() { _loading = false; });
      _result = switch (cmd) {
        'graph' => '마인드 그래프를 보여드릴게요.',
        'camera' => '시선 모드를 켤게요.',
        'translate' => '통역을 시작할게요.',
        'journal' => '일기장을 열어드릴게요.',
        'settings' => '설정 화면으로 이동할게요.',
        'mode' => '모드 전환 패널을 열어드릴게요.',
        'stop' => '알겠습니다. 조용히 있을게요.',
        'help' => '명령하신 대로 도와드릴게요.',
        'english' => '영어 듣기 공부를 시작할게요.',
        'slang' => '신조어 학습 카드를 준비했어요.',
        'learn' => '맞춤형 학습을 시작할게요.',
        'chat' => '대화 모드로 전환할게요.',
        'ask' => '무엇이든 물어보세요.',
        'summarize' => '지금까지 대화를 요약해드릴게요.',
        'audio' => '소리 관련 설정을 열어드릴게요.',
        _ => '죄송합니다. 다시 한 번 말씀해주시겠어요?',
      };
      widget.onCommand?.call(cmd);
    });
  }

  (String, int) _parse(String input) {
    int bestConf = 0;
    String bestCmd = 'unknown';
    for (final e in _commands.entries) {
      if (input.contains(e.key) && e.value.$2 > bestConf) {
        bestConf = e.value.$2;
        bestCmd = e.value.$1;
      }
    }
    return (bestCmd, bestConf);
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
