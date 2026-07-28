import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 📁 Markdown Vault — Hermes-style knowledge base
///
/// Structure:
///   vault/
///   ├── index.md           → 관문. 모든 파일 링크
///   ├── memory/            → 선언적 사실만. "사용자는 ~를 선호함"
///   ├── sessions/          → 일자별 모든 카드 응답 로그
///   ├── skills/            → .md 워크플로우 파일
///   └── cron/              → 예정된 작업
///
/// AI는 매 세션 시작 시 index.md → 참조 파일들 → 프롬프트 주입
class MarkdownVault {
  static final MarkdownVault _i = MarkdownVault._();
  factory MarkdownVault() => _i;
  MarkdownVault._();

  late Directory _root;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _root = Directory('${appDir.path}/vault');
    await _root.create(recursive: true);
    await _ensureDirs();
    await _ensureIndex();
  }

  Future<void> _ensureDirs() async {
    for (final d in ['memory', 'sessions', 'skills', 'cron']) {
      await Directory('${_root.path}/$d').create(recursive: true);
    }
  }

  // ─── index.md — AI의 진입점 ────────────────────

  Future<void> _ensureIndex() async {
    final file = File('${_root.path}/index.md');
    if (!await file.exists()) {
      await file.writeAsString('''# TokTok Vault
      
## 📂 구조
- [[memory/preferences]] — 사용자 선호
- [[memory/interests]] — 관심사
- [[memory/learning]] — 학습 프로필
- [[sessions/]] — 세션 로그
- [[skills/]] — 학습 스킬

마지막 업데이트: ${DateTime.now().toIso8601String()}
''');
    }
  }

  // ─── Memory = 선언적 사실만 ────────────────────

  /// Write a memory fact. Format: declarative statement.
  Future<void> writeMemory(String category, String fact) async {
    final file = File('${_root.path}/memory/$category.md');
    final exists = await file.exists();
    final content = exists ? await file.readAsString() : '# $category\n\n';
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    await file.writeAsString('$content- [$timestamp] $fact\n');
  }

  /// Read all memory facts for LLM context
  Future<String> readMemories() async {
    final dir = Directory('${_root.path}/memory');
    if (!await dir.exists()) return '';
    final buf = StringBuffer();
    await for (final f in dir.list()) {
      if (f is File && f.path.endsWith('.md')) {
        buf.writeln(await f.readAsString());
        buf.writeln();
      }
    }
    return buf.toString();
  }

  // ─── Session = 일자별 카드 응답 ─────────────────

  Future<void> logCardResponse(String statement, int confidence) async {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final file = File('${_root.path}/sessions/$date.md');
    final exists = await file.exists();
    final content = exists ? await file.readAsString() : '# $date\n\n';
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final emoji = confidence >= 1 ? '○' : '✕';
    await file.writeAsString('$content- $time $emoji $statement (신뢰: $confidence)\n');
  }

  /// Read session for a date
  Future<String> readSession(String date) async {
    final file = File('${_root.path}/sessions/$date.md');
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  // ─── LLM Context Builder ───────────────────────

  /// Build context block to inject into LLM prompt
  Future<String> buildLLMContext() async {
    final buf = StringBuffer();
    buf.writeln('# 사용자 컨텍스트 (vault 기반)');
    buf.writeln();
    buf.writeln('## 선호·취향');
    buf.writeln(await readMemories());
    buf.writeln('## 오늘의 활동');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    buf.writeln(await readSession(today));
    return buf.toString();
  }
}
