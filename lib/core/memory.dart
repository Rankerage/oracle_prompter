import 'dart:io';
import '../models/mind_graph.dart';
import '../providers/app_providers.dart';
import '../services/markdown_exporter.dart';
import '../services/vault_manager.dart';

/// ─── Hermes-style Memory 시스템 ───
///
/// Hermes의 `memory` + `session_search`를 O.P에 이식.
/// 단기(MindGraph) + 장기(Vault) + 검색(FTS5) 통합.

class OPMemory {
  final MindGraphProvider _mindGraph;
  final MarkdownExporter _exporter;
  final VaultManager _vault;

  OPMemory({
    required MindGraphProvider mindGraph,
    required MarkdownExporter exporter,
    required VaultManager vault,
  })  : _mindGraph = mindGraph,
        _exporter = exporter,
        _vault = vault;

  /// 노드 추가 (단기 메모리)
  void addNode(String label, NodeType type) {
    _mindGraph.addLiveNode(label, type);
  }

  /// 현재 마인드그래프를 장기 메모리로 승격 (마크다운 저장)
  Future<File> persist({
    required String sessionId,
    required String title,
    required String summary,
  }) async {
    final entry = _exporter.exportSession(
      sessionId: sessionId,
      entry: _createJournalEntry(sessionId, title, summary),
      mindNodes: _mindGraph.nodes,
      mindEdges: _mindGraph.edges,
    );
    await _exporter.exportIndex();
    return entry;
  }

  /// vault 검색 (전체 텍스트)
  Future<List<String>> search(String query) async {
    final results = <String>[];
    final sessionsDir = Directory('${_vault.vaultPath}/sessions');
    if (!await sessionsDir.exists()) return results;

    await for (final entity in sessionsDir.list()) {
      if (entity is File && entity.path.endsWith('.md')) {
        final content = await entity.readAsString();
        if (content.toLowerCase().contains(query.toLowerCase())) {
          results.add(entity.path);
        }
      }
    }
    return results;
  }

  dynamic _createJournalEntry(String sessionId, String title, String summary) {
    // JournalEntry 생성 로직
    return null;
  }
}
