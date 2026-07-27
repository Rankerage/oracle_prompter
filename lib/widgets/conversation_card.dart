import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card types
enum CardType { preference, reminder, learning, news, checkup }

/// 🃏 Double-Tap Conversation Card
///
/// Flow:
/// 1. Front: statement + [No] [Yes]
/// 2. Tap → flip to Back: answer shown, buttons still there
/// 3. Tap again → 2nd response recorded, card dismisses
///
/// Two responses provide confidence level:
///   Yes→Yes = confident   | Yes→No = unsure
///   No→No  = confident    | No→Yes = learning
class ConversationCard extends StatefulWidget {
  final CardType type;
  final String statement;
  final String backAnswer;
  final String positiveLabel;
  final String negativeLabel;
  final Color? accentColor;
  final bool speakAloud;
  final void Function(int confidence)? onResult;
  // confidence: +2 (Yes→Yes), +1 (No→Yes), -1 (Yes→No), -2 (No→No)

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
  int? _firstChoice; // null, 0=no, 1=yes
  int? _secondChoice;
  bool _audioPlayed = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(duration: const Duration(milliseconds: 450), vsync: this);
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flip, curve: Curves.easeInOut));
  }

  void _tap(bool accepted) {
    HapticFeedback.selectionClick();
    if (!_flipped) {
      // First tap: flip card, show answer
      _firstChoice = accepted ? 1 : 0;
      _flip.forward();
      setState(() => _flipped = true);
      // Replay audio on back for learning cards
      if (widget.type == CardType.learning) _audioPlayed = false;
    } else {
      // Second tap: record confidence, dismiss
      _secondChoice = accepted ? 1 : 0;
      final confidence = _calcConfidence();
      widget.onResult?.call(confidence);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  int _calcConfidence() {
    // +2: Yes→Yes (strong positive)
    // +1: No→Yes  (learned)
    // -1: Yes→No  (unsure)
    // -2: No→No   (strong negative)
    if (_firstChoice == 1 && _secondChoice == 1) return 2;
    if (_firstChoice == 0 && _secondChoice == 1) return 1;
    if (_firstChoice == 1 && _secondChoice == 0) return -1;
    return -2;
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
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (context, child) {
            final showFront = _flipAnim.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnim.value * pi),
              child: showFront ? _buildFront(color) : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: _buildBack(color),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront(Color color) {
    return Container(
      width: 320, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 24)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _badge(color),
        const SizedBox(height: 14),
        Text(widget.statement, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 6),
        Text('← ${widget.negativeLabel}  |  ${widget.positiveLabel} →',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(widget.negativeLabel, false, Colors.grey.shade600),
          const SizedBox(width: 20),
          _btn(widget.positiveLabel, true, color),
        ]),
      ]),
    );
  }

  Widget _buildBack(Color color) {
    return Container(
      width: 320, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Answer text
        Text(widget.backAnswer, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        const SizedBox(height: 6),
        Text(_secondPrompt(),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 16),
        // Same buttons still present
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(widget.negativeLabel, false, Colors.grey.shade600),
          const SizedBox(width: 20),
          _btn(widget.positiveLabel, true, color),
        ]),
      ]),
    );
  }

  String _secondPrompt() {
    if (_firstChoice == 1) return '한 번 더 눌러주세요.';
    return '다시 한 번 확인해주세요.';
  }

  Widget _btn(String label, bool value, Color color) {
    return GestureDetector(
      onTap: () => _tap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _badge(Color color) {
    final (icon, label) = switch (widget.type) {
      CardType.preference => (Icons.tune, ''),
      CardType.reminder   => (Icons.alarm, ''),
      CardType.learning   => (Icons.school, ''),
      CardType.news       => (Icons.newspaper, ''),
      CardType.checkup    => (Icons.favorite, ''),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
    ]);
  }

  Color _typeColor() => switch (widget.type) {
    CardType.preference => const Color(0xFFD4A574),
    CardType.reminder   => const Color(0xFF6AC9D4),
    CardType.learning   => const Color(0xFFB088D4),
    CardType.news       => const Color(0xFF7CCE8C),
    CardType.checkup    => const Color(0xFFE8847C),
  };

  @override
  void dispose() { _flip.dispose(); super.dispose(); }
}

void showCard(BuildContext context, {
  required CardType type, required String statement,
  required String backAnswer, String pos = '네', String neg = '아니오',
  Color? accent, void Function(int confidence)? onResult,
}) {
  showDialog(
    context: context, barrierColor: Colors.black.withAlpha(200),
    barrierDismissible: false,
    builder: (_) => ConversationCard(
      type: type, statement: statement, backAnswer: backAnswer,
      positiveLabel: pos, negativeLabel: neg,
      accentColor: accent, onResult: onResult,
    ),
  );
}
