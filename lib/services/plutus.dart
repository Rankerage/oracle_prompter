import 'dart:math';

/// 💰 Plutus Engine — 시황 + 펀더멘털 주식 분석
///
/// 마켓·종목·섹터에 대한 분석을 카드로 제공.
/// 시황(기술적) + 펀더멘털(기업가치) 통합 관점.
///
/// 이름: Plutus (플루투스)
/// - 그리스 부(富)의 신
/// - 데메테르(농업의 여신)의 자식
/// - 눈이 먼 것으로 묘사 → 누구에게나 공평하게 부를 나눠줌

class Plutus {
  static final Plutus _i = Plutus._();
  factory Plutus() => _i;
  Plutus._();

  final _rng = Random();
  final _profile = <String, dynamic>{};
  final List<String> _pendingQuestions = [];
  String _currentTicker = '';

  // ─── Sector Knowledge ──────────────────────────

  static const _sectors = {
    'AAPL': {'name': 'Apple', 'sector': '기술', 'pe': 28, 'div': 0.5, 'strength': '생태계·브랜드·현금보유'},
    'TSLA': {'name': 'Tesla', 'sector': '전기차', 'pe': 65, 'div': 0, 'strength': '혁신·배터리·자율주행'},
    'NVDA': {'name': 'NVIDIA', 'sector': '반도체', 'pe': 45, 'div': 0.03, 'strength': 'AI칩·데이터센터'},
    'MSFT': {'name': 'Microsoft', 'sector': '기술', 'pe': 35, 'div': 1.0, 'strength': '클라우드·AI·오피스'},
    'GOOGL': {'name': 'Alphabet', 'sector': '기술', 'pe': 25, 'div': 0, 'strength': '검색·광고·AI'},
    'AMZN': {'name': 'Amazon', 'sector': '전자상거래', 'pe': 40, 'div': 0, 'strength': 'AWS·물류·프라임'},
    'META': {'name': 'Meta', 'sector': 'SNS', 'pe': 22, 'div': 0.5, 'strength': '광고·AI·메타버스'},
    '005930': {'name': '삼성전자', 'sector': '반도체', 'pe': 12, 'div': 3.0, 'strength': '메모리·파운드리'},
    '000660': {'name': 'SK하이닉스', 'sector': '반도체', 'pe': 8, 'div': 1.5, 'strength': 'HBM·AI메모리'},
    '035420': {'name': 'NAVER', 'sector': '인터넷', 'pe': 20, 'div': 0.5, 'strength': '검색·AI·클라우드'},
  };

  static const _marketConditions = {
    '나스닥': '기술주 중심. 변동성 크고 성장성이 높음.',
    'S&P500': '미국 대형주 500. 시장 전체의 척도.',
    '코스피': '한국 대표지수. 수출주 비중 높음.',
    '코스닥': '한국 기술주·중소형주. 변동성 큼.',
    '니케이': '일본 대표지수. 엔화 약세 영향.',
  };

  // ─── Start analysis ────────────────────────────

  void start(String query) {
    _currentTicker = '';
    _pendingQuestions.clear();

    // Detect ticker from query
    for (final t in _sectors.keys) {
      final info = _sectors[t]!;
      if (query.toUpperCase().contains(t) || query.contains(info['name'] as String)) {
        _currentTicker = t;
        break;
      }
    }

    if (_currentTicker.isEmpty) {
      // Market analysis
      for (final m in _marketConditions.keys) {
        if (query.contains(m)) {
          _pendingQuestions.addAll([
            '어떤 기간으로 분석할까요? [단기 1-3개월] [중기 6-12개월] [장기 1년이상]',
            '투자 목적은 무엇인가요? [배당] [성장] [가치] [단기차익]',
            '위험 감수 정도는? [안전형] [중립] [공격적]',
          ]);
          return;
        }
      }
      // General
      _pendingQuestions.addAll([
        '어떤 종목이나 마켓에 관심 있으세요?',
        '투자 기간은? [단기] [중기] [장기]',
        '투자 스타일은? [배당] [성장] [가치]',
      ]);
    } else {
      // Stock-specific
      _pendingQuestions.addAll([
        '투자 기간은? [단기 1-3개월] [중기 6-12개월] [장기 1년이상]',
        '투자 목적은? [배당] [성장] [단기차익]',
        '위험 감수 정도는? [안전형] [중립] [공격적]',
      ]);
    }
  }

