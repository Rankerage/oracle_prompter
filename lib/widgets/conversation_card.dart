import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ask_me_card.dart';

enum CardType { preference, reminder, learning, news, checkup, askMe }

/// 🃏 Conversation Card — 3-button: [✕] [▲] [○]
///
/// ▲ = Switch to open-ended question mode
class ConversationCard extends StatefulWidget {
  final CardType type;
  final String statement, backAnswer, positiveLabel, negativeLabel;
  final Color? accentColor;
  final bool speakAloud;
  final void Function(int confidence)? onResult;

  const ConversationCard({
    super.key, required this.type, required this.statement,
    required this.backAnswer, this.positiveLabel = '네',
    this.negativeLabel = '아니오', this.accentColor,
    this.speakAloud = true, this.onResult,
  });

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flip;
  late Animation<double> _flipAnim;
  bool _flipped = false;
  int? _first, _second;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(duration: const Duration(milliseconds: 450), vsync: this);
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flip, curve: Curves.easeInOut));
  }

  void _tap(bool accepted) {
    HapticFeedback.selectionClick();
    if (!_flipped) {
      _first = accepted ? 1 : 0;
      _flip.forward(); setState(() => _flipped = true);
    } else {
      _second = accepted ? 1 : 0;
      final c = _first == 1 && _second == 1 ? 2 : (_first == 0 && _second == 1 ? 1 : (_first == 1 && _second == 0 ? -1 : -2));
      widget.onResult?.call(c);
      Future.delayed(const Duration(milliseconds: 600), () { if (mounted) Navigator.of(context).pop(); });
    }
  }

  void _openAsk() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    showAskMeCard(context, onSubmit: (q) {});
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? _typeColor();
    return Center(
      child: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity! > 60) _tap(true);
          else if (d.primaryVelocity! < -60) _tap(false);
        },
        child: AnimatedBuilder(animation: _flipAnim, builder: (ctx, _) {
          final front = _flipAnim.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_flipAnim.value * pi),
            child: front ? _front(color) : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _back(color)),
          );
        }),
      ),
    );
  }

  Widget _front(Color color) => _card(
    Column(mainAxisSize: MainAxisSize.min, children: [
      _badge(color), const SizedBox(height: 14),
      Text(widget.statement, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
      const SizedBox(height: 6),
      Text('← ${widget.negativeLabel}  |  ${widget.positiveLabel} →',
        style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
      const SizedBox(height: 18),
      _threeBtn(color),
    ]),
  );

  Widget _back(Color color) => _card(
    Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.backAnswer, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
      const SizedBox(height: 6),
      Text('한 번 더 눌러주세요', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      const SizedBox(height: 16),
      _threeBtn(color),
    ]),
  );

  Widget _card(Widget child) => Container(
    width: 320, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: (_flipped ? Colors.white : widget.accentColor ?? _typeColor()).withAlpha(60)),
    ),
    child: child,
  );

  Widget _threeBtn(Color color) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _circleBtn('✕', false, Colors.grey.shade600),
    const SizedBox(width: 16),
    _centerBtn(color),
    const SizedBox(width: 16),
    _circleBtn('○', true, color),
  ]);

  Widget _circleBtn(String sym, bool value, Color color) => GestureDetector(
    onTap: () => _tap(value),
    child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(20), border: Border.all(color: color.withAlpha(100), width: 2)),
      child: Center(child: Text(sym, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w300)))),
  );

  Widget _centerBtn(Color color) => GestureDetector(
    onTap: _openAsk,
    child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(8), border: Border.all(color: Colors.white.withAlpha(20))),
      child: const Center(child: Text('▲', style: TextStyle(color: Color(0xFF888888), fontSize: 18)))),
  );

  Widget _badge(Color color) {
    final icon = switch (widget.type) {
      CardType.preference => Icons.tune, CardType.reminder => Icons.alarm,
      CardType.learning => Icons.school, CardType.news => Icons.newspaper,
      CardType.checkup => Icons.favorite, CardType.askMe => Icons.chat,
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: color)]);
  }

  Color _typeColor() => switch (widget.type) {
    CardType.preference => const Color(0xFFD4A574), CardType.reminder => const Color(0xFF6AC9D4),
    CardType.learning => const Color(0xFFB088D4), CardType.news => const Color(0xFF7CCE8C),
    CardType.checkup => const Color(0xFFE8847C), CardType.askMe => const Color(0xFFB088D4),
  };

  @override
  void dispose() { _flip.dispose(); super.dispose(); }
}

void showCard(BuildContext ctx, {required CardType type, required String statement,
  required String backAnswer, String pos = '네', String neg = '아니오',
  Color? accent, void Function(int confidence)? onResult}) {
  showDialog(context: ctx, barrierColor: Colors.black.withAlpha(200), barrierDismissible: false,
    builder: (_) => ConversationCard(type: type, statement: statement, backAnswer: backAnswer,
      positiveLabel: pos, negativeLabel: neg, accentColor: accent, onResult: onResult));
}
