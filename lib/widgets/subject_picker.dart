import 'package:flutter/material.dart';
import '../widgets/chip_card.dart';
import '../widgets/conversation_card.dart';
import '../widgets/ask_me_card.dart';
import '../models/content_profile.dart';

/// 📚 Subject Picker — 칩 선택 + 직접 입력
class SubjectPicker {
  static const _suggestions = ['영어', '영어듣기', '수학', '신조어', 'IT 용어', '상식', '유머', '뉴스'];

  /// Blocked subjects
  static const _blocked = ['음담패설', '19금', '성인', '도박', '마약', '폭력'];

  static void show(BuildContext ctx, void Function(String subject, ContentProfile profile) onPicked) {
    final allChoices = [..._suggestions, '직접 입력...'];

    showChipCard(ctx,
      statement: '무엇을 공부하고 싶으세요?',
      note: '목록에 없으면 직접 입력할 수 있어요',
      choices: allChoices,
      onChosen: (s) {
        if (s == '직접 입력...') {
          _showTextInput(ctx, onPicked);
        } else if (_blocked.contains(s)) {
          _showRefusal(ctx, s);
        } else {
          onPicked(s, ContentProfile.forSubject(s));
        }
      },
    );
  }

  static void _showTextInput(BuildContext ctx, void Function(String, ContentProfile) onPicked) {
    // Show ask-me card for free text input
    showAskMeCard(ctx, onSubmit: (text) {
      if (_blocked.any((b) => text.contains(b))) {
        _showRefusal(ctx, text);
      } else {
        onPicked(text, ContentProfile.forSubject(text));
      }
    });
  }

  static void _showRefusal(BuildContext ctx, String requested) {
    showCard(ctx,
      type: CardType.preference,
      statement: '그런 내용은 도와드릴 수 없어요.',
      backAnswer: '대신 재미있는 유머나 상식을 추천해드릴까요?\n\nTikiTaka는 모든 사람을 위한 학습 동반자예요.',
      pos: '유머 보기', neg: '다른 과목',
      onResult: (c) {
        if (c >= 1) {
          // Show humor card instead
        }
      },
    );
  }
}
