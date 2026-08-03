import 'syncretia.dart';
import 'hygieia.dart';

/// 🎯 Clio Engine — 진로·적성·직업 컨설팅
///
/// Syncretia(성격) + Hygieia(건강) + 사용자 반응 데이터
/// → 최적의 진로와 강점을 도출.
///
/// 이름: Clio (클리오)
/// - 그리스 역사·서사시의 뮤즈
/// - "당신의 이야기를 써 내려가는 엔진"

class Clio {
  static final Clio _i = Clio._();
  factory Clio() => _i;
  Clio._();

  final Map<String, dynamic> _profile = {};
  final List<String> _pendingQuestions = [];

  // ─── Start assessment ──────────────────────────

  void start() {
    _pendingQuestions.clear();
    _pendingQuestions.addAll([
      '어떤 일을 할 때 가장 시간 가는 줄 모르나요?',
      '주변 사람들이 당신의 어떤 점을 칭찬하나요?',
      '가장 싫어하는 일이나 환경은 무엇인가요?',
      '10년 후 어떤 모습이고 싶나요?',
      '현재 가장 부족하다고 느끼는 능력은?',
      '어릴 적 꿈은 무엇이었나요?',
      '일과 삶의 균형 중 무엇이 더 중요하나요? [일] [균형] [삶]',
    ]);
  }

  String? nextQuestion() {
    if (_pendingQuestions.isEmpty) return null;
    return _pendingQuestions.removeAt(0);
  }

  void answer(String response) {
    _profile['q${_profile.length}'] = response;
  }

  bool get isComplete => _profile.length >= 5;

  // ─── Synthesize with other engines ─────────────

  Map<String, dynamic> synthesize(Syncretia syncretia, Hygieia hygieia) {
    final persona = syncretia.synthesize();
    final health = hygieia.generateReport();

    final mbti = persona['mbti']?.toString() ?? 'ENTP';
    final traits = (persona['traits'] as List?)?.cast<String>() ?? [];
    final healthRisks = (health['risks'] as List?)?.cast<String>() ?? [];

    // Career suggestions based on MBTI + traits
    final careers = <String>[];
    final strengths = <String>[];
    final cautions = <String>[];

    // MBTI-based careers
    switch (mbti) {
      case 'ENTP': careers.addAll(['스타트업 창업가','변호사','제품 기획자','컨설턴트','저널리스트']); break;
      case 'INTP': careers.addAll(['개발자','데이터 과학자','연구원','철학자','게임 디자이너']); break;
      case 'ENTJ': careers.addAll(['CEO','정치인','군 장교','투자은행가','프로젝트 매니저']); break;
      case 'INTJ': careers.addAll(['전략 컨설턴트','과학자','엔지니어','교수','건축가']); break;
      case 'ENFP': careers.addAll(['마케터','교사','상담사','작가','이벤트 플래너']); break;
      case 'INFP': careers.addAll(['심리상담사','예술가','작가','사회복지사','인사담당']); break;
      default: careers.addAll(['전문직','교육자','크리에이터','분석가','서비스업']);
    }

    // Strengths
    if (traits.contains('창의적')) strengths.add('새로운 것을 만들어내는 능력');
    if (traits.contains('리더십')) strengths.add('사람들을 이끄는 카리스마');
    if (traits.contains('논리적')) strengths.add('복잡한 문제를 분석하는 능력');
    if (traits.contains('인내심')) strengths.add('끝까지 해내는 집요함');
    if (traits.contains('직관적')) strengths.add('데이터 너머를 보는 통찰력');

    // Cautions based on health
    for (final risk in healthRisks) {
      if (risk.contains('스트레스')) cautions.add('스트레스 관리가 중요한 직군은 피하세요.');
      if (risk.contains('눈') || risk.contains('시력')) cautions.add('장시간 모니터 작업은 주의하세요.');
      if (risk.contains('소화')) cautions.add('불규칙한 식사 패턴의 직업은 피하세요.');
    }

    return {
      'careers': careers.take(3).toList(),
      'strengths': strengths,
      'cautions': cautions,
      'mbti': mbti,
      'traits': traits,
    };
  }
}

/// 🎼 Orchestra — 다중 엔진 협업 조정자
///
/// Syncretia(영혼) + Hygieia(육체) + Clio(진로) + TikiTakaBrain(학습)
/// → 종합적 컨설팅
class Orchestra {
  static final Orchestra _i = Orchestra._();
  factory Orchestra() => _i;
  Orchestra._();

  final syncretia = Syncretia();
  final hygieia = Hygieia();
  final clio = Clio();

  /// Status of all engines
  Map<String, bool> get status => {
    'Syncretia': syncretia.isComplete,
    'Hygieia': hygieia.isUseful,
    'Clio': clio.isComplete,
  };

  /// Generate comprehensive report combining all engines
  String comprehensiveReport() {
    final buf = StringBuffer();

    buf.writeln('# 🧬 당신의 종합 프로파일');
    buf.writeln();

    if (syncretia.isComplete) {
      final p = syncretia.synthesize();
      buf.writeln('## 성격·체질 (Syncretia)');
      buf.writeln('- MBTI: ${p['mbti']} — ${p['mbtiDesc']}');
      buf.writeln('- 사상체질: ${p['sasang']}');
      buf.writeln('- Ayurveda: ${p['ayurveda']}');
      buf.writeln('- 핵심 특성: ${(p['traits'] as List).join(', ')}');
      buf.writeln();
    }

    if (hygieia.isUseful) {
      final h = hygieia.generateReport();
      buf.writeln('## 건강 (Hygieia)');
      buf.writeln('- 방문 횟수: ${h['totalVisits']}회');
      if ((h['risks'] as List).isNotEmpty) {
        buf.writeln('- 위험 요소:');
        for (final r in h['risks'] as List) {
          buf.writeln('  - $r');
        }
      }
      if ((h['recommendations'] as List).isNotEmpty) {
        buf.writeln('- 추천:');
        for (final r in h['recommendations'] as List) {
          buf.writeln('  - $r');
        }
      }
      buf.writeln();
    }

    if (clio.isComplete) {
      final c = clio.synthesize(syncretia, hygieia);
      buf.writeln('## 진로 (Clio)');
      buf.writeln('- 추천 직업: ${(c['careers'] as List).join(', ')}');
      if ((c['strengths'] as List).isNotEmpty) {
        buf.writeln('- 강점: ${(c['strengths'] as List).join('. ')}');
      }
      if ((c['cautions'] as List).isNotEmpty) {
        buf.writeln('- 주의: ${(c['cautions'] as List).join('. ')}');
      }
      buf.writeln();
    }

    return buf.toString();
  }

  /// What the user should do next
  List<String> get nextSteps {
    final steps = <String>[];
    if (!syncretia.isComplete) steps.add('Syncretia 질문 ${7 - (syncretia.get('birth') != null ? 1 : 0)}개 남음');
    if (!hygieia.isUseful) steps.add('Hygieia에 건강 고민을 알려주세요');
    if (!clio.isComplete && syncretia.isComplete) steps.add('Clio 진로 상담을 시작할 수 있어요');
    return steps;
  }
}
