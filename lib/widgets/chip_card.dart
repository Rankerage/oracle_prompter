import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🔘 Multi-choice chip card — stress-free profile questions
///
/// "당신의 혈액형은?" → [A] [B] [O] [AB]
/// Tap one. Done. No confirmation.
class ChipCard extends StatefulWidget {
  final String statement;          // "당신의 혈액형은?"
  final List<String> choices;      // ["A", "B", "O", "AB"]
  final String? note;              // small note: "스트레스 없이 톡톡"
  final void Function(String chosen)? onChosen;

  const ChipCard({
    super.key, required this.statement, required this.choices,
    this.note, this.onChosen,
  });

  @override
  State<ChipCard> createState() => _ChipCardState();
}

class _ChipCardState extends State<ChipCard> {
  String? _chosen;

  void _choose(String choice) {
    if (_chosen != null) return; // One tap only
    setState(() => _chosen = choice);
    HapticFeedback.selectionClick();
    widget.onChosen?.call(choice);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF8BB8EA).withAlpha(50)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.statement, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          if (widget.note != null) ...[
            const SizedBox(height: 4),
            Text(widget.note!, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: widget.choices.map((c) => _chip(c)).toList()),
          if (_chosen != null) ...[
            const SizedBox(height: 12),
            Text(_chosen!, style: const TextStyle(color: Color(0xFF8BB8EA), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ]),
      ),
    );
  }

  Widget _chip(String label) {
    final selected = _chosen == label;
    return GestureDetector(
      onTap: () => _choose(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8BB8EA).withAlpha(30) : Colors.white.withAlpha(6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected
              ? const Color(0xFF8BB8EA) : Colors.white.withAlpha(15), width: selected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(
            color: selected ? const Color(0xFF8BB8EA) : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
      ),
    );
  }
}

/// Built-in profile chips
enum ProfileChip {
  name('이름이 어떻게 되세요?', null, false),
  age('나이는 어떻게 되세요?', ['10대', '20대', '30대', '40대', '50대', '60대+'], true),
  bloodType('혈액형은 어떻게 되세요?', ['A', 'B', 'O', 'AB'], true),
  job('직업은 어떻게 되세요?', ['학생', '회사원', '자영업', '전문직', '기타'], true),
  hobby('취미는 어떻게 되세요?', ['운동', '독서', '게임', '음악', '여행', '요리'], true),
  wakeTime('보통 몇 시에 일어나세요?', ['6시 이전', '6~8시', '8~10시', '10시 이후'], true),
  learningGoal('주로 무엇을 배우고 싶으세요?', ['외국어', 'IT/기술', '상식/교양', '업무 스킬'], true),
  ;

  final String statement;
  final List<String>? choices;
  final bool isChip; // true = chip card, false = OX card

  const ProfileChip(this.statement, this.choices, this.isChip);
}

/// Show chip card
void showChipCard(BuildContext ctx, {
  required String statement, required List<String> choices,
  String? note, void Function(String)? onChosen,
}) {
  showDialog(context: ctx, barrierColor: Colors.black.withAlpha(180),
    builder: (_) => ChipCard(statement: statement, choices: choices,
        note: note, onChosen: onChosen));
}
