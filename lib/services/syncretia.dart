import 'dart:math';
import 'mystic_deck.dart';

/// 🧬 Syncretia Engine — 인류 지혜 합성 엔진
///
/// 사주·별자리·MBTI·사상체질·8체질·혈액형·Enneagram·Ayurveda...
/// 모든 분류 체계를 하나의 페르소나로 합성.
class Syncretia {
  static final Syncretia _i = Syncretia._();
  factory Syncretia() => _i;
  Syncretia._();

  final _rng = Random();

  // ─── User Profile ──────────────────────────────

  final Map<String, dynamic> _profile = {};

  /// Set a profile value (called once during initial questionnaire)
  void set(String key, dynamic value) => _profile[key] = value;

  dynamic get(String key) => _profile[key];

  bool get isComplete => _profile.length >= 5; // Minimum: birth, blood, MBTI, 체질, Ayurveda

  // ─── Questionnaire ─────────────────────────────

  /// Generate the next question (card-based)
  String? nextQuestion() {
    if (_profile['birth'] == null) return '태어난 연도와 월, 일을 알려주세요. (예: 1990년 3월 15일)';
    if (_profile['blood'] == null) return '혈액형이 어떻게 되세요? [A] [B] [O] [AB]';
    if (_profile['mbti_ei'] == null) return '사람들과 함께 있을 때 에너지를 얻나요,\n혼자 있을 때 충전되나요?';
    if (_profile['mbti_sn'] == null) return '구체적인 사실에 관심이 있나요,\n아이디어와 가능성에 끌리나요?';
    if (_profile['mbti_tf'] == null) return '의사 결정할 때 논리를 따르나요,\n감정과 가치를 따르나요?';
    if (_profile['mbti_jp'] == null) return '계획대로 하는 걸 좋아하나요,\n즉흥적으로 하는 걸 좋아하나요?';
    if (_profile['sasang'] == null) {
      return '다음 중 어떤 체형에 가깝나요?\n[상체발달] [하체발달] [균형] [마른편]';
    }
    if (_profile['ayurveda'] == null) {
      return '몸과 마음의 특징을 골라주세요:\n[가볍고 건조] [뜨겁고 예민] [무겁고 안정]';
    }
    if (_profile['chronotype'] == null) {
      return '가장 집중이 잘 되는 시간대는?\n[아침 6-9시] [오전 10-12시] [오후 2-5시] [밤 9-12시]';
    }
    return null; // All done
  }

  /// Process questionnaire answer
  void answer(String response) {
    final r = response.trim();

    if (_profile['birth'] == null) {
      _profile['birth'] = r;
      return;
    }
    if (_profile['blood'] == null) {
      if (r.contains('A')) _profile['blood'] = 'A';
      else if (r.contains('B')) _profile['blood'] = 'B';
      else if (r.contains('O')) _profile['blood'] = 'O';
      else if (r.contains('AB')) _profile['blood'] = 'AB';
      else _profile['blood'] = r;
      return;
    }
    if (_profile['mbti_ei'] == null) {
      _profile['mbti_ei'] = r.contains('함께') || r.contains('에너지') ? 'E' : 'I';
      return;
    }
    if (_profile['mbti_sn'] == null) {
      _profile['mbti_sn'] = r.contains('사실') || r.contains('구체') ? 'S' : 'N';
      return;
    }
    if (_profile['mbti_tf'] == null) {
      _profile['mbti_tf'] = r.contains('논리') || r.contains('논') ? 'T' : 'F';
      return;
    }
    if (_profile['mbti_jp'] == null) {
      _profile['mbti_jp'] = r.contains('계획') ? 'J' : 'P';
      return;
    }
    if (_profile['sasang'] == null) {
      if (r.contains('상체')) _profile['sasang'] = '태양인';
      else if (r.contains('하체')) _profile['sasang'] = '소음인';
      else if (r.contains('균형')) _profile['sasang'] = '태음인';
      else if (r.contains('마른')) _profile['sasang'] = '소양인';
      else _profile['sasang'] = r;
      return;
    }
    if (_profile['ayurveda'] == null) {
      if (r.contains('가볍') || r.contains('건조')) _profile['ayurveda'] = 'Vata';
      else if (r.contains('뜨겁') || r.contains('예민')) _profile['ayurveda'] = 'Pitta';
      else if (r.contains('무겁') || r.contains('안정')) _profile['ayurveda'] = 'Kapha';
      else _profile['ayurveda'] = r;
      return;
    }
    if (_profile['chronotype'] == null) {
      _profile['chronotype'] = r;
      return;
    }
  }

  // ─── MBTI ──────────────────────────────────────

  String get mbti {
    final ei = _profile['mbti_ei'] ?? 'E';
    final sn = _profile['mbti_sn'] ?? 'N';
    final tf = _profile['mbti_tf'] ?? 'T';
    final jp = _profile['mbti_jp'] ?? 'P';
    return '$ei$sn$tf$jp';
  }

  String get mbtiDescription {
    return switch (mbti) {
      'ENTP' => '혁신적 토론가. 아이디어 폭발. 변화 추구.',
      'INTP' => '논리적 사색가. 깊은 분석. 호기심.',
      'ENTJ' => '대담한 지휘관. 목표 지향. 결단력.',
      'INTJ' => '전략적 설계자. 비전. 독립적.',
      'ENFP' => '열정적 활동가. 가능성. 인간관계.',
      'INFP' => '이상주의자. 가치 중심. 창의적.',
      'ENFJ' => '카리스마 조력자. 공감. 영감.',
      'INFJ' => '통찰력 있는 조언자. 직관. 헌신.',
      'ESTP' => '모험적 사업가. 행동파. 현실적.',
      'ISTP' => '장인. 손재주. 문제해결.',
      'ESTJ' => '체계적 관리자. 규칙. 책임.',
      'ISTJ' => '원칙주의자. 신뢰. 철저함.',
      'ESFP' => '즉흥적 연예인. 활력. 즐거움.',
      'ISFP' => '예술가. 감성. 현재.',
      'ESFJ' => '사교적 봉사자. 배려. 조화.',
      'ISFJ' => '헌신적 수호자. 세심. 인내.',
      _ => mbti,
    };
  }

