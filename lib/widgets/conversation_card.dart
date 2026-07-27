import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// Card types for different purposes
enum CardType {
  preference,  // "이 목소리 어떠세요?" → 사용자 취향
  reminder,    // "오후 3시 약속 잊지 않으셨죠?" → 알림
  learning,    // "Geek이 무슨 뜻인지 아세요?" → 지식
  news,        // "오늘 AI 큰 뉴스 있었어요." → 정보
  checkup,     // "지금 기분 어떠세요?" → 감정 체크
}

/// 🃏 Universal Conversation Card
///
/// Front: Statement (never a question word)
/// Back: Always shows answer/explanation regardless of choice
/// Voice: Reads statement aloud, listens for "yes/no" response
class ConversationCard extends StatefulWidget {
  final CardType type;
  final String statement;      // Front text
  final String backAnswer;     // Back explanation (always shown)
  final String positiveLabel;
  final String negativeLabel;
  final Color? accentColor;
  final void Function(bool accepted, CardType type)? onChoice;
  final VoidCallback? onDismiss;
  final bool speakAloud;       // Read statement via TTS

  const ConversationCard({
    super.key,
    required this.type,
    required this.statement,
    required this.backAnswer,
    this.positiveLabel = '네',
    this.negativeLabel = '아니오',
    this.accentColor,
    this.onChoice,
    this.onDismiss,
    this.speakAloud = true,
  });

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flip;
  late Animation<double> _flipAnim;
  bool _flipped = false;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flip, curve: Curves.easeInOut));

    // Auto-speak statement after 300ms
    if (widget.speakAloud) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // TTS would speak here: widget.statement
        }
      });
    }
  }

  void _respond(bool accepted) {
    _accepted = accepted;
    HapticFeedback.lightImpact();
    _flip.forward();
    setState(() => _flipped = true);
    widget.onChoice?.call(accepted, widget.type);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (!_flipped) {
            if (details.primaryVelocity! > 50) _respond(true);
            else if (details.primaryVelocity! < -50) _respond(false);
          }
        },
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (context, child) {
            final isFront = _flipAnim.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnim.value * pi),
              child: isFront ? _buildFront() : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: _buildBack(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    final color = widget.accentColor ?? _typeColor(widget.type);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 24)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _typeBadge(),
          const SizedBox(height: 16),
          Text(widget.statement, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: 8),
          Text('← ${widget.negativeLabel}  |  ${widget.positiveLabel} →\n(swipe or tap)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _choiceBtn(widget.negativeLabel, false, Colors.grey.shade600),
            const SizedBox(width: 20),
            _choiceBtn(widget.positiveLabel, true, color),
          ]),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (_accepted
            ? const Color(0xFF7CCE8C) : Colors.grey.shade600).withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.backAnswer, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Text(widget.type == CardType.learning ? '이해하셨나요?' : '기억해두겠습니다.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _typeBadge() {
    final (icon, label) = switch (widget.type) {
      CardType.preference => (Icons.tune, '취향'),
      CardType.reminder   => (Icons.alarm, '알림'),
      CardType.learning   => (Icons.school, '학습'),
      CardType.news       => (Icons.newspaper, '소식'),
      CardType.checkup    => (Icons.favorite, '체크'),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: _typeColor(widget.type)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
          color: _typeColor(widget.type), fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _choiceBtn(String label, bool value, Color color) {
    return GestureDetector(
      onTap: () => _respond(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Color _typeColor(CardType type) => switch (type) {
    CardType.preference => const Color(0xFFD4A574),
    CardType.reminder   => const Color(0xFF6AC9D4),
    CardType.learning   => const Color(0xFFB088D4),
    CardType.news       => const Color(0xFF7CCE8C),
    CardType.checkup    => const Color(0xFFE8847C),
  };

  @override
  void dispose() { _flip.dispose(); super.dispose(); }
}

/// Show card as overlay dialog
void showCard(
  BuildContext context, {
  required CardType type,
  required String statement,
  required String backAnswer,
  String positive = '네', String negative = '아니오',
  Color? accentColor,
  void Function(bool accepted, CardType type)? onChoice,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(200),
    barrierDismissible: false,
    builder: (_) => ConversationCard(
      type: type, statement: statement, backAnswer: backAnswer,
      positiveLabel: positive, negativeLabel: negative,
      accentColor: accentColor, onChoice: onChoice, onDismiss: onDismiss,
    ),
  );
}
