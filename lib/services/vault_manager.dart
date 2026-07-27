import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 🗄️ Vault 관리자 — 마크다운 문서 저장소 관리
class VaultManager {
  late Directory _vaultDir;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _vaultDir = Directory('${appDir.path}/vault');
    _ensureDirs();
  }

  Future<void> _ensureDirs() async {
    for (final sub in ['sessions', 'topics', 'entities', 'daily', 'graph']) {
      final dir = Directory('${_vaultDir.path}/$sub');
      if (!await dir.exists()) await dir.create(recursive: true);
    }
  }

  String get vaultPath => _vaultDir.path;

  /// 모든 세션 파일 목록
  Future<List<File>> listSessions() async {
    final dir = Directory('${_vaultDir.path}/sessions');
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().toList();
  }

  /// 모든 주제 파일 목록
  Future<List<File>> listTopics() async {
    final dir = Directory('${_vaultDir.path}/topics');
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().toList();
  }

  /// vault 크기
  Future<int> totalSize() async {
    int size = 0;
    await for (final entity in _vaultDir.list(recursive: true)) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  /// vault 백업 (외부 저장소로 복사)
  Future<String?> backup(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);
      if (!await backupDir.exists()) await backupDir.create(recursive: true);
      await _copyDir(_vaultDir, backupDir);
      return backupPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _copyDir(Directory source, Directory destination) async {
    await for (final entity in source.list()) {
      if (entity is File) {
        final newPath = '${destination.path}/${entity.path.split('/').last}';
        await entity.copy(newPath);
      }
    }
  }
}
