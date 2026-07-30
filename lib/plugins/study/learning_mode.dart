import 'package:flutter/material.dart';
import '../widgets/conversation_card.dart';

/// 📚 Topic Learning Mode — triggered by ▲ commands
///
/// "신조어 암기 도와줘" → 신조어 모드 진입
/// "영어 공부 시작해"     → 영어 모드 진입
///
/// Works like Leitner flashcard deck focused on one topic.
/// Cards keep coming until user says "그만" or presses ▼.
class LearningMode {
  final String _topic;
  final List<_Flashcard> _cards;
  int _index = 0;
  int _correct = 0;
  int _total = 0;
  bool _active = true;
  final Map<String, int> _leitner = {};
  bool _generating = false; // 백그라운드 생성 중

  // ─── Start with first few cards, generate more in background ──

  static Future<LearningMode> start(String topic, {Future<List<_Flashcard>> Function()? generate}) async {
    // 즉시 보여줄 기초 카드
    final seed = _seedCards(topic);
    final mode = LearningMode._(topic, seed);

    // 백그라운드에서 추가 카드 생성
    if (generate != null) {
      mode._generating = true;
      generate().then((newCards) {
        mode._cards.addAll(newCards);
        mode._generating = false;
      });
    }

    return mode;
  }

  static List<_Flashcard> _seedCards(String topic) {
    return switch (topic) {
      '신조어' => _slangCards.take(4).toList(),
      'IT' => _itCards.take(3).toList(),
      '영어' => _englishCards.take(3).toList(),
      _ => _generalCards,
    };
  }

  // ─── Get next card ─────────────────────────────

  _Flashcard? nextCard() {
    if (!_active || _cards.isEmpty) return null;

    // Filter by Leitner box (box 5 = mastered, skip)
    final candidates = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      final box = _leitner[_cards[i].question] ?? 1;
      if (box < 5) candidates.add(i);
    }

    if (candidates.isEmpty) {
      _active = false;
      return null; // All mastered!
    }

    _index = candidates[_total % candidates.length];
    _total++;
    return _cards[_index];
  }

  // ─── Record response ───────────────────────────

  void record(bool correct) {
    final card = _cards[_index];
    final box = _leitner[card.question] ?? 1;

    if (correct) {
      _correct++;
      _leitner[card.question] = (box + 1).clamp(1, 5);
    } else {
      _leitner[card.question] = (box - 1).clamp(1, 5);
    }
  }

  // ─── Stats ─────────────────────────────────────

  bool get isActive => _active;
  bool get allMastered => !_active && _total > 0;
  double get accuracy => _total > 0 ? _correct / _total : 0;
  String get topic => _topic;
  bool get isGenerating => _generating;
  int get cardCount => _cards.length;

  String get summary =>
      '$_topic 학습 결과\n'
      '정답률: ${(_correct * 100 / _total).round()}%\n'
      '학습 카드: $_total장\n'
      '완전 학습: ${_leitner.values.where((b) => b >= 5).length}장';

  void stop() => _active = false;
}

// ─── Card data ───────────────────────────────────

class _Flashcard {
  final String question;
  final String answer;
  const _Flashcard(this.question, this.answer);
}

const _slangCards = [
  _Flashcard('가심비', '가격 대비 심리적 만족도. 비싸도 마음이 편하면 OK.'),
  _Flashcard('스불재', '스스로 불러온 재앙. 내가 만든 문제.'),
  _Flashcard('중꺾마', '중간에 꺾여도 마음만은. 포기하지 않는 정신.'),
  _Flashcard('킹받다', 'King + 받다. 매우 화가 난 상태.'),
  _Flashcard('억텐', '억지 텐션. 억지로 분위기 띄우기.'),
  _Flashcard('갑분싸', '갑자기 분위기 싸해짐. 대화 맥 끊김.'),
  _Flashcard('TMI', 'Too Much Information. 굳이 안 알려줘도 될 정보.'),
  _Flashcard('JMT', '존맛탱. 매우 맛있다는 뜻.'),
];

const _itCards = [
  _Flashcard('프롬프트 엔지니어링', 'AI에게 원하는 답을 얻기 위해 질문을 정교하게 설계하는 기술'),
  _Flashcard('RAG', '외부 문서를 검색해 AI 답변의 정확도를 높이는 방법'),
  _Flashcard('벡터DB', '의미 유사도를 숫자로 저장해 빠르게 검색하는 데이터베이스'),
  _Flashcard('파인튜닝', '기존 AI 모델을 특정 분야에 맞게 추가 학습시키는 과정'),
];

const _englishCards = [
  _Flashcard('Could you repeat that?', '다시 말씀해 주시겠어요?'),
  _Flashcard('I will be there in five minutes.', '5분 안에 도착할게요.'),
  _Flashcard('Let me check and get back to you.', '확인하고 다시 연락드릴게요.'),
  _Flashcard('That sounds like a great idea.', '정말 좋은 생각이네요.'),
];

const _generalCards = [
  _Flashcard('새로운 것을 배우는 중이에요', '곧 더 다양한 주제를 준비할게요.'),
];
