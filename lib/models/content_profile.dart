import '../widgets/conversation_card.dart';

/// 📚 Content Profile — 과목별 카드 구조 정의
enum ContentProfile {
  /// Type 1: Pure text. 앞면=영어, 뒷면=한국어
  text(
    mode: CardMode.content,
    showFrontText: true,
    showBackText: true,
    playAudio: false,
    description: '영어단어, 용어, 사실 암기 등',
  ),

  /// Type 2: Formula/Image. 앞면=수식, 뒷면=의미+발음텍스트
  formula(
    mode: CardMode.content,
    showFrontText: true,
    showBackText: true,
    playAudio: false, // TTS가 수식을 읽어줌 (별도 발음 텍스트 필요)
    description: '수학공식, 도표, 그림 포함',
  ),

  /// Type 3: Audio-first. 앞면=소리만, 뒷면=소리+텍스트
  audio(
    mode: CardMode.content,
    showFrontText: false, // "소리만 들으세요" 안내만 표시
    showBackText: true,
    playAudio: true,
    description: '영어듣기, 음악, 발음 훈련',
  );

  final CardMode mode;
  final bool showFrontText;
  final bool showBackText;
  final bool playAudio;
  final String description;

  const ContentProfile({
    required this.mode,
    required this.showFrontText,
    required this.showBackText,
    required this.playAudio,
    required this.description,
  });

  /// Get profile for a subject
  static ContentProfile forSubject(String subject) => switch (subject) {
    '영어' || 'english' || '일본어' || '중국어' => ContentProfile.text,
    '수학' || '과학' || '물리' || '화학' => ContentProfile.formula,
    '영어듣기' || '리스닝' || '히어링' || '발음' => ContentProfile.audio,
    _ => ContentProfile.text,
  };

  /// Front instruction text (audio mode only)
  static const audioInstruction = '소리만 들으세요.\n의미 생각하지 말고\n귀만 열어두세요.';

  /// Generate TTS-readable pronunciation for formulas
  static String formulaToSpeech(String latex) {
    return latex
        .replaceAll(r'\frac{', '분수. 분자 ')
        .replaceAll('}{', ' 분모 ')
        .replaceAll('}', '')
        .replaceAll(r'\sqrt{', '루트 ')
        .replaceAll(r'\pm', '플러스 마이너스 ')
        .replaceAll('^', '의 ')
        .replaceAll('_', ' 아래첨자 ')
        .replaceAll(r'\cdot', '곱하기 ')
        .replaceAll('=', '는 ')
        .replaceAll('+', '더하기 ')
        .replaceAll('-', '빼기 ');
  }
}
