/// ⚖️ RetentionEngine — 막대기 균형 잡기
///
/// 사용자가 앱을 삭제하지 않고 지속 사용하게 하는 균형추.
/// "나무 막대기를 손가락 위에 올려 쓰러지지 않게 하는 능력."
///
/// 원리:
///   너무 적게 개입 → 사용자가 잊음 → 삭제
///   너무 많이 개입 → 사용자가 귀찮음 → 삭제
///   딱 좋은 지점 → Goldilocks zone → 지속 사용
///
/// Hermes DNA: 사용자 반응 패턴을 학습하여 최적 개입 시점 예측.
class RetentionEngine {
  static final RetentionEngine _i = RetentionEngine._();
  factory RetentionEngine() => _i;
  RetentionEngine._();

  // ─── Engagement State ──────────────────────────

  int _consecutiveRejects = 0; // 연속 무시/거부
  int _consecutiveAccepts = 0; // 연속 수용/긍정
  int _sessionsToday = 0;
  int _interactionsThisSession = 0;
  DateTime? _lastInteraction;
  DateTime? _lastFeelingCheck;

  // User's tolerance profile
  double _toleranceFactor = 1.0; // 1.0 = normal, >1 = tolerant, <1 = sensitive

  // ─── Log interaction ───────────────────────────

  /// Record every user interaction
  void logInteraction({bool accepted = true}) {
    if (accepted) {
      _consecutiveAccepts++;
      _consecutiveRejects = 0;
    } else {
      _consecutiveRejects++;
      _consecutiveAccepts = 0;
    }
    _interactionsThisSession++;
    _lastInteraction = DateTime.now();

    // Adapt tolerance based on pattern
    if (_consecutiveRejects >= 3) _toleranceFactor *= 0.8; // user is getting annoyed
    if (_consecutiveAccepts >= 10) _toleranceFactor *= 1.1; // user is in flow
    _toleranceFactor = _toleranceFactor.clamp(0.3, 3.0);
  }

  void logSessionStart() { _sessionsToday++; _interactionsThisSession = 0; }
  void logSessionEnd() { _consecutiveRejects = 0; _consecutiveAccepts = 0; }

  // ─── Smart decisions ───────────────────────────

  /// Should we engage the user right now?
  bool get shouldEngage {
    if (_consecutiveRejects >= 3) return false; // too many rejections → back off
    if (_interactionsThisSession > 50 * _toleranceFactor) return false; // too many this session
    final sinceLast = _lastInteraction != null
        ? DateTime.now().difference(_lastInteraction!).inMinutes
        : 999;
    if (sinceLast < 2) return false; // too recent
    return true;
  }

  /// Optimal delay before next engagement (minutes)
  int get optimalDelay {
    final base = _consecutiveRejects > 0 ? 30 : 5; // rejected? wait longer
    return (base * _toleranceFactor).round().clamp(2, 120);
  }

  /// Should we ask how they feel about the app?
  bool get shouldCheckFeelings {
    if (_lastFeelingCheck == null) return true;
    final daysSince = DateTime.now().difference(_lastFeelingCheck!).inDays;
    if (daysSince >= 3) return true; // every 3 days
    if (_consecutiveRejects >= 2 && daysSince >= 1) return true; // user seems frustrated
    return false;
  }

  void didCheckFeelings() => _lastFeelingCheck = DateTime.now();

  // ─── Feeling check cards ───────────────────────

  /// Generate a gentle feeling-check card
  String get feelingCard {
    final cards = [
      '티키타카와 잘 지내고 있나요',
      '아직도 불편한 점이 있나요',
      '더 편하게 사용할 수 있도록 알려주세요',
      '이대로 계속 함께해도 될까요',
    ];
    final idx = _sessionsToday % cards.length;
    return cards[idx];
  }

  // ─── Insight cards ─────────────────────────────

  /// Usage milestone cards
  String? get milestoneCard {
    if (_sessionsToday == 1) return '오늘 처음이시네요. 천천히 둘러보세요.';
    if (_sessionsToday == 3) return '벌써 세 번째 방문. 적응되셨나요.';
    if (_sessionsToday == 7) return '일주일째 함께하고 있어요. 감사합니다.';
    if (_sessionsToday % 30 == 0) return '한 달째 함께. 이제 당신의 페이스를 알 것 같아요.';
    return null;
  }

  // ─── Profile ──────────────────────────────────

  Map<String, dynamic> get profile => {
    'tolerance': _toleranceFactor,
    'sessions': _sessionsToday,
    'interactions': _interactionsThisSession,
    'rejects': _consecutiveRejects,
    'shouldEngage': shouldEngage,
    'optimalDelayMin': optimalDelay,
  };

  /// User type
  String get userType {
    if (_toleranceFactor > 1.5) return '여유로운 탐험가';
    if (_toleranceFactor < 0.5) return '예민한 감상가';
    if (_sessionsToday > 10) return '열정적인 동반자';
    if (_sessionsToday < 2) return '신중한 관찰자';
    return '꾸준한 학습자';
  }
}
