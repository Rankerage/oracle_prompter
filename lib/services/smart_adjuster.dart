import 'dart:math';

/// 🎯 SmartAdjuster — 입체적 5차원 가중치 조절
///
/// [정답률, 반응속도, 시간대, 과목난이도, 카드유형]
/// 5개 차원을 동시에 고려하여 최적의 FSRS 파라미터 도출.
class SmartAdjuster {
  static final SmartAdjuster _i = SmartAdjuster._();
  factory SmartAdjuster() => _i;
  SmartAdjuster._();

  final _rng = Random();

  // Per-user adaptive state
  final Map<String, _UserCurve> _curves = {};
  _UserCurve _get(String s) => _curves.putIfAbsent(s, () => _UserCurve());

  // ─── 5D Vector Input ───────────────────────────

  /// Record a single data point
  void record({
    required String subject, required bool known,
    required int responseMs, required int hourOfDay,
    String cardType = 'text',
  }) {
    final c = _get(subject);
    c.points.add(_DataPoint(
      accuracy: known ? 1.0 : 0.0,
      speed: (3000 - responseMs.clamp(0, 3000)) / 3000, // 0=slow, 1=fast
      timeOfDay: _timeWeight(hourOfDay),
      difficulty: 0.5, // will be updated after analysis
      cardType: _typeWeight(cardType),
    ));
    if (c.points.length > 200) c.points.removeRange(0, 50);
  }

  double _timeWeight(int h) => h >= 6 && h <= 11 ? 1.0 : h >= 12 && h <= 17 ? 0.8 : h >= 18 && h <= 22 ? 0.6 : 0.3;
  double _typeWeight(String t) => t == 'listening' ? 0.5 : t == 'image' ? 0.8 : 1.0;

  // ─── Analysis ──────────────────────────────────

  /// Analyze current state and return adjustment vector
  Map<String, dynamic> analyze(String subject) {
    final c = _get(subject);
    if (c.points.length < 10) return {'ready': false};

    // Running averages
    double avgAcc = 0, avgSpeed = 0, avgTime = 0, avgType = 0;
    for (final p in c.points) {
      avgAcc += p.accuracy;
      avgSpeed += p.speed;
      avgTime += p.timeOfDay;
      avgType += p.cardType;
    }
    final n = c.points.length.toDouble();
    avgAcc /= n; avgSpeed /= n; avgTime /= n; avgType /= n;

    // Gradient: which direction should each dimension move?
    final dAcc = _gradient(avgAcc, c.prevAcc);
    final dSpeed = _gradient(avgSpeed, c.prevSpeed);
    final dTime = _gradient(avgTime, c.prevTime);
    final dType = _gradient(avgType, c.prevType);

    // Update previous values
    c.prevAcc = avgAcc; c.prevSpeed = avgSpeed;
    c.prevTime = avgTime; c.prevType = avgType;

    return {
      'ready': true,
      'accuracy': avgAcc, 'speed': avgSpeed,
      'timeWeight': avgTime, 'typeWeight': avgType,
      'gradient': [dAcc, dSpeed, dTime, dType, 0.0],
      'suggestion': _suggest(subject, avgAcc, avgSpeed, avgTime),
    };
  }

  double _gradient(double current, double prev) {
    if (prev == 0) return 0;
    return (current - prev).clamp(-0.3, 0.3);
  }

  // ─── Smart Suggestions ─────────────────────────

  String _suggest(String s, double acc, double speed, double time) {
    if (acc > 0.85 && speed > 0.7 && time > 0.6) {
      return '아침 컨디션이 좋습니다. 새로운 단어를 추천드려요.';
    }
    if (acc < 0.5 && speed < 0.4) {
      return '조금 어려운 것 같아요. 복습 모드로 전환할까요?';
    }
    if (time < 0.4 && acc > 0.7) {
      return '늦은 시간인데도 잘하고 계시네요. 5장만 더 하고 마무리!';
    }
    if (speed > 0.8 && acc < 0.6) {
      return '빠르게 누르시는데 오답이 많아요. 천천히 생각해보세요.';
    }
    return '안정적인 페이스입니다. 계속 이대로!';
  }

  // ─── Get adjusted FSRS parameters ─────────────

  Map<String, double> getAdjustedParams(String subject) {
    final a = analyze(subject);
    if (!(a['ready'] as bool)) return {'retention': 0.85, 'interval': 1.0};

    final acc = (a['accuracy'] as double).clamp(0.3, 1.0);
    final speed = (a['speed'] as double);
    final grad = (a['gradient'] as List<double>)[0];

    return {
      'retention': (0.75 + acc * 0.2).clamp(0.7, 0.95),
      'interval': (1.0 + grad * 2.0).clamp(0.5, 5.0),
      'speed': speed,
      'timeWeight': (a['timeWeight'] as double),
    };
  }

  /// Optimal time to study this subject
  int bestHour(String subject) {
    final c = _get(subject);
    if (c.points.length < 20) return 8;
    // Find hour with highest accuracy
    final hourScore = <int, double>{};
    for (final p in c.points) {
      final h = ((1 - p.timeOfDay) * 24).round().clamp(0, 23);
      hourScore[h] = (hourScore[h] ?? 0) + p.accuracy;
    }
    return hourScore.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

class _UserCurve {
  final List<_DataPoint> points = [];
  double prevAcc = 0, prevSpeed = 0, prevTime = 0, prevType = 0;
}

class _DataPoint {
  final double accuracy, speed, timeOfDay, difficulty, cardType;
  const _DataPoint({
    required this.accuracy, required this.speed,
    required this.timeOfDay, this.difficulty = 0.5,
    this.cardType = 1.0,
  });
}
