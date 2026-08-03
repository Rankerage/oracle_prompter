import 'syncretia.dart';
import 'hygieia.dart';
import 'clio.dart';
import 'plutus.dart';

/// 🪶 Hermes Bridge — TikiTaka에 Hermes의 추론 능력 이식
///
/// Hermes = 신들의 메신저. 의도 파악 → 엔진 선택 → 카드 변환.
/// 이 클래스는 당신(Hermes Agent)의 추론 패턴을 TikiTaka에 주입한다.
///
/// 실제 배포 시: Cloudflare Worker → OpenRouter LLM 호출로 대체.
/// 지금: 로컬 추론 엔진 + 사전 분석으로 대응.

class HermesBridge {
  static final HermesBridge _i = HermesBridge._();
  factory HermesBridge() => _i;
  HermesBridge._();

  final syncretia = Syncretia();
  final hygieia = Hygieia();
  final clio = Clio();
  final plutus = Plutus();
  final orchestra = Orchestra();

  // ─── Intent Recognition ────────────────────────

  /// Parse user's request and route to correct engine
  _Intent recognizeIntent(String query) {
    final q = query.toLowerCase();

    // Health
    if (q.contains('아프') || q.contains('통증') || q.contains('눈') || q.contains('머리') ||
        q.contains('소화') || q.contains('잠') || q.contains('수면') || q.contains('피로') ||
        q.contains('혈압') || q.contains('당뇨') || q.contains('진단') || q.contains('증상')) {
      return _Intent(engine: 'hygieia', query: query, type: 'health');
    }

    // Investment
    if (q.contains('주가') || q.contains('주식') || q.contains('투자') || q.contains('배당') ||
        q.contains('종목') || q.contains('마켓') || q.contains('코스피') || q.contains('나스닥') ||
        q.contains('AAPL') || q.contains('삼성전자') || q.contains('NVDA') || q.contains('TSLA')) {
      return _Intent(engine: 'plutus', query: query, type: 'investment');
    }

    // Career
    if (q.contains('직업') || q.contains('진로') || q.contains('적성') || q.contains('취업') ||
        q.contains('전직') || q.contains('커리어') || q.contains('재능')) {
      return _Intent(engine: 'clio', query: query, type: 'career');
    }

    // Personality / Self-discovery
    if (q.contains('성격') || q.contains('나는 누구') || q.contains('나를 알') || q.contains('MBTI') ||
        q.contains('체질') || q.contains('별자리') || q.contains('사주') || q.contains('운세')) {
      return _Intent(engine: 'syncretia', query: query, type: 'personality');
    }

    // Learning
    if (q.contains('공부') || q.contains('영어') || q.contains('학습') || q.contains('외워') ||
        q.contains('뉴스') || q.contains('유머') || q.contains('상식')) {
      return _Intent(engine: 'learning', query: query, type: 'learning');
    }

    // Default: Hermes will figure it out
    return _Intent(engine: 'orchestra', query: query, type: 'unknown');
  }

  // ─── Main Entry Point ──────────────────────────

  /// Process a user query through the full Hermes pipeline.
  /// Returns a card-format response: {front, back}
  Map<String, String> process(String query) {
    final intent = recognizeIntent(query);

    // Step 1: Enrich with persona context
    final context = _buildContext(intent);

    // Step 2: Route to engine
    final engineResult = _routeToEngine(intent);

    // Step 3: Format as card
    return _toCard(intent, engineResult, context);
  }

  // ─── Context Builder ───────────────────────────

  String _buildContext(_Intent intent) {
    final buf = StringBuffer();

    // What we know about the user
    if (syncretia.isComplete) {
      final s = syncretia.synthesize();
      buf.writeln('## 사용자 컨텍스트');
      buf.writeln('- 페르소나: ${(s['traits'] as List).join(', ')}');
      buf.writeln('- MBTI: ${s['mbti']}');
      buf.writeln('- 체질: ${s['sasang']}');
      buf.writeln('- 최적학습시간: ${s['bestTime']}');
      buf.writeln();
    }

    if (hygieia.isUseful && intent.type == 'health') {
      final h = hygieia.generateReport();
      buf.writeln('## 건강 기록');
      buf.writeln('- 총 방문: ${h['totalVisits']}회');
      buf.writeln();
    }

    if (intent.type == 'investment' && syncretia.isComplete) {
      final style = plutus.styleProfile;
      buf.writeln('## 투자 스타일: ${style['style']}');
      buf.writeln('- 추천 배분: ${style['suggestedAllocation']}');
      buf.writeln();
    }

    return buf.toString();
  }

