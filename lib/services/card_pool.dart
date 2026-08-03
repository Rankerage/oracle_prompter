import 'dart:math';

/// 🎚️ Card Pool — 전체 카드뭉치 vs 사용자 맞춤 카드뭉치
///
/// 마스터 풀(전체)과 활성 풀(사용자 수준)을 분리.
/// 사용자가 성장할수록 새로운 카드가 활성 풀로 유입됨.
class CardPool {
  static final CardPool _i = CardPool._();
  factory CardPool() => _i;
  CardPool._();

  final _rng = Random();

  // Per-subject: master pool (all cards), active pool (user's current level)
  final Map<String, _Pool> _pools = {};

  _Pool _get(String s) => _pools.putIfAbsent(s, () => _Pool());

  // ─── Initialize ────────────────────────────────

  /// Set the master deck for a subject (all possible cards)
  void setMaster(String subject, List<String> allCards) {
    final p = _get(subject);
    p.master = List.of(allCards);
    p.active = _pickInitial(p.master, 20); // Start with 20 cards
  }

  /// Initial selection — pick easiest/most common cards first
  List<String> _pickInitial(List<String> master, int count) {
    // For English: pick shorter words first (easier)
    if (master.isNotEmpty && master.first.contains(' ')) {
      final sorted = List.of(master)
        ..sort((a, b) => a.split(' ').first.length.compareTo(b.split(' ').first.length));
      return sorted.take(count).toList();
    }
    // Otherwise: random sample
    return List.of(master)..shuffle(_rng);
  }

  // ─── Card serving ──────────────────────────────

  /// Get the next card for the user (from active pool)
  String nextCard(String subject) {
    final p = _get(subject);
    if (p.active.isEmpty) _unlockMore(subject);
    if (p.active.isEmpty) return masterRandom(subject);
    return p.active[_rng.nextInt(p.active.length)];
  }

  /// Get a random card from master (fallback)
  String masterRandom(String subject) {
    final p = _get(subject);
    if (p.master.isEmpty) return '...';
    return p.master[_rng.nextInt(p.master.length)];
  }

  // ─── Progression ───────────────────────────────

  /// Mark a card as mastered → unlock harder cards
  void markMastered(String subject, String card) {
    final p = _get(subject);
    p.active.remove(card);
    p.mastered.add(card);
    // Every 5 mastered cards, unlock 5 new ones
    if (p.mastered.length % 5 == 0) _unlockMore(subject);
  }

  /// Mark a card as too hard → keep it, but don't unlock harder yet
  void markStruggled(String subject, String card) {
    final p = _get(subject);
    p.struggled.add(card);
    // If too many struggled, stay at current level
  }

  /// Unlock next batch of cards from master
  void _unlockMore(String subject) {
    final p = _get(subject);
    final remaining = p.master
        .where((c) => !p.active.contains(c) && !p.mastered.contains(c))
        .toList();
    if (remaining.isEmpty) return;
    remaining.shuffle(_rng);
    p.active.addAll(remaining.take(5));
  }

  // ─── Level tracker ─────────────────────────────

  /// What percentage of master pool has user seen?
  double progress(String subject) {
    final p = _get(subject);
    return p.master.isEmpty ? 0.0 : (p.mastered.length + p.active.length) / p.master.length;
  }

  /// How many cards left to master?
  int remaining(String subject) {
    final p = _get(subject);
    return p.master.length - p.mastered.length;
  }

  /// Active pool size
  int activeSize(String subject) => _get(subject).active.length;

  /// Master pool size
  int masterSize(String subject) => _get(subject).master.length;

  // ─── Natural language commands ─────────────────

  /// "너무 쉬워요" — skip mastered, unlock harder
  void unlockHarder(String subject) {
    final p = _get(subject);
    // Unlock a bigger batch
    final remaining = p.master
        .where((c) => !p.active.contains(c) && !p.mastered.contains(c))
        .toList();
    remaining.shuffle(_rng);
    p.active.addAll(remaining.take(15)); // bigger jump
  }

  /// "어려워요" — go back to basics
  void easierMode(String subject) {
    final p = _get(subject);
    // Reset to initial easier cards
    p.active = _pickInitial(p.master, 15);
    p.mastered.clear();
  }

  /// "좋아요" — show more of this subject
  void favorSubject(String subject) {
    final p = _get(subject);
    final remaining = p.master
        .where((c) => !p.active.contains(c) && !p.mastered.contains(c))
        .toList();
    remaining.shuffle(_rng);
    p.active.addAll(remaining.take(10));
  }

  // ─── 🌍 Generate 10x bigger decks ──────────────

  /// Expand a deck by generating similar cards from a template
  static List<String> expand(List<String> base, int targetSize) {
    if (base.length >= targetSize) return base;
    final expanded = List<String>.from(base);
    final _rng = Random();

    // For English: generate variations
    if (base.isNotEmpty && base.first.contains(' ') && base.first.split(' ').first.length <= 15) {
      // Expand by cycling through known patterns
      final prefixes = ['able','pre','re','un','in','over','under','out','dis','co'];
      final suffixes = ['tion','ance','ment','ness','ful','less','able','ous','ive','al'];
      final roots = ['form','port','struct','press','tend','serve','cern','gest','min','vol'];
      while (expanded.length < targetSize) {
        final p = prefixes[_rng.nextInt(prefixes.length)];
        final r = roots[_rng.nextInt(roots.length)];
        final s = suffixes[_rng.nextInt(suffixes.length)];
        final word = '$p${r.substring(0, r.length ~/ 2)}${s.substring(0, s.length ~/ 2)}';
        expanded.add('$word ${word}의미');
      }
    } else {
      // For other types: duplicate with markers
      while (expanded.length < targetSize) {
        final idx = expanded.length % base.length;
        expanded.add('${base[idx]} #${expanded.length}');
      }
    }
    return expanded;
  }
}

class _Pool {
  List<String> master = [];   // All possible cards
  List<String> active = [];   // Currently available (at user level)
  List<String> mastered = []; // Completed
  List<String> struggled = []; // Too hard, keep practicing
}
