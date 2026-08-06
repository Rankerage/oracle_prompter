/// 🎓 Curriculum Engine — 맞춤형 시험·학습 컨텐츠 생성
///
/// 주제 하나로 단답퀴즈 카드뭉치 생성.
/// 5지선다 → ○✕ 변환. 교재 업로드 → 카드 변환.
/// 백그라운드에서 작동. 사용자는 기다리지 않음.
class CurriculumEngine {
  static final CurriculumEngine _i = CurriculumEngine._();
  factory CurriculumEngine() => _i;
  CurriculumEngine._();

  // ─── Generation state ──────────────────────────

  String _currentTopic = '';
  bool _isGenerating = false;
  int _cardsGenerated = 0;
  final List<String> _newCards = [];

  /// Start generating a curriculum
  Future<void> generate(String topic, {
    String? level,     // beginner, intermediate, advanced
    String? focus,     // specific area within topic
    String? fileText,  // uploaded textbook content
    int targetCards = 50,
  }) async {
    _currentTopic = topic;
    _isGenerating = true;
    _cardsGenerated = 0;
    _newCards.clear();

    // Step 1: Ask user for scope (if not provided)
    // This is done via card interface — caller handles this

    // Step 2: Generate prompt
    final prompt = _buildPrompt(topic, level: level, focus: focus,
        fileText: fileText, count: targetCards);

    // Step 3: LLM generates cards (via OpenRouter proxy)
    // For now, generate basic cards from built-in templates
    _generateFromTemplate(topic, count: targetCards);

    _isGenerating = false;
  }

  String _buildPrompt(String topic, {
    String? level, String? focus, String? fileText, int count = 50,
  }) {
    final buf = StringBuffer();
    buf.writeln('Create $count simple Q&A flashcard pairs about: $topic.');
    if (level != null) buf.writeln('Level: $level.');
    if (focus != null) buf.writeln('Focus on: $focus.');

    buf.writeln('''
Format each as: "question answer"
Rules:
- Question must be answerable with one word or short phrase
- No multiple choice. No "which of the following".
- Cover the full range of the topic
- Questions should test understanding, not just recall
- Mix easy and hard questions
- Korean language preferred for Korean topics

Example good format:
"운전면허 갱신 기간 10년마다"
"음주운전 기준 혈중알콜농도 0.03%"
"고속도로 최고속도 120km"
''');

    return buf.toString();
  }

  /// Template-based generation (offline fallback)
  void _generateFromTemplate(String topic, {int count = 50}) {
    final cards = <String>[];

    // Topic-specific templates
    if (topic.contains('운전') || topic.contains('면허')) {
      cards.addAll(_drivingLicenseQA());
    } else if (topic.contains('영어')) {
      cards.addAll(['vocabulary advanced', 'grammar intermediate', 'reading comprehension']);
    } else {
      // Generic: decompose topic into subtopics
      for (int i = 1; i <= count; i++) {
        cards.add('$topic 핵심개념 $i $topic의 ${i}번째 핵심 내용');
      }
    }

    _newCards.addAll(cards.take(count));
    _cardsGenerated = _newCards.length;
  }

  /// Pre-built driving license Q&A (Korea)
  List<String> _drivingLicenseQA() {
    return [
      '운전면허 갱신 주기 10년마다',
      '음주운전 기준 혈중알콜농도 0.03%',
      '음주측정 불응 시 처벌 면허취소',
      '고속도로 최고속도 승용차 120km/h',
      '고속도로 최저속도 승용차 50km/h',
      '어린이보호구역 속도 30km/h',
      '신호위반 벌점 15점',
      '중앙선 침범 벌점 30점',
      '안전벨트 미착용 벌점 3점',
      '운전 중 휴대폰 사용 벌점 15점',
      '횡단보도 보행자 보호 일시정지',
      '방향지시등 작동시기 30m 전',
      '주차금지 장소 소화전 5m 이내',
      '주차금지 장소 교차로 10m 이내',
      '주차금지 장소 버스정류장 10m 이내',
      '좌회전 금지 장소 안전지대',
      '유턴 금지 장소 횡단보도',
      '추월 금지 장소 터널 안',
      '추월 금지 장소 교량 위',
      '적재물 낙하방지 의무 운전자',
      '임시운행 허가기간 5일',
      '제1종 보통면허 운전가능차량 승용차·15인승이하',
      '제2종 보통면허 운전가능차량 승용차·10인승이하',
      '연습면허 유효기간 1년',
      '국제면허 유효기간 1년',
      '운전면허 정기적성검사 1종 7년',
      '운전면허 정기적성검사 2종 9년',
      '교통사고 발생 시 구호조치 신고의무',
      '졸음운전 예방 2시간마다 15분 휴식',
      '비상등 사용 상황 고장·긴급시',
      '전조등 작동시간 일몰 후 30분',
      '도로교통법상 자전거 차량',
      '이륜차 승차인원 2인',
      '이륜차 인도주행 금지',
      '이륜차 안전모 착용 의무',
      '어린이 통학버스 보호자 탑승의무',
      '고속도로 갓길 통행금지',
      '터널 내 차로변경 금지',
      '급제동 금지 원칙',
      '끼어들기 금지',
      '보복운전 처벌 특가법 적용',
      '뺑소니 처벌 5년이하 징역',
      '무면허운전 처벌 1년이하 징역',
      '정지선 준수 의무',
      '과속카메라 단속기준 제한속도+10km',
      '신호등 색상 순서 빨강·노랑·초록',
      '적색신호 의미 정지',
      '황색신호 의미 곧 적색',
      '녹색신호 의미 진행',
      '녹색화살표 의미 지정방향 진행가능',
    ];
  }

  // ─── Public API ────────────────────────────────

  bool get isGenerating => _isGenerating;
  int get generatedCount => _cardsGenerated;
  List<String> get newCards => List.unmodifiable(_newCards);
  String get topic => _currentTopic;

  /// Progress as a fraction (0.0 - 1.0)
  double get progress => _newCards.isEmpty ? 0.0
      : _cardsGenerated / (_cardsGenerated + _newCards.length);

  /// How many more cards are being generated
  String get statusMessage {
    if (!_isGenerating && _newCards.isEmpty) return '주제를 선택해주세요';
    if (_isGenerating) return '$_currentTopic 카드 만드는 중... $_cardsGenerated장 완성';
    return '$_currentTopic: $_cardsGenerated장 준비 완료';
  }
}
