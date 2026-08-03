/// 🏥 Hygieia Engine — 평생 건강 문진 시스템
///
/// 현대의학 + 한의학 통합 건강 프로파일.
/// 카드 인터페이스로 문진 → 3년 축적 → 개인 DNA.
///
/// 이름: Hygieia (히기에이아)
/// - 그리스 건강의 여신, 의신 아스클레피오스의 딸
/// - "예방이 치료보다 낫다"의 화신
/// - Syncretia(영혼) + Hygieia(육체) = 완전한 인간

class Hygieia {
  static final Hygieia _i = Hygieia._();
  factory Hygieia() => _i;
  Hygieia._();

  // ─── Health Profile ────────────────────────────

  final Map<String, dynamic> _profile = {};
  final List<Map<String, dynamic>> _history = []; // symptom history
  final List<String> _pendingQuestions = [];
  String _currentComplaint = '';

  // ─── Symptom entry point ───────────────────────

  /// User says "눈이 잘 안 보인다" → this generates follow-up questions
  void reportSymptom(String complaint) {
    _currentComplaint = complaint;
    _pendingQuestions.clear();
    _history.add({'date': DateTime.now(), 'complaint': complaint, 'answers': []});

    // Generate questions based on the complaint
    if (complaint.contains('눈') || complaint.contains('시력')) {
      _pendingQuestions.addAll([
        '언제부터 증상이 시작되었나요? [며칠전] [몇주전] [몇달전] [1년이상]',
        '어떤 느낌인가요? [흐릿함] [겹쳐보임] [빛번짐] [통증동반]',
        '한쪽 눈인가요, 양쪽 눈인가요?',
        '두통이나 어지러움이 함께 있나요?',
        '당뇨나 고혈압 진단을 받은 적이 있나요?',
        '스마트폰이나 컴퓨터를 하루 몇 시간 보나요?',
        '가족 중에 녹내장이나 백내장 환자가 있나요?',
      ]);
    } else if (complaint.contains('머리') || complaint.contains('두통')) {
      _pendingQuestions.addAll([
        '어느 부위가 아픈가요? [관자놀이] [뒷머리] [한쪽] [전체]',
        '어떤 종류의 통증인가요? [욱신거림] [찌르는듯] [무거운느낌] [박동성]',
        '언제 주로 발생하나요? [아침] [오후] [밤] [스트레스시]',
        '메스꺼움이나 구토가 동반되나요?',
        '빛이나 소리에 민감해지나요?',
        '수면 시간은 충분한가요? 하루 몇 시간?',
        '카페인 섭취량은 어느 정도인가요?',
      ]);
    } else if (complaint.contains('소화') || complaint.contains('속') || complaint.contains('배')) {
      _pendingQuestions.addAll([
        '어디가 불편한가요? [명치] [아랫배] [옆구리] [전체]',
        '식사와 관련이 있나요? [식후] [공복시] [관계없음]',
        '어떤 느낌인가요? [더부룩함] [쓰림] [경련] [가스]',
        '대변 상태는 어떤가요? [정상] [설사] [변비] [번갈아]',
        '어떤 음식을 먹으면 더 불편한가요?',
        '스트레스와 관련이 있다고 느끼시나요?',
        '체중 변화가 있었나요?',
      ]);
    } else if (complaint.contains('잠') || complaint.contains('수면') || complaint.contains('불면')) {
      _pendingQuestions.addAll([
        '잠들기 어려운가요, 깨는 것이 문제인가요?',
        '평균 몇 시간 주무시나요?',
        '잠들기까지 얼마나 걸리나요?',
        '밤에 몇 번 정도 깨나요?',
        '낮에 졸음이 오나요?',
        '코골이나 무호흡 증상이 있나요?',
        '카페인 섭취 시간대가 언제인가요?',
      ]);
    } else {
      // General screening
      _pendingQuestions.addAll([
        '언제부터 증상이 있었나요?',
        '증상의 강도는 어느 정도인가요? [약함] [보통] [심함]',
        '다른 증상이 함께 있나요?',
        '과거에 비슷한 증상이 있었나요?',
        '현재 복용 중인 약이 있나요?',
        '최근에 스트레스가 심했나요?',
      ]);
    }
  }

