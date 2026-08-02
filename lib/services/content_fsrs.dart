/// 🎛️ Content-Adaptive FSRS — 컨텐츠별 21개 핸들 + 업데이트 파이프라인
///
/// 각 컨텐츠 타입은 고유한 FSRS 파라미터를 가진다.
/// 마스터한 카드는 자동으로 새 컨텐츠로 교체된다.
class ContentFSRS {
  static final ContentFSRS _i = ContentFSRS._();
  factory ContentFSRS() => _i;
  ContentFSRS._();

  // ─── 컨텐츠별 FSRS 프로필 ──────────────────────

  static const _profiles = <String, _Profile>{
    // 학습형: 오래 기억. 높은 유지율.
    '영어': _Profile(retention: 0.90, maxInterval: 365, w: [1.0,1.2,2.5,4.0,1.0,1.2,2.5,4.0,1.0,1.2,2.0,3.5,1.0,1.0,1.5,2.5,0.5,0.8,1.2,2.0]),
    '신조어': _Profile(retention: 0.85, maxInterval: 180, w: [1.0,1.2,2.5,4.0,1.0,1.2,2.5,4.0,1.0,1.2,2.0,3.5,1.0,1.0,1.5,2.5,0.5,0.8,1.2,2.0]),
    '수학': _Profile(retention: 0.90, maxInterval: 365, w: [1.5,2.0,3.0,5.0,1.5,2.0,3.0,5.0,1.5,2.0,3.0,4.0,1.0,1.2,2.0,3.0,1.0,1.5,2.0,3.0]),
    '상식': _Profile(retention: 0.80, maxInterval: 90, w: [1.0,1.2,2.5,4.0,1.0,1.2,2.5,4.0,1.0,1.2,2.0,3.5,1.0,1.0,1.5,2.5,0.5,0.8,1.2,2.0]),
    // 소비형: 반복 없음. 빠른 소멸.
    '뉴스': _Profile(retention: 0.10, maxInterval: 1, w: [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]),
    '유머': _Profile(retention: 0.05, maxInterval: 1, w: [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]),
    // 청각형: 중간 유지율.
    '영어듣기': _Profile(retention: 0.70, maxInterval: 30, w: [1.0,1.2,2.0,3.0,1.0,1.2,2.0,3.0,1.0,1.2,1.5,2.5,0.5,0.8,1.2,2.0,0.5,0.8,1.0,1.5]),
  };

  // ─── Public API ────────────────────────────────

  /// Get FSRS profile for a subject
  _Profile getProfile(String subject) {
    return _profiles[subject] ?? _profiles['영어']!;
  }

  /// How many times should we show this card?
  int reviewCount(String subject) => getProfile(subject).reviewTarget;

  /// Should this content type use FSRS at all?
  bool useFSRS(String subject) => getProfile(subject).maxInterval > 1;

  // ─── Card replacement pipeline ─────────────────

  final Map<String, List<String>> _mastered = {}; // mastered cards (to replace)
  final Map<String, List<String>> _newCards = {}; // fresh cards waiting

  /// Mark a card as mastered → will be replaced with new content
  void markMastered(String subject, String card) {
    _mastered.putIfAbsent(subject, () => []).add(card);
  }

  /// Add new cards to the queue
  void addNewCards(String subject, List<String> cards) {
    _newCards.putIfAbsent(subject, () => []).addAll(cards);
  }

  /// Get replacement cards (swap mastered for new)
  List<String>? swapCards(String subject) {
    final mastered = _mastered[subject];
    final fresh = _newCards[subject];
    if (mastered == null || mastered.isEmpty) return null;
    if (fresh == null || fresh.isEmpty) return null;
    mastered.clear();
    final replacements = fresh.take(mastered.length).toList();
    fresh.removeRange(0, replacements.length.clamp(0, fresh.length));
    return replacements;
  }

  int get masteredCount => _mastered.values.fold(0, (s,l)=>s+l.length);
  int get newCardCount => _newCards.values.fold(0, (s,l)=>s+l.length);
}

class _Profile {
  final double retention;
  final int maxInterval;
  final int reviewTarget;
  final List<double> w; // 20 FSRS weights
  const _Profile({
    required this.retention, required this.maxInterval, required this.w,
    this.reviewTarget = 10,
  });
}
