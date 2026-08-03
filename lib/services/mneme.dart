import 'markdown_vault.dart';

/// 🧠 Mneme Engine — 기억 + 실행 엔진
///
/// TikiTaka가 사용자의 외부 두뇌가 되는 핵심.
/// "기억해줘" → 저장, "실행해줘" → 알림.
///
/// 이름: Mneme (므네메)
/// - 그리스 기억의 여신 (Mnemosyne의 다른 이름)
/// - 뮤즈들의 어머니 = 모든 창조의 근원

class Mneme {
  static final Mneme _i = Mneme._();
  factory Mneme() => _i;
  Mneme._();

  final List<_NoteCard> _notes = [];
  final List<_Reminder> _reminders = [];

  // ─── Note Cards ────────────────────────────────

  /// Create a note card — voice, text, or photo
  void remember(String content, {String type = 'text', String? mediaUrl}) {
    _notes.insert(0, _NoteCard(
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    ));

    // Auto-tag based on content
    if (content.contains('회의')) _notes.first.tags.add('업무');
    if (content.contains('약속') || content.contains('예약')) _notes.first.tags.add('일정');
    if (content.contains('아이디어')) _notes.first.tags.add('아이디어');
    if (content.contains('장보기') || content.contains('살것')) _notes.first.tags.add('쇼핑');
  }

  /// Get all notes as cards
  List<Map<String, String>> get noteCards => _notes.map((n) => {
    'front': n.content,
    'back': '${n.type} · ${n.tags.isNotEmpty ? n.tags.join(', ') : '일반'} · '
        '${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}',
  }).toList();

  // ─── Reminders ─────────────────────────────────

  /// Set a reminder that will notify the user
  void remindAt(String what, DateTime when) {
    _reminders.add(_Reminder(what: what, when: when));
    _reminders.sort((a, b) => a.when.compareTo(b.when));
  }

  /// Get upcoming reminders (next 24h)
  List<_Reminder> get upcoming =>
      _reminders.where((r) => r.when.isAfter(DateTime.now())).toList();

  /// Get overdue reminders
  List<_Reminder> get overdue =>
      _reminders.where((r) => r.when.isBefore(DateTime.now()) && !r.done).toList();

  /// The most urgent reminder card
  Map<String, String>? get urgentCard {
    final now = DateTime.now();
    final urgent = _reminders
        .where((r) => r.when.isAfter(now) && r.when.difference(now).inMinutes < 30 && !r.done)
        .toList();
    if (urgent.isEmpty) return null;
    final r = urgent.first;
    final minutes = r.when.difference(now).inMinutes;
    return {
      'front': '⏰ ${minutes}분 후: ${r.what}',
      'back': '지금 준비하세요.\n○ 알겠어요  ✕ 다시 알림',
    };
  }

  void markDone(String what) {
    for (final r in _reminders) {
      if (r.what == what) r.done = true;
    }
  }

  // ─── Auto-scheduler ────────────────────────────

  /// Learn from user patterns and auto-suggest
  List<String> get autoSuggestions {
    final suggestions = <String>[];

    // Morning routine (from pattern)
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour <= 9) {
      suggestions.add('오늘 하루 계획을 세워볼까요?');
    }
    if (hour >= 21 && hour <= 23) {
      suggestions.add('내일 할 일을 메모해두세요.');
    }

    // Overdue reminders
    if (overdue.isNotEmpty) {
      suggestions.add('${overdue.length}개의 할 일이 밀려있어요.');
    }

    return suggestions;
  }
}

class _NoteCard {
  final String content;
  final String type; // text, voice, photo
  final String? mediaUrl;
  final DateTime createdAt;
  final List<String> tags = [];
  _NoteCard({required this.content, required this.type, this.mediaUrl, required this.createdAt});
}

class _Reminder {
  final String what;
  final DateTime when;
  bool done = false;
  _Reminder({required this.what, required this.when});
}
