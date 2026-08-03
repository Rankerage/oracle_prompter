import 'markdown_vault.dart';
import 'smart_adjuster.dart';
import 'persona_engine.dart';
import 'card_factory.dart';
import 'adaptive_fsrs.dart';

/// 💡 DailyInsight — 매일 LLM이 생성하는 지능형 인사이트
///
/// 사용자에게 보여줄 인사이트 카드 + LLM에 보낼 분석 요청.
/// "이번 주 동사 정답률이 23% 올랐어요" 같은 구체적 통찰.
class DailyInsight {
  static final DailyInsight _i = DailyInsight._();
  factory DailyInsight() => _i;
  DailyInsight._();

  final _vault = MarkdownVault();
  final _adjuster = SmartAdjuster();
  final _persona = PersonaEngine();

  // ─── User-facing insights (카드로 보여줌) ──────

  List<String> generateUserInsights() {
    final insights = <String>[];

    // 1. Today's stats
    final today = _vault.dailySummary();
    if (!today.startsWith('오늘은 아직')) {
      insights.add('📊 $today');
    }

    // 2. Persona
    if (_persona.profile['totalCards'] > 10) {
      insights.add('👤 ${_persona.introduce()}');
    }

    // 3. Subject-specific analysis
    for (final s in ['영어', ' 수학', '신조어', '영어듣기']) {
      final analysis = _adjuster.analyze(s);
      if (analysis['ready'] == true) {
        final suggestion = analysis['suggestion'] as String;
        if (suggestion.isNotEmpty && suggestion != '안정적인 페이스입니다. 계속 이대로!') {
          insights.add('🎯 $suggestion');
        }
      }
    }

    // 4. Deck progress
    for (final s in ['영어', '신조어', '수학']) {
      final total = CardFactory.deckSize(s);
      final suggested = _adjuster.analyze(s);
      if (suggested['ready'] == true) {
        final bestHour = _adjuster.bestHour(s);
        final params = _adjuster.getAdjustedParams(s);
        final r = (params['retention'] as double) * 100;
        insights.add('📚 $s: ${total}장 대기 중. 최적 학습 시간: ${bestHour}시. '
            '목표 유지율: ${r.round()}%');
      }
    }

    // 5. Milestone
    final total = _persona.profile['totalCards'] as int;
    if (total >= 100 && total % 100 < 10) {
      insights.add('🎉 축하합니다! 지금까지 총 $total장을 학습하셨어요!');
    }

    return insights;
  }

  // ─── LLM Prompt Builder ────────────────────────

  String buildLLMPrompt() {
    final buf = StringBuffer();

    // System context
    buf.writeln('당신은 TikiTaka의 AI 학습 코치입니다. 사용자의 데이터를 분석하고 개인화된 조언을 제공하세요.');
    buf.writeln();

    // User persona
    buf.writeln('## 👤 사용자 프로필');
    buf.writeln(_persona.introduce());
    buf.writeln();

    // Daily vault
    buf.writeln(_vault.toMarkdown());
    buf.writeln();

    // Analysis request
    buf.writeln('## 🎯 분석 요청');
    buf.writeln('1. 사용자의 현재 학습 상태를 한 문장으로 요약하세요.');
    buf.writeln('2. 가장 시급한 조정이 필요한 과목은 무엇인가요?');
    buf.writeln('3. 내일을 위해 어떤 컨텐츠를 준비해야 할까요?');
    buf.writeln('4. 사용자에게 보여줄 동기부여 인사이트 한 줄을 작성하세요.');
    buf.writeln();
    buf.writeln('JSON 응답:');
    buf.writeln('```json');
    buf.writeln('{');
    buf.writeln('  "summary": "한 줄 요약",');
    buf.writeln('  "urgent": "시급한 과목",');
    buf.writeln('  "newContent": [{"subject": "영어", "cards": ["word meaning", ...]}],');
    buf.writeln('  "motivation": "사용자에게 보여줄 메시지",');
    buf.writeln('  "personaUpdate": {"traits": ["아침형","우등생"], "note": "..."}');
    buf.writeln('}');
    buf.writeln('```');

    return buf.toString();
  }

  /// Get today's most important insight card
  String get topInsight {
    final insights = generateUserInsights();
    return insights.isNotEmpty ? insights.first : '오늘도 수고하셨어요! 내일 또 만나요.';
  }
}
