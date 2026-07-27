import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// 🃏 Conversation Card — "설정화면 대신 말 걸기"
///
/// Never uses question words. Always a recommendation statement.
/// User responds with binary choice: Yes/No, Like/Dislike, Know/Don't Know.
/// Card flips with animation to show acknowledgment.
class ConversationCard extends StatefulWidget {
  final String statement;     // "이 목소리, 마음에 드실 거예요."
  final String positiveLabel; // "좋다"
  final String negativeLabel; // "싫다"
  final Color? accentColor;
  final void Function(bool accepted)? onChoice;

  const ConversationCard({
    super.key,
    required this.statement,
    this.positiveLabel = '예',
    this.negativeLabel = '아니오',
    this.accentColor,
    this.onChoice,
  });

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _hasResponded = false;
  bool _accepted = false;
  String _acknowledgment = '';

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void _respond(bool accepted) {
    _accepted = accepted;
    _hasResponded = true;
    _acknowledgment = accepted
        ? '알겠습니다. 다음에 또 여쭤볼게요.'
        : '기억해두겠습니다. 다른 방식을 찾아볼게요.';

    HapticFeedback.lightImpact();
    _flipController.forward();
    widget.onChoice?.call(accepted);

    // Auto-dismiss after flip
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isFlipped = _flipAnimation.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * pi),
            child: _flipAnimation.value < 0.5
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final color = widget.accentColor ?? const Color(0xFFD4A574);
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [
          BoxShadow(color: color.withAlpha(20), blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // O.P icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withAlpha(180)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('O.P', style: TextStyle(
                color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 16),
          // Statement (not a question!)
          Text(widget.statement,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: 24),
          // Binary choice buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _choiceButton(widget.negativeLabel, false, Colors.grey.shade600),
              const SizedBox(width: 16),
              _choiceButton(widget.positiveLabel, true, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (_accepted
            ? const Color(0xFF7CCE8C) : Colors.orange.shade400).withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_accepted ? Icons.check_circle : Icons.refresh,
            color: _accepted ? const Color(0xFF7CCE8C) : Colors.orange.shade400, size: 36),
          const SizedBox(height: 16),
          Text(_acknowledgment,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _accepted ? const Color(0xFF7CCE8C) : Colors.orange.shade400,
              fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _choiceButton(String label, bool value, Color color) {
    return GestureDetector(
      onTap: () => _respond(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(
          color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }
}

/// Show a conversation card as overlay dialog
void showConversationCard(
  BuildContext context, {
  required String statement,
  String positiveLabel = '예',
  String negativeLabel = '아니오',
  Color? accentColor,
  void Function(bool accepted)? onChoice,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(180),
    builder: (_) => ConversationCard(
      statement: statement,
      positiveLabel: positiveLabel,
      negativeLabel: negativeLabel,
      accentColor: accentColor,
      onChoice: onChoice,
    ),
  );
}