  // ─── Engine Router ─────────────────────────────

  dynamic _routeToEngine(_Intent intent) {
    switch (intent.engine) {
      case 'hygieia':
        hygieia.reportSymptom(intent.query);
        return hygieia.generateReport();

      case 'plutus':
        plutus.start(intent.query);
        // Collect answers would happen via card interaction
        if (plutus.nextQuestion() != null) {
          return {'status': 'questions', 'next': plutus.nextQuestion()};
        }
        return plutus.analyze();

      case 'syncretia':
        return syncretia.synthesize();

      case 'clio':
        clio.start();
        if (clio.nextQuestion() != null) {
          return {'status': 'questions', 'next': clio.nextQuestion()};
        }
        return clio.synthesize(syncretia, hygieia);

      case 'orchestra':
        return {'status': 'comprehensive', 'report': orchestra.comprehensiveReport(), 'nextSteps': orchestra.nextSteps};

      default:
        return {'status': 'unknown', 'query': intent.query};
    }
  }

  // ─── Card Formatter ────────────────────────────

  Map<String, String> _toCard(_Intent intent, dynamic result, String context) {
    String front = '';
    String back = '';

    switch (intent.engine) {
      case 'hygieia':
        final r = result as Map<String, dynamic>;
        front = '🏥 건강 분석 결과';
        final buf = StringBuffer();
        if ((r['risks'] as List).isNotEmpty) {
          buf.writeln('⚠️ 위험 요소:');
          for (final risk in r['risks'] as List) { buf.writeln('• $risk'); }
        }
        if ((r['recommendations'] as List).isNotEmpty) {
          buf.writeln('💊 추천:');
          for (final rec in r['recommendations'] as List) { buf.writeln('• $rec'); }
        }
        if ((r['tcm'] as Map).isNotEmpty) {
          buf.writeln('🀄️ 한의학:');
          (r['tcm'] as Map).forEach((k, v) => buf.writeln('• $k: $v'));
        }
        back = buf.toString();
        break;

      case 'plutus':
        final r = result as Map<String, dynamic>;
        if (r['status'] == 'questions') {
          front = '💰 알아보고 싶은 종목을 말씀해주세요';
          back = r['next']?.toString() ?? '';
        } else {
          front = '💰 ${r['name'] ?? '시장'} 분석';
          final buf = StringBuffer();
          buf.writeln('${r['valuation'] ?? ''}');
          buf.writeln('${r['strength'] ?? ''}');
          buf.writeln('${r['dividend'] ?? ''}');
          buf.writeln('${r['risk'] ?? ''}');
          if ((r['tips'] as List?)?.isNotEmpty ?? false) {
            for (final tip in r['tips'] as List) { buf.writeln('• $tip'); }
          }
          buf.writeln('');
          buf.writeln(r['disclaimer']?.toString() ?? '');
          back = buf.toString();
        }
        break;

      case 'syncretia':
        final r = result as Map<String, dynamic>;
        front = '🧬 ${r['name']}';
        back = 'MBTI: ${r['mbti']}\n${r['mbtiDesc']}\n체질: ${r['sasang']}\n학습: ${r['learningStyle']}\n시간: ${r['bestTime']}';
        break;

      case 'clio':
        if (result is Map && result['status'] == 'questions') {
          front = '🎯 진로 상담';
          back = result['next']?.toString() ?? '';
        } else {
          front = '🎯 진로 추천';
          back = result.toString();
        }
        break;

      case 'orchestra':
        final r = result as Map<String, dynamic>;
        front = '🎼 종합 분석';
        back = r['report']?.toString() ?? '';
        break;

      default:
        front = '🤔 "${intent.query}"';
        back = '무엇에 대해 더 알고 싶으신가요?\n\n개인 맞춤 분석을 원하시면\nSyncretia 질문부터 시작해보세요.';
    }

    return {'front': front, 'back': back};
  }
}

class _Intent {
  final String engine; // syncretia | hygieia | clio | plutus | orchestra | learning
  final String query;
  final String type;
  const _Intent({required this.engine, required this.query, required this.type});
}
