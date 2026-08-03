/// 🏥 Hygieia Engine — 평생 건강 문진
///
/// 현대의학 + 한의학. 8체질 분석. 카드로 묻고 카드로 답함.
/// 스트레스 제로. "이 질문에 답해보실래요" 먼저 묻는다.
class Hygieia {
  static final Hygieia _i = Hygieia._();
  factory Hygieia() => _i;
  Hygieia._();

  final _profile = <String, dynamic>{};
  final List<Map<String, dynamic>> _history = [];
  final List<String> _pending = [];
  String _currentComplaint = '';

  // ─── 8체질 질문 (공손한 접근) ──────────────────

  static const _bcQuestions = [
    '체형은 어느 쪽인가요',
    '상체가 발달한 편인가요, 하체가 발달한 편인가요',
    '땀이 많은 편인가요, 적은 편인가요',
    '더위를 많이 타는 편인가요, 추위를 많이 타는 편인가요',
    '물을 자주 마시는 편인가요',
    '소화가 잘 되는 편인가요, 더부룩한 편인가요',
    '변비가 있나요, 설사를 자주 하나요',
    '손발이 차가운 편인가요, 따뜻한 편인가요',
    '잠을 잘 자는 편인가요, 불면이 있나요',
    '술을 마시면 얼굴이 빨개지나요',
  ];

  static const _bcOptions = [
    ['상체 발달', '하체 발달', '균형 잡힘'],
    ['땀이 많다', '땀이 적다', '보통'],
    ['더위를 많이 탐', '추위를 많이 탐', '둘 다'],
    ['자주 마심', '별로 안 마심'],
    ['잘 되는 편', '더부룩한 편', '보통'],
    ['변비', '설사', '보통'],
    ['차가운 편', '따뜻한 편'],
    ['잘 잠', '불면', '보통'],
    ['빨개짐', '안 빨개짐', '안 마심'],
  ];

  bool _bcStarted = false;
  int _bcStep = -1;

  // ─── 공손한 첫 질문 ────────────────────────────

  /// "8체질을 알아볼까요?" — ○✕
  String get greetingCard => '8체질 중 어디에 해당하는지\n알아볼까요';

  void startBC() { _bcStarted = true; _bcStep = 0; }

  /// Get next 8-constitution question (with options)
  Map<String, dynamic>? get bcQuestion {
    if (!_bcStarted || _bcStep < 0 || _bcStep >= _bcQuestions.length) return null;
    return {
      'step': _bcStep + 1,
      'total': _bcQuestions.length,
      'question': _bcQuestions[_bcStep],
      'options': _bcOptions[_bcStep],
    };
  }

  void answerBC(String response) {
    _profile['bc_q$_bcStep'] = response;
    _bcStep++;
  }

  bool get bcComplete => _bcStep >= _bcQuestions.length;

  // ─── 8체질 판정 ────────────────────────────────

  Map<String, dynamic> get bcResult {
    if (!bcComplete) return {'ready': false};

    // Simple heuristic based on answers
    int upper = 0, heat = 0, digestion = 0, cold = 0;
    final answers = <String>[];
    for (int i = 0; i < _bcQuestions.length; i++) {
      final a = _profile['bc_q$i']?.toString() ?? '';
      answers.add(a);
      if (i == 0 && a.contains('상체')) upper++;
      if (i == 3 && a.contains('더위')) heat++;
      if (i == 5 && a.contains('더부룩')) digestion++;
      if (i == 7 && a.contains('차가운')) cold++;
    }

    String type;
    List<String> goodFoods, badFoods, tips;

    if (heat >= 1 && digestion >= 1) {
      type = '목양체질 (간·담낭 강함)';
      goodFoods = ['해산물', '녹색채소', '현미', '들기름'];
      badFoods = ['육류', '밀가루', '커피', '인삼'];
      tips = ['찬 음식 자주', '수영·걷기 추천', '분노 조절 훈련', '오후 3시 이후 금식'];
    } else if (upper >= 1 && cold >= 1) {
      type = '목음체질 (간·담낭 약함)';
      goodFoods = ['소고기', '마늘', '생강', '대추'];
      badFoods = ['돼지고기', '생맥주', '냉면', '수박'];
      tips = ['따뜻한 음식 위주', '족욕 자주', '일찍 자기', '햇볕 충분히'];
    } else if (cold >= 1 && digestion >= 1) {
      type = '토양체질 (비장·위장 강함)';
      goodFoods = ['쌀밥', '감자', '호박', '밤'];
      badFoods = ['날음식', '찬물', '아이스크림'];
      tips = ['소식 위주', '천천히 식사', '산책', '규칙적 식사 시간'];
    } else if (heat >= 1) {
      type = '토음체질 (비장·위장 약함)';
      goodFoods = ['따뜻한 죽', '생강차', '닭고기', '찹쌀'];
      badFoods = ['튀김', '밀가루', '술', '탄산'];
      tips = ['아침 꼭 먹기', '늦은 저녁 금지', '따뜻한 물 자주', '배 마사지'];
    } else {
      type = '수양체질 (신장·방광 강함)';
      goodFoods = ['검은콩', '미역', '굴', '호두'];
      badFoods = ['짠 음식', '가공식품', '카페인'];
      tips = ['물 충분히', '소금 줄이기', '허리 따뜻하게', '규칙적 운동'];
    }

    return {
      'ready': true,
      'type': type,
      'goodFoods': goodFoods,
      'badFoods': badFoods,
      'tips': tips,
    };
  }

  // ─── Symptom ───────────────────────────────────

  void reportSymptom(String complaint) {
    _currentComplaint = complaint;
    _pending.clear();
    _history.add({'date': DateTime.now(), 'complaint': complaint, 'answers': []});

    if (complaint.contains('눈') || complaint.contains('시력')) {
      _pending.addAll(['언제부터 시작되었나요','어떤 느낌인가요 — 흐릿함, 겹쳐보임, 빛번짐','한쪽인가요 양쪽인가요','두통이나 어지러움이 함께 있나요','당뇨나 고혈압 진단을 받은 적이 있나요']);
    } else if (complaint.contains('머리') || complaint.contains('두통')) {
      _pending.addAll(['어느 부위인가요 — 관자놀이, 뒷머리, 한쪽','어떤 통증인가요 — 욱신, 찌르는, 무거운','메스꺼움이나 구토가 동반되나요','빛이나 소리에 민감해지나요']);
    } else {
      _pending.addAll(['언제부터 있었나요','증상의 강도는 — 약함, 보통, 심함','다른 증상이 함께 있나요','과거에 비슷한 적이 있나요']);
    }
  }

  String? nextQuestion() => _pending.isNotEmpty ? _pending.removeAt(0) : null;

  void answer(String r) {
    if (_history.isNotEmpty) (_history.last['answers'] as List).add(r);
  }

  // ─── Report ────────────────────────────────────

  Map<String, dynamic> generateReport() {
    final risks = <String>[], recs = <String>[];

    for (final e in _history) {
      final answers = e['answers'] as List;
      if (answers.any((a) => a.toString().contains('당뇨'))) {
        risks.add('당뇨망막병증 위험. 안저검사 권장.');
      }
      if (answers.any((a) => a.toString().contains('스트레스') || a.toString().contains('두통'))) {
        recs.add('견갑근 스트레칭. 명상 추천.');
      }
    }

    return {'risks': risks, 'recommendations': recs, 'totalVisits': _history.length};
  }

  bool get isUseful => _history.length >= 1 || bcComplete;
  int get totalQuestions => _history.fold(0, (s, e) => s + (e['answers'] as List).length);
}
