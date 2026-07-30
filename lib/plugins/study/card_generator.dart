import '../widgets/conversation_card.dart';

/// 🎴 Card Content Generator — Stress-Free Design
///
/// Strict rules:
/// 1. Statement MUST be easy to understand (≤10 words Korean)
/// 2. Back MUST resolve all doubt — never leave user wondering
/// 3. Back SHOULD nudge toward ○ by explaining the benefit
/// 4. Never use question words (뭐, 왜, 어떻게, 언제, 어디, 누가)
/// 5. If user picks ✕, back still provides value
class CardContentGenerator {
  static final CardContentGenerator _i = CardContentGenerator._();
  factory CardContentGenerator() => _i;
  CardContentGenerator._();

  int _idx = 0;

  // ─── English listening practice ────────────────

  static const _english = [
    ('The weather is beautiful today.', '오늘 날씨가 정말 좋네요.'),
    ('Could you repeat that?', '다시 말씀해 주시겠어요?'),
    ('I will be there in five minutes.', '5분 안에 도착할게요.'),
    ('What do you think about this?', '이것에 대해 어떻게 생각하세요?'),
    ('Let me check and get back to you.', '확인하고 다시 연락드릴게요.'),
    ('That sounds like a great idea.', '정말 좋은 생각이네요.'),
    ('I appreciate your help.', '도와주셔서 감사합니다.'),
    ('We need to discuss this further.', '이것에 대해 더 논의해야 해요.'),
  ];

  static ({String english, String korean}) nextEnglish() {
    _i._idx = (_i._idx + 1) % _english.length;
    final e = _english[_i._idx];
    return (english: e.$1, korean: e.$2);
  }

  // ─── IT/Slang terms ────────────────────────────

  static const _terms = [
    ('프롬프트 엔지니어링', 'AI에게 원하는 답을 얻기 위해 질문을 정교하게 설계하는 기술'),
    ('벡터 데이터베이스', '의미의 유사도를 숫자로 저장해 비슷한 내용을 빠르게 찾는 기술'),
    ('RAG', 'Retrieval-Augmented Generation. 외부 문서를 검색해서 AI 답변의 정확도를 높이는 방법'),
    ('파인튜닝', '기존 AI 모델을 특정 분야에 맞게 추가 학습시키는 과정'),
    ('토큰', 'AI가 텍스트를 처리하는 최소 단위. 한국어는 보통 음절 단위'),
    ('할루시네이션', 'AI가 그럴듯하지만 사실이 아닌 내용을 생성하는 현상'),
    ('임베딩', '단어나 문장의 의미를 숫자 벡터로 표현한 것'),
    ('에이전트', '스스로 판단하고 도구를 사용해 목표를 달성하는 AI 시스템'),
  ];

  static ({String term, String definition}) nextTerm() {
    _i._idx = (_i._idx + 7) % _terms.length;
    final t = _terms[_i._idx % _terms.length];
    return (term: t.$1, definition: t.$2);
  }

  // ─── News prompts ──────────────────────────────

  static const _news = [
    '오늘 AI 업계에서 큰 발표가 있었어요.',
    '새로운 오픈소스 LLM이 공개되었어요.',
    '스마트 안경 시장이 빠르게 성장하고 있어요.',
    '온디바이스 AI 기술이 점점 발전하고 있어요.',
  ];

  static String nextNews() {
    _i._idx = (_i._idx + 3) % _news.length;
    return _news[_i._idx];
  }

  // ─── Generate card data ────────────────────────

  static CardData nextCard() {
    final r = _i._idx % 4;
    return switch (r) {
      0 => _englishCard(),
      1 => _termCard(),
      2 => _newsCard(),
      _ => _englishCard(),
    };
  }

  static CardData _englishCard() {
    final e = nextEnglish();
    return CardData(
      type: CardType.learning,
      statement: '이 소리, 들리세요?',
      backAnswer: '${e.english}\n\n${e.korean}\n\n하루 한 문장씩 들으면 영어가 편해져요.',
      positiveLabel: '들려',
      negativeLabel: '안들려',
    );
  }

  static CardData _termCard() {
    final t = nextTerm();
    return CardData(
      type: CardType.learning,
      statement: '${t.term} 뜻을 아시나요?',
      backAnswer: '${t.definition}\n\n알아두면 대화할 때 유용한 표현이에요.',
      positiveLabel: '안다',
      negativeLabel: '모른다',
    );
  }

  static CardData _newsCard() {
    return CardData(
      type: CardType.news,
      statement: '오늘 AI 소식 하나 가져왔어요.',
      backAnswer: '새로운 기술은 매일 나오고 있어요. O.P도 계속 배우는 중입니다.\n\n궁금한 게 있으면 언제든 물어봐 주세요.',
      positiveLabel: '알겠다',
      negativeLabel: '나중에',
    );
  }
}

class CardData {
  final CardType type;
  final String statement;
  final String backAnswer;
  final String positiveLabel;
  final String negativeLabel;
  const CardData({required this.type, required this.statement,
      required this.backAnswer, this.positiveLabel = '네',
      this.negativeLabel = '아니오'});
}
