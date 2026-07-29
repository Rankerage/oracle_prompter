import 'package:flutter/material.dart';
import '../widgets/chip_card.dart';
import '../models/content_profile.dart';

/// 📚 Quick Subject Picker — ▲ 누르면 나오는 과목 선택
class SubjectPicker {
  static const subjects = {
    '영어': ContentProfile.text,
    '영어듣기': ContentProfile.audio,
    '수학': ContentProfile.formula,
    '신조어': ContentProfile.text,
    'IT 용어': ContentProfile.text,
    '상식': ContentProfile.text,
    '유머': ContentProfile.connection,
    '뉴스': ContentProfile.connection,
  };

  static void show(BuildContext ctx, void Function(String subject, ContentProfile profile) onPicked) {
    showChipCard(ctx,
      statement: '무엇을 공부하고 싶으세요?',
      note: '언제든 ▲로 바꿀 수 있어요',
      choices: subjects.keys.toList(),
      onChosen: (s) => onPicked(s, subjects[s]!),
    );
  }
}
