/// 👤 PersonaEngine — 사용자 페르소나 구축
///
/// 30일 데이터로 고유한 학습 페르소나 생성.
/// "아침형 영어 천재", "밤샘 신조어 수집가", "느리지만 확실한" 등.
class PersonaEngine {
  static final PersonaEngine _i = PersonaEngine._();
  factory PersonaEngine() => _i;
  PersonaEngine._();

  final _history = <_Entry>[];

  void record({
    required String subject, required bool known,
    required int hour, required int responseMs,
  }) {
    _history.add(_Entry(subject: subject, known: known, hour: hour, ms: responseMs));
    if (_history.length > 5000) _history.removeRange(0, 1000);
  }

  // ─── Traits ────────────────────────────────────

  double get _accuracy => _history.isEmpty ? 0.5 :
      _history.where((e) => e.known).length / _history.length;

  double get _avgSpeed => _history.isEmpty ? 800 :
      _history.map((e) => e.ms).reduce((a, b) => a + b) / _history.length;

  String get _chronotype {
    final morning = _history.where((e) => e.hour >= 5 && e.hour <= 11).length;
    final night = _history.where((e) => e.hour >= 20 || e.hour <= 2).length;
    if (morning > night * 1.5) return '아침형';
    if (night > morning * 1.5) return '올빼미형';
    return '자유형';
  }

  String get _speedTrait => _avgSpeed < 400 ? '번개' : _avgSpeed < 800 ? '보통' : '신중';

  String get _accuracyTrait => _accuracy > 0.8 ? '천재' : _accuracy > 0.6 ? '우등생' : '노력가';

  Map<String, double> get _favoriteSubjects {
    final m = <String, int>{};
    for (final e in _history) { m[e.subject] = (m[e.subject] ?? 0) + 1; }
    final total = m.values.fold(0, (a, b) => a + b).toDouble();
    return m.map((k, v) => MapEntry(k, v / total));
  }

  // ─── Persona ───────────────────────────────────

  String get personaName => '${_chronotype} ${_speedTrait} ${_accuracyTrait}';

  Map<String, dynamic> get profile => {
    'name': personaName,
    'chronotype': _chronotype,
    'speed': _speedTrait,
    'accuracy': _accuracyTrait,
    'accuracyRate': (_accuracy * 100).round(),
    'avgResponseMs': _avgSpeed.round(),
    'favorites': _favoriteSubjects,
    'totalCards': _history.length,
    'bestSubject': _favoriteSubjects.isNotEmpty
        ? _favoriteSubjects.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : '영어',
  };

  /// Generate a natural introduction
  String introduce() {
    final p = profile;
    return '당신은 ${p['name']}입니다. '
        '평균 반응 ${p['avgResponseMs']}ms, '
        '정답률 ${p['accuracyRate']}%. '
        '가장 좋아하는 과목은 ${p['bestSubject']}입니다.';
  }
}

class _Entry {
  final String subject;
  final bool known;
  final int hour, ms;
  const _Entry({
    required this.subject, required this.known,
    required this.hour, required this.ms,
  });
}