  // ─── Synthesis ─────────────────────────────────

  /// The merged persona
  Map<String, dynamic> synthesize() {
    if (!isComplete) return {'ready': false};

    final blood = _profile['blood'] as String? ?? '?';
    final sasang = _profile['sasang'] as String? ?? '?';
    final ayurveda = _profile['ayurveda'] as String? ?? '?';

    // Collect traits from all systems
    final traits = <String, int>{};

    // Blood type traits
    switch (blood) {
      case 'A': traits['꼼꼼함'] = 2; traits['내향적'] = 1; break;
      case 'B': traits['자유로움'] = 2; traits['창의적'] = 1; break;
      case 'O': traits['리더십'] = 2; traits['외향적'] = 1; break;
      case 'AB': traits['이중적'] = 2; traits['독특함'] = 1; break;
    }

    // MBTI traits
    if (mbti.contains('E')) traits['외향적'] = (traits['외향적'] ?? 0) + 2;
    if (mbti.contains('I')) traits['내향적'] = (traits['내향적'] ?? 0) + 2;
    if (mbti.contains('N')) traits['직관적'] = (traits['직관적'] ?? 0) + 2;
    if (mbti.contains('T')) traits['논리적'] = (traits['논리적'] ?? 0) + 2;
    if (mbti.contains('F')) traits['감성적'] = (traits['감성적'] ?? 0) + 2;

    // Sasang traits
    switch (sasang) {
      case '태양인': traits['활동적'] = 3; traits['열정적'] = 3; break;
      case '소양인': traits['민첩함'] = 3; traits['예민함'] = 2; break;
      case '태음인': traits['안정적'] = 3; traits['인내심'] = 3; break;
      case '소음인': traits['섬세함'] = 3; traits['신중함'] = 2; break;
    }

    // Ayurveda traits
    switch (ayurveda) {
      case 'Vata': traits['창의적'] = (traits['창의적'] ?? 0) + 2; traits['가벼움'] = 2; break;
      case 'Pitta': traits['열정적'] = (traits['열정적'] ?? 0) + 2; traits['리더십'] = (traits['리더십'] ?? 0) + 1; break;
      case 'Kapha': traits['인내심'] = (traits['인내심'] ?? 0) + 2; traits['안정적'] = (traits['안정적'] ?? 0) + 2; break;
    }

    // Top traits
    final sorted = traits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTraits = sorted.take(3).map((e) => e.key).toList();

    // Health notes
    final health = <String>[];
    if (sasang == '소양인' || ayurveda == 'Pitta') health.add('열이 많은 체질. 찬 음식·수영 추천.');
    if (sasang == '소음인' || ayurveda == 'Vata') health.add('찬 기운에 약함. 따뜻한 음식·족욕 추천.');
    if (blood == 'A' || blood == 'AB') health.add('스트레스 관리 중요. 명상 추천.');

    // Learning style
    String learningStyle = '청각형';
    if (traits['직관적'] != null && traits['직관적']! >= 2) learningStyle = '개념형';
    if (traits['활동적'] != null && traits['활동적']! >= 2) learningStyle = '체험형';

    // Best time to study
    final chrono = _profile['chronotype']?.toString() ?? '오전';
    String bestTime = chrono.contains('아침') || chrono.contains('오전') ? '아침 8시' :
        chrono.contains('오후') ? '오후 3시' : '저녁 9시';

    return {
      'ready': true,
      'name': '${topTraits.join(' ')} ${mbti}',
      'traits': topTraits,
      'mbti': mbti,
      'mbtiDesc': mbtiDescription,
      'sasang': sasang,
      'ayurveda': ayurveda,
      'blood': blood,
      'health': health,
      'learningStyle': learningStyle,
      'bestTime': bestTime,
      'biorhythm': MysticDeck().todaysBiorhythm(_parseBirth()),
    };
  }

  DateTime _parseBirth() {
    final s = _profile['birth']?.toString() ?? '2000-01-01';
    return DateTime.tryParse(s.replaceAll('년','-').replaceAll('월','-').replaceAll('일','')) ?? DateTime(2000);
  }

  // ─── LLM Prompt ───────────────────────────────

  String buildLLMPrompt() {
    final s = synthesize();
    if (!(s['ready'] as bool)) return '';

    return '''
## 🧬 Syncretia Persona

**MBTI**: ${s['mbti']} — ${s['mbtiDesc']}
**사상체질**: ${s['sasang']}
**Ayurveda**: ${s['ayurveda']}
**혈액형**: ${s['blood']}
**핵심 특성**: ${(s['traits'] as List).join(', ')}

**건강 조언**: ${(s['health'] as List).join('\n')}
**학습 스타일**: ${s['learningStyle']}
**최적 학습 시간**: ${s['bestTime']}

**분석 요청**:
1. 이 사용자에게 어떤 컨텐츠를 추천할까요?
2. 어떤 시간대에 어떤 과목을 추천할까요?
3. 특별히 주의해야 할 건강 조언은?
4. 이 페르소나를 설명하는 한 줄을 만들어주세요.

JSON 응답.
''';
  }
}