  String? nextQuestion() {
    if (_pendingQuestions.isEmpty) return null;
    return _pendingQuestions.removeAt(0);
  }

  void answer(String r) => _profile['a${_profile.length}'] = r;

  // ─── Generate Analysis ─────────────────────────

  Map<String, dynamic> analyze() {
    if (_currentTicker.isNotEmpty) {
      return _stockAnalysis();
    }
    return _marketAnalysis();
  }

  Map<String, dynamic> _stockAnalysis() {
    final info = _sectors[_currentTicker]!;
    final name = info['name'] as String;
    final sector = info['sector'] as String;
    final pe = info['pe'] as int;
    final div = info['div'] as double;

    // Simple analysis
    final valuation = pe > 30 ? '고평가 구간. 성장성 감안 필요.' :
        pe > 15 ? '적정 수준. 업종 평균과 비교해보세요.' : '저평가 가능성. 추가 분석 필요.';

    final dividend = div > 2 ? '배당 매력도 높음. 인컴 투자에 적합.' :
        div > 0.5 ? '배당 있음. 성장+배당 밸런스.' : '무배당. 성장주 전략에 적합.';

    final strength = info['strength'] as String;

    // Generate question-based insight
    final factors = <String>[];
    if (_profile.values.any((v) => v.toString().contains('장기'))) {
      factors.add('$name은 $strength 을(를) 보유하고 있어 장기 보유에 적합한 종목입니다.');
    }
    if (_profile.values.any((v) => v.toString().contains('배당'))) {
      factors.add('배당 수익률은 ${div}% 수준입니다. $dividend');
    }

    return {
      'ticker': _currentTicker,
      'name': name,
      'sector': sector,
      'pe': pe,
      'valuation': valuation,
      'dividend': dividend,
      'strength': strength,
      'factors': factors,
      'risk': pe > 40 ? '⚠️ 고평가 리스크. 분할 매수 권장.' : '✅ 상대적 안정 구간.',
      'disclaimer': '※ AI 분석은 참고용입니다. 투자 결정은 본인의 판단에 따르세요.',
    };
  }

  Map<String, dynamic> _marketAnalysis() {
    final conditions = <String>[];
    final tips = <String>[];

    final isDefensive = _profile.values.any((v) => v.toString().contains('안전'));
    final isAggressive = _profile.values.any((v) => v.toString().contains('공격'));
    final isLongTerm = _profile.values.any((v) => v.toString().contains('장기'));

    if (isDefensive) {
      tips.add('국채·금·배당주 중심의 방어적 포트폴리오');
      tips.add('변동성 낮은 ETF 고려 (TIGER 미국배당다우존스 등)');
    } else if (isAggressive) {
      tips.add('AI·반도체·전기차 섹터 비중 확대');
      tips.add('레버리지 ETF는 주의. 분할 매수 전략');
    } else {
      tips.add('대형주 60% + 성장주 40% 혼합');
      tips.add('월 1회 정기적 리밸런싱');
    }

    if (isLongTerm) {
      tips.add('복리 효과를 위해 배당 재투자 추천');
      tips.add('월 적립식 투자로 평균 매입 단가 낮추기');
    }

    conditions.add('현재 시장은 기술주 중심의 변동성 국면입니다.');
    conditions.add('AI와 반도체가 시장을 주도하고 있습니다.');

    return {
      'conditions': conditions,
      'tips': tips,
      'disclaimer': '※ AI 분석은 참고용입니다. 투자 결정은 본인의 판단에 따르세요.',
    };
  }

  // ─── Investment Style Profile ──────────────────

  Map<String, String> get styleProfile {
    String style = '중립형';
    if (_profile.values.any((v) => v.toString().contains('공격'))) style = '공격적 성장형';
    if (_profile.values.any((v) => v.toString().contains('안전'))) style = '안정적 배당형';

    return {
      'style': style,
      'suggestedAllocation': style.contains('공격') ? '주식 80% / 채권 20%' :
          style.contains('안전') ? '주식 40% / 채권 40% / 현금 20%' : '주식 60% / 채권 40%',
    };
  }
}
