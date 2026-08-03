import 'dart:math';
import 'card_factory.dart';

/// 📝 Markdown Vault — LLM이 읽을 수 있는 학습기록
///
/// 하루 단위 마크다운 문서로 저장.
/// LLM이 사용자 패턴을 분석하고 컨텐츠를 생성할 때 참조.
class MarkdownVault {
  static final MarkdownVault _i = MarkdownVault._();
  factory MarkdownVault() => _i;
  MarkdownVault._();

  String _today = _dateStr(DateTime.now());
  final _daily = <String, _DayLog>{};

  _DayLog _log() => _daily.putIfAbsent(_today, () => _DayLog());

  static String _dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  static String _timeStr(DateTime d) =>
    '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  // ─── Record ────────────────────────────────────

  void record(String subject, bool known, {int? responseMs}) {
    final l = _log();
    l.total++;
    if (known) l.correct++;
    if (responseMs != null) {
      l.totalMs += responseMs;
      l.countMs++;
    }
    _today = _dateStr(DateTime.now()); // refresh date
  }

  void recordSubjectChange(String from, String to) {
    _log().subjectChanges.add('${_timeStr(DateTime.now())} $from → $to');
  }

  // ─── Generate Markdown for LLM ─────────────────

  /// Full learning history as markdown
  String toMarkdown() {
    final buf = StringBuffer();

    buf.writeln('# 📊 TikiTaka 학습 기록');
    buf.writeln('마지막 업데이트: ${_dateStr(DateTime.now())} ${_timeStr(DateTime.now())}');
    buf.writeln();

    if (_daily.isEmpty) {
      buf.writeln('아직 기록이 없습니다.');
      return buf.toString();
    }

    // Summary table
    buf.writeln('## 📈 전체 요약');
    buf.writeln();
    buf.writeln('| 날짜 | 카드 | 정답률 | 평균반응 | 과목 |');
    buf.writeln('|------|------|--------|----------|------|');

    for (final e in _daily.entries.toList().reversed.take(30)) {
      final d = e.value;
      final rate = d.total > 0 ? (d.correct / d.total * 100).round() : 0;
      final avgMs = d.countMs > 0 ? (d.totalMs / d.countMs).round() : 0;
      final subjects = d.subjectChanges.isNotEmpty
          ? d.subjectChanges.last.split(' ').last
          : '영어';
      buf.writeln('| ${e.key} | ${d.total} | $rate% | ${avgMs}ms | $subjects |');
    }
    buf.writeln();

    // Today detail
    final today = _daily[_today];
    if (today != null) {
      buf.writeln('## 📅 오늘 ($_today)');
      buf.writeln();
      buf.writeln('- 총 카드: ${today.total}장');
      buf.writeln('- 정답: ${today.correct}장');
      buf.writeln('- 정답률: ${today.total > 0 ? (today.correct / today.total * 100).round() : 0}%');
      buf.writeln('- 평균 반응 시간: ${today.countMs > 0 ? (today.totalMs / today.countMs).round() : 0}ms');
      if (today.subjectChanges.isNotEmpty) {
        buf.writeln('- 과목 이동: ${today.subjectChanges.join(', ')}');
      }
      buf.writeln();
    }

    // Content deck sizes
    buf.writeln('## 📦 현재 카드 덱');
    buf.writeln();
    buf.writeln('| 과목 | 카드 수 | 유형 |');
    buf.writeln('|------|:---:|------|');
    for (final s in ['영어','영어듣기','신조어','수학','상식','유머','뉴스']) {
      buf.writeln('| $s | ${CardFactory.deckSize(s)} | ${_deckType(s)} |');
    }
    buf.writeln();

    // Recommendations for LLM
    buf.writeln('## 🤖 LLM 분석 요청');
    buf.writeln();
    buf.writeln('1. 위 통계를 바탕으로 사용자의 학습 패턴을 분석하세요.');
    buf.writeln('2. 어떤 과목이 너무 쉽거나 어려운가요?');
    buf.writeln('3. 다음에 추천할 과목은 무엇인가요?');
    buf.writeln('4. 부족한 카드 덱을 보충할 컨텐츠를 생성하세요.');
    buf.writeln();
    buf.writeln('응답 형식: JSON');
    buf.writeln('```json');
    buf.writeln('{');
    buf.writeln('  "analysis": "사용자 패턴 분석",');
    buf.writeln('  "adjustment": {"subject": "영어", "level": "up|down", "reason": "..."},');
    buf.writeln('  "newCards": [{"subject": "영어", "cards": ["word meaning", ...]}],');
    buf.writeln('  "recommend": "다음 추천 과목"');
    buf.writeln('}');
    buf.writeln('```');

    return buf.toString();
  }

  String _deckType(String s) => switch (s) {
    '뉴스' => 'RSS 실시간',
    '유머' => '1회성',
    '영어듣기' => '청각형',
    _ => 'FSRS 학습',
  };

  /// Short summary for daily cron/card generation
  String dailySummary() {
    final today = _daily[_today];
    if (today == null) return '오늘은 아직 학습하지 않았습니다.';
    final rate = today.total > 0 ? (today.correct / today.total * 100).round() : 0;
    return '오늘 ${today.total}장 ($rate% 정답). ';
  }
}

class _DayLog {
  int total = 0, correct = 0;
  int totalMs = 0, countMs = 0;
  List<String> subjectChanges = [];
}
