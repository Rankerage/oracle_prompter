import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎤 Ask Me Anything Card — 주관식 질문 (음성 입력)
///
/// Triggered by:
/// - Long-pressing ○ or ✕ on any card (2 seconds)
/// - Triple-tapping anywhere
/// - Saying "O.P" followed by a pause (voice trigger)
class AskMeCard extends StatefulWidget {
  final void Function(String question)? onSubmit;
  final VoidCallback? onCancel;

  const AskMeCard({super.key, this.onSubmit, this.onCancel});

  @override
  State<AskMeCard> createState() => _AskMeCardState();
}

class _AskMeCardState extends State<AskMeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _listening = true;
  String _transcript = '';
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this);
    _pulse.repeat(reverse: true);
    // Auto-stop listening after 8 seconds of silence
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _listening) _stopListening();
    });
  }

  void _stopListening() {
    setState(() => _listening = false);
    _pulse.stop();
  }

  void _submit() {
    if (_transcript.isEmpty) return;
    setState(() => _submitted = true);
    HapticFeedback.mediumImpact();
    widget.onSubmit?.call(_transcript);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 320, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A1030), Color(0xFF0D0D1A)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFB088D4).withAlpha(80)),
          boxShadow: [BoxShadow(color: const Color(0xFFB088D4).withAlpha(25), blurRadius: 32)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Mic icon with pulse
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulse.value * 0.15),
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening
                        ? const Color(0xFFB088D4).withAlpha(30)
                        : const Color(0xFF7CCE8C).withAlpha(30),
                    border: Border.all(
                      color: _listening ? const Color(0xFFB088D4) : const Color(0xFF7CCE8C),
                      width: 2.5),
                  ),
                  child: Icon(
                    _listening ? Icons.mic : Icons.check,
                    color: _listening ? const Color(0xFFB088D4) : const Color(0xFF7CCE8C),
                    size: 28),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Transcript or prompt
          if (_transcript.isNotEmpty)
            Text('"$_transcript"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
          else
            Text(_listening ? '무엇이든 물어보세요...' : '질문이准备好면 눌러주세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),

          const SizedBox(height: 8),
          if (_listening)
            Text('듣고 있어요', style: TextStyle(color: const Color(0xFFB088D4).withAlpha(150), fontSize: 11)),

          const SizedBox(height: 20),

          // Action buttons
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _smallBtn('취소', Colors.grey.shade600, () {
              widget.onCancel?.call();
              Navigator.of(context).pop();
            }),
            const SizedBox(width: 16),
            if (_transcript.isNotEmpty)
              _smallBtn('질문하기', const Color(0xFF7CCE8C), _submit),
          ]),
        ]),
      ),
    );
  }

  Widget _smallBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
}

/// Show Ask Me card as overlay
void showAskMeCard(BuildContext context, {void Function(String)? onSubmit}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(200),
    builder: (_) => AskMeCard(onSubmit: onSubmit),
  );
}
