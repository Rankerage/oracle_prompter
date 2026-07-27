import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';
import '../models/mind_graph.dart';

/// 📝 마크다운 내보내기 — 세션/주제/개체/일간 문서 생성
class MarkdownExporter {
  late Directory _vaultDir;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _vaultDir = Directory('${appDir.path}/vault');
    if (!await _vaultDir.exists()) {
      await _vaultDir.create(recursive: true);
      await Directory('${_vaultDir.path}/sessions').create();
      await Directory('${_vaultDir.path}/topics').create();
      await Directory('${_vaultDir.path}/entities').create();
      await Directory('${_vaultDir.path}/daily').create();
      await Directory('${_vaultDir.path}/graph').create();
    }
  }

  /// vault/ 경로
  String get vaultPath => _vaultDir.path;

  /// 세션 마크다운 생성
  Future<File> exportSession({
    required String sessionId,
    required JournalEntry entry,
    required List<MindNode> mindNodes,
    required List<MindEdge> mindEdges,
    String? rawTranscript,
  }) async {
    await init();

    final dateStr = _formatDate(entry.startTime);
    final timeStr = _formatTime(entry.startTime);
    final safeTitle = entry.title.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
    final filename = '${dateStr}_${timeStr}_$safeTitle.md';

    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('session_id: $sessionId');
    buffer.writeln('date: ${entry.startTime.toIso8601String()}');
    if (entry.endTime != null) {
      final duration = entry.endTime!.difference(entry.startTime);
      buffer.writeln('duration: ${duration.inMinutes}분');
    }
    if (entry.locations.isNotEmpty) {
      buffer.writeln('location: ${entry.locations.first.name ?? "미상"}');
    }
    if (entry.mood != null) {
      buffer.writeln('mood: ${entry.mood}');
    }
    buffer.writeln('keywords: [${entry.keywords.join(", ")}]');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('# ${entry.title}');
    buffer.writeln();
    buffer.writeln('## 요약');
    buffer.writeln(entry.summary);
    buffer.writeln();

    // 대화 기록
    if (rawTranscript != null && rawTranscript.isNotEmpty) {
      buffer.writeln('## 대화 기록');
      buffer.writeln(rawTranscript);
      buffer.writeln();
    }

    // 마인드그래프
    if (mindNodes.isNotEmpty) {
      buffer.writeln('## 마인드그래프');
      for (final node in mindNodes) {
        buffer.writeln('- **${node.label}** (${node.type.name})');
      }
      buffer.writeln();
    }

    // 위치
    if (entry.locations.isNotEmpty) {
      buffer.writeln('## 위치');
      for (final loc in entry.locations) {
        buffer.writeln('- ${loc.name ?? "미상"} (${loc.latitude}, ${loc.longitude})');
      }
      buffer.writeln();
    }

    final file = File('${_vaultDir.path}/sessions/$filename');
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// 일간 다이제스트 생성
  Future<File> exportDailyDigest({
    required DateTime date,
    required List<JournalEntry> entries,
  }) async {
    await init();

    final dateStr = _formatDate(date);
    final buffer = StringBuffer();
    buffer.writeln('# $dateStr');
    buffer.writeln();
    buffer.writeln('## 오늘의 대화 (${entries.length}건)');
    buffer.writeln();

    for (final entry in entries) {
      final timeStr = _formatTime(entry.startTime);
      buffer.writeln('### $timeStr — ${entry.title}');
      buffer.writeln(entry.summary);
      buffer.writeln();
    }

    final file = File('${_vaultDir.path}/daily/$dateStr.md');
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// 전체 인덱스 생성
  Future<File> exportIndex() async {
    await init();

    final sessionsDir = Directory('${_vaultDir.path}/sessions');
    final topicsDir = Directory('${_vaultDir.path}/topics');
    final entitiesDir = Directory('${_vaultDir.path}/entities');
    final dailyDir = Directory('${_vaultDir.path}/daily');

    final buffer = StringBuffer();
    buffer.writeln('# OraclePrompter — 개인 지식 베이스');
    buffer.writeln();
    buffer.writeln('> 마지막 업데이트: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    // 세션 목록
    buffer.writeln('## 📂 세션');
    if (await sessionsDir.exists()) {
      final files = await sessionsDir.list().toList();
      for (final f in files) {
        if (f is File) {
          final name = f.path.split('/').last.replaceAll('.md', '');
          buffer.writeln('- [[sessions/${f.path.split('/').last}|$name]]');
        }
      }
    }
    buffer.writeln();

    // 주제별
    buffer.writeln('## 📑 주제별');
    if (await topicsDir.exists()) {
      final files = await topicsDir.list().toList();
      for (final f in files) {
        if (f is File) {
          final name = f.path.split('/').last.replaceAll('.md', '');
          buffer.writeln('- [[topics/${f.path.split('/').last}|$name]]');
        }
      }
    }
    buffer.writeln();

    final file = File('${_vaultDir.path}/index.md');
    await file.writeAsString(buffer.toString());
    return file;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}시${dt.minute.toString().padLeft(2, '0')}분';
}
