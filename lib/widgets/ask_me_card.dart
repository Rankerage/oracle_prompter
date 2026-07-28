import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎤 Ask Me Card — 주관식 질문 (텍스트 기본, 키보드 음성 이용)
///
/// Layout:
///   [AI 답변]
///   ┌──────────────┐
///   │ 텍스트 입력    │ ← 키보드 마이크로 음성입력 가능
///   └──────────────┘
///        [▼] ← 객체식 카드로 돌아가기
class AskMeCard extends StatefulWidget {
  final void Function(String question)? onSubmit;
  const AskMeCard({super.key, this.onSubmit});
  @override
  State<AskMeCard> createState() => _AskMeCardState();
}

class _AskMeCardState extends State<AskMeCard> {
  final _controller = TextEditingController();
  String _answer = '';
  bool _loading = false;

  void _submit() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _controller.clear(); });
    HapticFeedback.mediumImpact();

    // Simulate AI response — in production, calls AiService
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _answer = '"$q"에 대한 답변입니다.\n\n곧 더 자세한 답변을 드릴 수 있을 거예요.';
      });
      widget.onSubmit?.call(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 340, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A1030), Color(0xFF0D0D1A)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFB088D4).withAlpha(60)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFB088D4), Color(0xFF8B6CC4)]),
              borderRadius: BorderRadius.circular(8),
            ), child: const Center(child: Text('OP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)))),
            const SizedBox(width: 10),
            const Text('무엇이든 물어보세요', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),

          const SizedBox(height: 16),

          // AI Answer (if any)
          if (_answer.isNotEmpty) ...[
            Container(width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withAlpha(6), borderRadius: BorderRadius.circular(12)),
              child: Text(_answer, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))),
            const SizedBox(height: 12),
          ],

          // Text input
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '질문을 입력하세요...',
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              filled: true, fillColor: Colors.white.withAlpha(8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _loading
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB088D4))))
                  : IconButton(icon: const Icon(Icons.send_rounded, color: Color(0xFFB088D4), size: 20), onPressed: _submit),
            ),
            onSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 12),

          // ▼ Switch back to objective card
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

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}

void showAskMeCard(BuildContext context, {void Function(String)? onSubmit}) {
  showDialog(context: context, barrierColor: Colors.black.withAlpha(200),
    builder: (_) => AskMeCard(onSubmit: onSubmit));
}