  /// Get the next question (null = done)
  String? nextQuestion() {
    if (_pendingQuestions.isEmpty) return null;
    return _pendingQuestions.removeAt(0);
  }

  /// Record answer to current question
  void answer(String response) {
    if (_history.isNotEmpty) {
      final current = _history.last;
      (current['answers'] as List).add(response);
    }
  }

  // ─── Health Summary ────────────────────────────

  Map<String, dynamic> generateReport() {
    final report = <String, dynamic>{};

    // Risk assessment based on accumulated answers
    final risks = <String>[];
    final recommendations = <String>[];

    for (final entry in _history) {
      final complaint = entry['complaint'] as String;
      final answers = entry['answers'] as List;

      // Eye-related
      if (complaint.contains('눈')) {
        if (answers.any((a) => a.toString().contains('흐릿'))) {
          risks.add('시력 저하 가능성. 안과 검진 권장.');
          recommendations.add('루테인·오메가3 섭취. 20-20-20 규칙 실천.');
        }
        if (answers.any((a) => a.toString().contains('당뇨'))) {
          risks.add('당뇨망막병증 위험. 정기 안저검사 필수.');
        }
        if (answers.any((a) => a.toString().contains('스마트폰') || a.toString().contains('컴퓨터'))) {
          recommendations.add('블루라이트 차단 안경. 1시간마다 5분 휴식.');
        }
      }

      // Headache
      if (complaint.contains('두통') || complaint.contains('머리')) {
        if (answers.any((a) => a.toString().contains('스트레스'))) {
          risks.add('긴장성 두통 가능성.');
          recommendations.add('견갑근 스트레칭. 명상·심호흡.');
        }
        if (answers.any((a) => a.toString().contains('카페인'))) {
          recommendations.add('카페인 섭취량 점검. 오후 2시 이후 금지.');
        }
      }

      // Digestion
      if (complaint.contains('소화') || complaint.contains('속')) {
        if (answers.any((a) => a.toString().contains('스트레스'))) {
          risks.add('스트레스성 소화불량 가능성.');
          recommendations.add('식사 30분 전 따뜻한 물. 천천히 식사.');
        }
        if (answers.any((a) => a.toString().contains('쓰림'))) {
          risks.add('위산 과다 가능성. 위염·역류성 식도염 주의.');
          recommendations.add('과식 금지. 취침 3시간 전 식사 완료.');
        }
      }
    }

    // 한의학적 해석 추가
    final tcm = _koreanMedicineView();

    report['risks'] = risks;
    report['recommendations'] = recommendations;
    report['tcm'] = tcm;
    report['totalVisits'] = _history.length;
    report['firstComplaint'] = _history.isNotEmpty ? _history.first['complaint'] : '';

    return report;
  }

  /// 한의학 기반 해석
  Map<String, String> _koreanMedicineView() {
    final tcm = <String, String>{};

    for (final entry in _history) {
      final answers = entry['answers'] as List;

      // 간(肝) 관련: 눈, 두통, 스트레스
      if (answers.any((a) => a.toString().contains('눈')) ||
          answers.any((a) => a.toString().contains('스트레스'))) {
        tcm['간(肝)'] = '눈 건강과 연결. 스트레스 조절 필요. 결명자차 추천.';
      }

      // 심(心) 관련: 불면, 불안
      if (answers.any((a) => a.toString().contains('잠')) ||
          answers.any((a) => a.toString().contains('불면'))) {
        tcm['심(心)'] = '수면과 정신 건강. 산조인차·연꽃차 추천.';
      }

      // 비위(脾胃) 관련: 소화
      if (answers.any((a) => a.toString().contains('소화')) ||
          answers.any((a) => a.toString().contains('속'))) {
        tcm['비위(脾胃)'] = '소화기 건강. 따뜻한 음식. 생강차 추천.';
      }
    }

    return tcm;
  }

  // ─── Profile completeness ─────────────────────

  bool get hasProfile => _profile.isNotEmpty;
  int get totalQuestions => _history.fold(0, (s, e) => s + (e['answers'] as List).length);

  /// Enough data to be useful?
  bool get isUseful => _history.length >= 3; // 3 or more visits
}
